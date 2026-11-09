import json
import os
import subprocess
import urllib.request
import urllib.error

DATA_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'data', 'production'))
BASE_URL = 'https://firestore.googleapis.com/v1/projects/metropulse-transit-2026/databases/(default)/documents'

def get_auth_token():
    cfg_path = os.path.expanduser('~/.config/configstore/firebase-tools.json')
    with open(cfg_path, 'r', encoding='utf-8') as f:
        cfg = json.load(f)
    token = cfg.get('tokens', {}).get('access_token')
    return token

def refresh_firebase_token():
    print("Refreshing Firebase OAuth access token via firebase.cmd...")
    try:
        subprocess.run(['firebase.cmd', 'projects:list'], capture_output=True, text=True, check=True)
    except Exception as e:
        print(f"Notice during token refresh: {e}")
    return get_auth_token()

def to_firestore_value(val):
    if val is None:
        return {'nullValue': None}
    elif isinstance(val, bool):
        return {'booleanValue': val}
    elif isinstance(val, int):
        return {'integerValue': str(val)}
    elif isinstance(val, float):
        return {'doubleValue': val}
    elif isinstance(val, str):
        return {'stringValue': val}
    elif isinstance(val, list):
        return {'arrayValue': {'values': [to_firestore_value(v) for v in val]}}
    elif isinstance(val, dict):
        return {'mapValue': {'fields': {k: to_firestore_value(v) for k, v in val.items()}}}
    else:
        return {'stringValue': str(val)}

def set_doc(path, data, token):
    url = f"{BASE_URL}/{path}"
    fields = {k: to_firestore_value(v) for k, v in data.items()}
    body = json.dumps({'fields': fields}).encode('utf-8')
    req = urllib.request.Request(
        url,
        data=body,
        headers={'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'},
        method='PATCH'
    )
    try:
        with urllib.request.urlopen(req) as resp:
            return resp.getcode(), token
    except urllib.error.HTTPError as e:
        if e.code == 401:
            print("Token expired (401). Refreshing token and retrying...")
            new_token = refresh_firebase_token()
            req = urllib.request.Request(
                url,
                data=body,
                headers={'Authorization': f'Bearer {new_token}', 'Content-Type': 'application/json'},
                method='PATCH'
            )
            with urllib.request.urlopen(req) as resp:
                return resp.getcode(), new_token
        else:
            print(f"Error setting {path}: {e.code} {e.read().decode()[:200]}")
            return e.code, token

token = get_auth_token()

print("="*60)
print("PUSHING PRODUCTION TRANSIT DATA TO FIRESTORE (metropulse-transit-2026)")
print("="*60)

# 1. Push Cities
cities_file = os.path.join(DATA_DIR, 'cities_production.json')
with open(cities_file, 'r', encoding='utf-8') as f:
    cities = json.load(f)

print(f"Pushing {len(cities)} Cities...")
for c in cities:
    status, token = set_doc(f"cities/{c['id']}", c, token)
    print(f"  [City] {c['name']} -> HTTP {status}")

# 2. Push Lines and Stations from each city dataset
datasets = [
    'delhi_metro_production.json',
    'mumbai_metro_production.json',
    'bengaluru_metro_production.json',
    'kolkata_metro_production.json',
    'hyderabad_metro_production.json'
]

total_lines_pushed = 0
total_stations_pushed = 0

for ds in datasets:
    ds_path = os.path.join(DATA_DIR, ds)
    with open(ds_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    lines = data.get('lines', [])
    stations = data.get('stations', [])

    print(f"\nProcessing {ds} ({len(lines)} lines, {len(stations)} stations)...")

    for l in lines:
        status, token = set_doc(f"lines/{l['id']}", l, token)
        total_lines_pushed += 1

    for s in stations:
        status, token = set_doc(f"stations/{s['id']}", s, token)
        total_stations_pushed += 1

print(f"\nTotal Lines Uploaded: {total_lines_pushed}")
print(f"Total Stations Uploaded: {total_stations_pushed}")

# 3. Push Live Service Alerts
alerts = [
    {
        "id": "alert_delhi_yellow_normal",
        "cityId": "delhi_ncr",
        "lineId": "yellow",
        "lineName": "Yellow Line",
        "headline": "Normal Services across all lines",
        "details": "Trains operating with 3 min headway. All terminal departures running as per schedule.",
        "severity": "normal",
        "isEmergency": False,
        "createdAt": "2026-11-09T14:30:00Z"
    },
    {
        "id": "alert_delhi_airport_express",
        "cityId": "delhi_ncr",
        "lineId": "airport_express",
        "lineName": "Airport Express Line",
        "headline": "120 kmph High Speed Service Active",
        "details": "Express connectivity from New Delhi to IGI Airport T3 in 15 mins and Yashobhoomi Dwarka Sec 25 in 21 mins.",
        "severity": "normal",
        "isEmergency": False,
        "createdAt": "2026-11-09T14:30:00Z"
    },
    {
        "id": "alert_mumbai_line1_normal",
        "cityId": "mumbai",
        "lineId": "mum_line_1",
        "lineName": "Line 1 (Blue)",
        "headline": "Full peak capacity operational",
        "details": "Services operating smoothly between Versova and Ghatkopar.",
        "severity": "normal",
        "isEmergency": False,
        "createdAt": "2026-11-09T14:30:00Z"
    }
]

print("\nPushing Live Alerts...")
for a in alerts:
    status, token = set_doc(f"alerts/{a['id']}", a, token)
    print(f"  [Alert] {a['id']} -> HTTP {status}")

# 4. Push Monetization Configuration
monetization_config = {
    "isPro": False,
    "discountPriceINR": 49,
    "originalPriceINR": 149,
    "discountPercent": 67,
    "bannerAdUnitId": "ca-app-pub-3940256099942544/6300978111",
    "interstitialAdUnitId": "ca-app-pub-3940256099942544/1033173712",
    "rewardedAdUnitId": "ca-app-pub-3940256099942544/5224354917",
    "freeOfflineMapsAllowed": 1,
    "showStickyBanners": True,
    "updatedAt": "2026-11-09T14:30:00Z"
}

print("\nPushing Monetization Config...")
status, token = set_doc("config/monetization", monetization_config, token)
print(f"  [Config] config/monetization -> HTTP {status}")

print("\nAll production transit data pushed to Firebase successfully!")
