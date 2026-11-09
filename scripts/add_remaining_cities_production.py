import json
import os
import subprocess
import urllib.request
import urllib.error

DATA_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'data', 'production'))
BASE_URL = 'https://firestore.googleapis.com/v1/projects/metropulse-transit-2026/databases/(default)/documents'

# 1. CHENNAI METRO
chennai_lines = [
    {
        "id": "chn_blue",
        "cityId": "chennai",
        "name": "Blue Line (Corridor 1: Wimco Nagar - Airport)",
        "code": "C1",
        "colorHex": "#1E88E5",
        "firstTrain": "05:00 AM",
        "lastTrain": "11:00 PM",
        "frequencyMinutes": 5,
        "startStationName": "Wimco Nagar Depot",
        "endStationName": "Chennai International Airport",
        "stationIds": [
            "chn_wimco_nagar", "chn_tollgate", "chn_washermanpet", "chn_chennai_central",
            "chn_government_estate", "chn_lic", "chn_thousand_lights", "chn_ag_dms",
            "chn_teynampet", "chn_nandanam", "chn_saidapet", "chn_guindy",
            "chn_alandur", "chn_meenambakkam", "chn_chennai_airport"
        ]
    },
    {
        "id": "chn_green",
        "cityId": "chennai",
        "name": "Green Line (Corridor 2: Chennai Central - St. Thomas Mount)",
        "code": "C2",
        "colorHex": "#43A047",
        "firstTrain": "05:00 AM",
        "lastTrain": "11:00 PM",
        "frequencyMinutes": 6,
        "startStationName": "Chennai Central (Dr. MGR)",
        "endStationName": "St. Thomas Mount",
        "stationIds": [
            "chn_chennai_central", "chn_egmore", "chn_nehru_park", "chn_kilpauk",
            "chn_pachaiyappa_college", "chn_shenoy_nagar", "chn_anna_nagar_east", "chn_anna_nagar_tower",
            "chn_thirumangalam", "chn_koyambedu", "chn_cmbt", "chn_arumbakkam",
            "chn_vadapalani", "chn_ashok_nagar", "chn_ekkatutthangal", "chn_alandur",
            "chn_st_thomas_mount"
        ]
    }
]

chennai_stations = [
    {
        "id": "chn_chennai_central",
        "cityId": "chennai",
        "name": "Puratchi Thalaivar Dr. MGR Central (Interchange)",
        "hindiName": "चेन्नई सेंट्रल",
        "lineIds": ["chn_blue", "chn_green"],
        "isInterchange": True,
        "latitude": 13.0827,
        "longitude": 80.2755,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Chennai Central Railway Terminal Main Concourse", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Chennai Moore Market Complex & Suburbans", "accessible": True}
        ],
        "platformDirections": {
            "chn_blue": "Platform 1: Chennai Airport | Platform 2: Wimco Nagar Depot",
            "chn_green": "Platform 3: St. Thomas Mount via Koyambedu CMBT"
        }
    },
    {
        "id": "chn_alandur",
        "cityId": "chennai",
        "name": "Alandur (Elevated Dual-Line Interchange)",
        "hindiName": "आलंदूर",
        "lineIds": ["chn_blue", "chn_green"],
        "isInterchange": True,
        "latitude": 13.0039,
        "longitude": 80.2016,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "GST Road & Kathipara Junction", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Alandur Asarkhana", "accessible": True}
        ],
        "platformDirections": {
            "chn_blue": "Platform 1: Chennai Airport | Platform 2: Chennai Central",
            "chn_green": "Platform 3: St. Thomas Mount | Platform 4: Chennai Central via CMBT"
        }
    },
    {
        "id": "chn_chennai_airport",
        "cityId": "chennai",
        "name": "Chennai International Airport",
        "hindiName": "चेन्नई एयरपोर्ट",
        "lineIds": ["chn_blue"],
        "isInterchange": False,
        "latitude": 12.9815,
        "longitude": 80.1637,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Domestic & International Terminals Skywalk Link", "accessible": True}
        ],
        "platformDirections": {
            "chn_blue": "Platform 1 & 2: Wimco Nagar via Chennai Central"
        }
    }
]

# 2. PUNE METRO
pune_lines = [
    {
        "id": "pun_purple",
        "cityId": "pune",
        "name": "Purple Line (Line 1: PCMC - Swargate)",
        "code": "L1",
        "colorHex": "#7B1FA2",
        "firstTrain": "06:00 AM",
        "lastTrain": "10:00 PM",
        "frequencyMinutes": 7,
        "startStationName": "PCMC (Pimpri Chinchwad)",
        "endStationName": "Swargate",
        "stationIds": [
            "pun_pcmc", "pun_tukaram_nagar", "pun_bhosari", "pun_kasarwadi",
            "pun_phugewadi", "pun_dapodi", "pun_bopodi", "pun_khadki",
            "pun_range_hill", "pun_shivajinagar", "pun_civil_court", "pun_budhwar_peth",
            "pun_mandai", "pun_swargate"
        ]
    },
    {
        "id": "pun_aqua",
        "cityId": "pune",
        "name": "Aqua Line (Line 2: Vanaz - Ramwadi)",
        "code": "L2",
        "colorHex": "#00ACC1",
        "firstTrain": "06:00 AM",
        "lastTrain": "10:00 PM",
        "frequencyMinutes": 7,
        "startStationName": "Vanaz",
        "endStationName": "Ramwadi",
        "stationIds": [
            "pun_vanaz", "pun_anand_nagar", "pun_ideal_colony", "pun_nal_stop",
            "pun_garware_college", "pun_deccan_gymkhana", "pun_chhatrapati_sambhaji_udyan", "pun_pmc",
            "pun_civil_court", "pun_mangwar_peth", "pun_pune_railway_station", "pun_ruby_hall_clinic",
            "pun_bund_garden", "pun_yerawada", "pun_kalyani_nagar", "pun_ramwadi"
        ]
    }
]

pune_stations = [
    {
        "id": "pun_civil_court",
        "cityId": "pune",
        "name": "Civil Court Central Interchange Hub",
        "hindiName": "सिविल कोर्ट",
        "lineIds": ["pun_purple", "pun_aqua"],
        "isInterchange": True,
        "latitude": 18.5289,
        "longitude": 73.8569,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "District Court & Sancheti Hospital", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "J.M. Road & Mutha Riverfront", "accessible": True}
        ],
        "platformDirections": {
            "pun_purple": "Platform 1: Swargate | Platform 2: PCMC",
            "pun_aqua": "Platform 3: Ramwadi | Platform 4: Vanaz"
        }
    },
    {
        "id": "pun_pune_railway_station",
        "cityId": "pune",
        "name": "Pune Railway Station Metro",
        "hindiName": "पुणे रेल्वे स्टेशन",
        "lineIds": ["pun_aqua"],
        "isInterchange": True,
        "latitude": 18.5284,
        "longitude": 73.8744,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Pune Junction Railway Platforms 1-6 Link", "accessible": True}
        ],
        "platformDirections": {
            "pun_aqua": "Platform 1: Ramwadi | Platform 2: Vanaz via Civil Court"
        }
    }
]

# 3. AHMEDABAD METRO
ahmedabad_lines = [
    {
        "id": "ahm_red",
        "cityId": "ahmedabad",
        "name": "North-South Line (Red Line: Motera - APMC)",
        "code": "NS",
        "colorHex": "#E53935",
        "firstTrain": "06:20 AM",
        "lastTrain": "10:00 PM",
        "frequencyMinutes": 8,
        "startStationName": "Narendra Modi Motera Stadium",
        "endStationName": "APMC Vasna",
        "stationIds": [
            "ahm_motera_stadium", "ahm_sabarmati", "ahm_aec", "ahm_sabarmati_railway",
            "ahm_ranip", "ahm_vadaj", "ahm_vijay_nagar", "ahm_usmanpura",
            "ahm_old_high_court", "ahm_gandhigram", "ahm_paldi", "ahm_shreyas",
            "ahm_rajiv_nagar", "ahm_jivraj_park", "ahm_apmc"
        ]
    },
    {
        "id": "ahm_blue",
        "cityId": "ahmedabad",
        "name": "East-West Line (Blue Line: Thaltej Gam - Vastral Gam)",
        "code": "EW",
        "colorHex": "#1E88E5",
        "firstTrain": "06:20 AM",
        "lastTrain": "10:00 PM",
        "frequencyMinutes": 8,
        "startStationName": "Thaltej Gam",
        "endStationName": "Vastral Gam",
        "stationIds": [
            "ahm_thaltej_gam", "ahm_thaltej", "ahm_doordarshan_kendra", "ahm_gurukul_road",
            "ahm_gujarat_university", "ahm_commerce_six_road", "ahm_stadium", "ahm_old_high_court",
            "ahm_shahpur", "ahm_gheekanta", "ahm_kalupur_railway", "ahm_kankaria_east",
            "ahm_apparel_park", "ahm_amraiwadi", "ahm_rabari_colony", "ahm_vastral",
            "ahm_nirant_cross_road", "ahm_vastral_gam"
        ]
    }
]

ahmedabad_stations = [
    {
        "id": "ahm_old_high_court",
        "cityId": "ahmedabad",
        "name": "Old High Court Interchange",
        "hindiName": "ओल्ड हाई कोर्ट",
        "lineIds": ["ahm_red", "ahm_blue"],
        "isInterchange": True,
        "latitude": 23.0381,
        "longitude": 72.5694,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Ashram Road & Sabarmati Riverfront", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Income Tax Circle", "accessible": True}
        ],
        "platformDirections": {
            "ahm_red": "Platform 1: APMC | Platform 2: Motera Stadium",
            "ahm_blue": "Platform 3: Vastral Gam | Platform 4: Thaltej Gam"
        }
    },
    {
        "id": "ahm_motera_stadium",
        "cityId": "ahmedabad",
        "name": "Narendra Modi Motera Stadium",
        "hindiName": "नरेंद्र मोदी मोटेरा स्टेडियम",
        "lineIds": ["ahm_red"],
        "isInterchange": False,
        "latitude": 23.0913,
        "longitude": 72.5976,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "World's Largest Cricket Stadium Gate 1 Link", "accessible": True}
        ],
        "platformDirections": {
            "ahm_red": "Platform 1 & 2: APMC via Old High Court"
        }
    }
]

# 4. KOCHI METRO
kochi_lines = [
    {
        "id": "koc_cyan",
        "cityId": "kochi",
        "name": "Line 1 (Cyan Line: Aluva - Thripunithura)",
        "code": "L1",
        "colorHex": "#00BCD4",
        "firstTrain": "06:00 AM",
        "lastTrain": "10:30 PM",
        "frequencyMinutes": 7,
        "startStationName": "Aluva",
        "endStationName": "Thripunithura Railway Station",
        "stationIds": [
            "koc_aluva", "koc_pulinchodu", "koc_companypady", "koc_ambattukavu",
            "koc_muttom", "koc_kalamassery", "koc_cochin_university", "koc_pathadipalam",
            "koc_edapally", "koc_changampuzha_park", "koc_palarivattom", "koc_jln_stadium",
            "koc_kaloor", "koc_lissie", "koc_mg_road", "koc_maharajas_college",
            "koc_ernakulam_south", "koc_kadavanthra", "koc_elamkulam", "koc_vyttila",
            "koc_thaikoodam", "koc_petta", "koc_vadakkekotta", "koc_sn_junction",
            "koc_thripunithura"
        ]
    }
]

kochi_stations = [
    {
        "id": "koc_aluva",
        "cityId": "kochi",
        "name": "Aluva Metro Terminal",
        "hindiName": "अलुवा",
        "lineIds": ["koc_cyan"],
        "isInterchange": False,
        "latitude": 10.1086,
        "longitude": 76.3533,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Aluva KSRTC Bus Stand & Periyar River View", "accessible": True}
        ],
        "platformDirections": {
            "koc_cyan": "Platform 1 & 2: Thripunithura via Ernakulam South"
        }
    },
    {
        "id": "koc_vyttila",
        "cityId": "kochi",
        "name": "Vyttila Mobility Hub (Water Metro Interchange)",
        "hindiName": "वाइटिला",
        "lineIds": ["koc_cyan"],
        "isInterchange": True,
        "latitude": 9.9676,
        "longitude": 76.3218,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Vyttila Water Metro Ferry Jetty & Inter-city Bus Port", "accessible": True}
        ],
        "platformDirections": {
            "koc_cyan": "Platform 1: Thripunithura | Platform 2: Aluva"
        }
    }
]

# 5. JAIPUR METRO
jaipur_lines = [
    {
        "id": "jai_pink",
        "cityId": "jaipur",
        "name": "Pink Line (Mansarovar - Badi Chaupar)",
        "code": "L1",
        "colorHex": "#E91E63",
        "firstTrain": "06:20 AM",
        "lastTrain": "10:00 PM",
        "frequencyMinutes": 8,
        "startStationName": "Mansarovar",
        "endStationName": "Badi Chaupar (Hawa Mahal)",
        "stationIds": [
            "jai_mansarovar", "jai_new_atish_market", "jai_vivek_vihar", "jai_shyam_nagar",
            "jai_ram_nagar", "jai_civil_lines", "jai_railway_station", "jai_sindhi_camp",
            "jai_chandpole", "jai_chhoti_chaupar", "jai_badi_chaupar"
        ]
    }
]

jaipur_stations = [
    {
        "id": "jai_badi_chaupar",
        "cityId": "jaipur",
        "name": "Badi Chaupar (Hawa Mahal & City Palace)",
        "hindiName": "बड़ी चौपड़",
        "lineIds": ["jai_pink"],
        "isInterchange": False,
        "latitude": 26.9242,
        "longitude": 75.8267,
        "facilities": {"hasParking": False, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Hawa Mahal & Johari Bazaar Entry", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "City Palace & Jantar Mantar Link", "accessible": True}
        ],
        "platformDirections": {
            "jai_pink": "Platform 1 & 2: Mansarovar via Sindhi Camp & Railway Station"
        }
    },
    {
        "id": "jai_sindhi_camp",
        "cityId": "jaipur",
        "name": "Sindhi Camp Inter-State Bus Terminal",
        "hindiName": "सिंधी कैंप",
        "lineIds": ["jai_pink"],
        "isInterchange": True,
        "latitude": 26.9238,
        "longitude": 75.8016,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "RSRTC Central Bus Stand Concourse", "accessible": True}
        ],
        "platformDirections": {
            "jai_pink": "Platform 1: Badi Chaupar | Platform 2: Mansarovar"
        }
    }
]

# Write JSON files
with open(os.path.join(DATA_DIR, 'chennai_metro_production.json'), 'w', encoding='utf-8') as f:
    json.dump({"lines": chennai_lines, "stations": chennai_stations}, f, indent=2, ensure_ascii=False)

with open(os.path.join(DATA_DIR, 'pune_metro_production.json'), 'w', encoding='utf-8') as f:
    json.dump({"lines": pune_lines, "stations": pune_stations}, f, indent=2, ensure_ascii=False)

with open(os.path.join(DATA_DIR, 'ahmedabad_metro_production.json'), 'w', encoding='utf-8') as f:
    json.dump({"lines": ahmedabad_lines, "stations": ahmedabad_stations}, f, indent=2, ensure_ascii=False)

with open(os.path.join(DATA_DIR, 'kochi_metro_production.json'), 'w', encoding='utf-8') as f:
    json.dump({"lines": kochi_lines, "stations": kochi_stations}, f, indent=2, ensure_ascii=False)

with open(os.path.join(DATA_DIR, 'jaipur_metro_production.json'), 'w', encoding='utf-8') as f:
    json.dump({"lines": jaipur_lines, "stations": jaipur_stations}, f, indent=2, ensure_ascii=False)

print("Generated local production datasets for Chennai, Pune, Ahmedabad, Kochi, Jaipur successfully!")
