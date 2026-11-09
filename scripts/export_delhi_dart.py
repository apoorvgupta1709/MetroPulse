import json

data = json.load(open('MetroPulse/data/production/delhi_metro_production.json', encoding='utf-8'))
lines = data['lines']
stations = data['stations']

out_lines = []
out_lines.append("// AUTO-GENERATED COMPLETE DELHI AND NOIDA METRO PRODUCTION DATASET")
out_lines.append("import '../models/metro_line.dart';")
out_lines.append("import '../models/station.dart';")
out_lines.append("")
out_lines.append("class DelhiFullDataset {")

# Generate Lines
out_lines.append("  static final List<MetroLine> lines = [")
for l in lines:
    st_ids = ', '.join([f"'{sid}'" for sid in l['stationIds']])
    out_lines.append("    const MetroLine(")
    out_lines.append(f"      id: '{l['id']}',")
    out_lines.append("      cityId: 'delhi_ncr',")
    out_lines.append(f"      name: '{l['name']}',")
    out_lines.append(f"      code: '{l['code']}',")
    out_lines.append(f"      colorHex: '{l['colorHex']}',")
    out_lines.append(f"      firstTrain: '{l['firstTrain']}',")
    out_lines.append(f"      lastTrain: '{l['lastTrain']}',")
    out_lines.append(f"      frequencyMinutes: {l['frequencyMinutes']},")
    out_lines.append(f"      startStationName: '{l['startStationName']}',")
    out_lines.append(f"      endStationName: '{l['endStationName']}',")
    out_lines.append(f"      stationIds: [{st_ids}],")
    out_lines.append("    ),")
out_lines.append("  ];")
out_lines.append("")

# Generate Stations
out_lines.append("  static final List<Station> stations = [")
for s in stations:
    line_ids_str = ', '.join([f"'{lid}'" for lid in s['lineIds']])
    hindi = s['hindiName'].replace("'", "\\'")
    name = s['name'].replace("'", "\\'")
    is_inter = 'true' if s['isInterchange'] else 'false'
    out_lines.append("    const Station(")
    out_lines.append(f"      id: '{s['id']}',")
    out_lines.append("      cityId: 'delhi_ncr',")
    out_lines.append(f"      name: '{name}',")
    out_lines.append(f"      hindiName: '{hindi}',")
    out_lines.append(f"      lineIds: [{line_ids_str}],")
    out_lines.append(f"      isInterchange: {is_inter},")
    out_lines.append(f"      latitude: {s['latitude']},")
    out_lines.append(f"      longitude: {s['longitude']},")
    out_lines.append("      facilities: StationFacilities(hasParking: true, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),")
    out_lines.append("      gates: [")
    for g in s['gates']:
        lm = g['landmark'].replace("'", "\\'")
        out_lines.append(f"        StationGate(gateNumber: '{g['gateNumber']}', landmark: '{lm}', hasWheelchairAccess: true),")
    out_lines.append("      ],")
    out_lines.append("      platformDirections: {")
    for p_line, p_dir in s['platformDirections'].items():
        out_lines.append(f"        '{p_line}': '{p_dir}',")
    out_lines.append("      },")
    out_lines.append("    ),")
out_lines.append("  ];")
out_lines.append("}")

with open('MetroPulse/metropulse_main/lib/services/delhi_full_dataset.dart', 'w', encoding='utf-8') as f_out:
    f_out.write('\n'.join(out_lines))

print(f"Generated DelhiFullDataset.dart with {len(lines)} lines and {len(stations)} stations!")
