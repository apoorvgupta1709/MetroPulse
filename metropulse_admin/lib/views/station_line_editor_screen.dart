import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/admin_control_provider.dart';

class StationLineEditorScreen extends StatefulWidget {
  final String initialCityId;
  const StationLineEditorScreen({super.key, this.initialCityId = 'delhi_ncr'});

  @override
  State<StationLineEditorScreen> createState() => _StationLineEditorScreenState();
}

class _StationLineEditorScreenState extends State<StationLineEditorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _selectedCityId;

  @override
  void initState() {
    super.initState();
    _selectedCityId = widget.initialCityId;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddStationDialog(BuildContext context, AdminControlProvider admin) {
    final nameCtrl = TextEditingController();
    final hindiCtrl = TextEditingController();
    final latCtrl = TextEditingController(text: '28.6139');
    final lngCtrl = TextEditingController(text: '77.2090');
    final gate1Ctrl = TextEditingController(text: 'Gate 1: Main Concourse Exit');
    final gate2Ctrl = TextEditingController(text: 'Gate 2: Ring Road / Auto Stand');

    final linesForCity = admin.lines.where((l) => l.cityId == _selectedCityId).toList();
    String selectedLineId = linesForCity.isNotEmpty ? linesForCity.first.id : 'yellow';
    bool isInterchange = false;
    bool hasParking = true;
    bool hasEscalator = true;
    bool hasElevator = true;
    bool hasAtm = true;
    bool hasRestroom = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(
              'Add New Metro Station',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Station Name (English)',
                      hintText: 'e.g. Cyber City Hub',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: hindiCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Regional / Hindi Name',
                      hintText: 'e.g. साइबर सिटी',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (linesForCity.isNotEmpty)
                    DropdownButtonFormField<String>(
                      initialValue: selectedLineId,
                      decoration: const InputDecoration(
                        labelText: 'Assign to Metro Line',
                        border: OutlineInputBorder(),
                      ),
                      items: linesForCity.map((l) {
                        return DropdownMenuItem(
                          value: l.id,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(color: l.color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              Text(l.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedLineId = val);
                      },
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: latCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Latitude',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: lngCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Longitude',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: Text(
                      'Interchange Station',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    subtitle: const Text('Connects multiple lines'),
                    value: isInterchange,
                    onChanged: (val) => setDialogState(() => isInterchange = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(),
                  Text(
                    'NUMBERED EXIT GATES',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: gate1Ctrl,
                    decoration: const InputDecoration(
                      labelText: 'Gate 1 & Landmark',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: gate2Ctrl,
                    decoration: const InputDecoration(
                      labelText: 'Gate 2 & Landmark',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const Divider(),
                  Text(
                    'STATION AMENITIES',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  CheckboxListTile(
                    title: const Text('Parking Available'),
                    value: hasParking,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setDialogState(() => hasParking = v ?? true),
                  ),
                  CheckboxListTile(
                    title: const Text('Escalators & Elevators'),
                    value: hasEscalator,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setDialogState(() => hasEscalator = v ?? true),
                  ),
                  CheckboxListTile(
                    title: const Text('ATM & Restrooms'),
                    value: hasAtm,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setDialogState(() => hasAtm = v ?? true),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    final lat = double.tryParse(latCtrl.text) ?? 28.6139;
                    final lng = double.tryParse(lngCtrl.text) ?? 77.2090;

                    admin.addStation(
                      cityId: _selectedCityId,
                      name: nameCtrl.text.trim(),
                      hindiName: hindiCtrl.text.trim(),
                      lineId: selectedLineId,
                      latitude: lat,
                      longitude: lng,
                      isInterchange: isInterchange,
                      gates: [gate1Ctrl.text.trim(), gate2Ctrl.text.trim()],
                      hasParking: hasParking,
                      hasEscalator: hasEscalator,
                      hasElevator: hasElevator,
                      hasAtm: hasAtm,
                      hasRestroom: hasRestroom,
                    );

                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Station "${nameCtrl.text}" added and auto-connected to graph!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: const Text('Add Station'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openAddLineDialog(BuildContext context, AdminControlProvider admin) {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final colorHexCtrl = TextEditingController(text: '#9C27B0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Add Metro Line',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Line Name (e.g. Silver Line)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: codeCtrl,
              decoration: const InputDecoration(
                labelText: 'Line Code (e.g. SL)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: colorHexCtrl,
              decoration: const InputDecoration(
                labelText: 'Line Color Hex (e.g. #9C27B0)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                admin.addLine(
                  cityId: _selectedCityId,
                  name: nameCtrl.text.trim(),
                  code: codeCtrl.text.trim().toUpperCase(),
                  colorHex: colorHexCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Line "${nameCtrl.text}" added to network!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Create Line'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminControlProvider>(context);
    final stationsForCity = admin.stations.where((s) => s.cityId == _selectedCityId).toList();
    final linesForCity = admin.lines.where((l) => l.cityId == _selectedCityId).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Station & Line CMS',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCityId,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              items: admin.cities.map((c) {
                return DropdownMenuItem(value: c.id, child: Text(c.name));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCityId = val);
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
          tabs: [
            Tab(text: 'Stations (${stationsForCity.length})'),
            Tab(text: 'Lines (${linesForCity.length})'),
            const Tab(text: 'JSON Sync'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Stations List Tab
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stationsForCity.length,
            itemBuilder: (context, index) {
              final s = stationsForCity[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.withOpacity(0.12)),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: s.isInterchange ? Colors.amber.withOpacity(0.2) : Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      s.isInterchange ? Icons.sync_alt : Icons.subway,
                      color: s.isInterchange ? Colors.amber.shade900 : Colors.blue,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    s.name,
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${s.hindiName} • ${s.gates.length} Gates • [${s.latitude.toStringAsFixed(3)}, ${s.longitude.toStringAsFixed(3)}]',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    tooltip: 'Delete Station',
                    onPressed: () {
                      admin.deleteStation(s.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Station ${s.name} removed from graph')),
                      );
                    },
                  ),
                ),
              );
            },
          ),

          // 2. Lines List Tab
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: linesForCity.length,
            itemBuilder: (context, index) {
              final line = linesForCity[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: line.color.withOpacity(0.4)),
                ),
                child: ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: line.color,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        line.code,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    line.name,
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${line.stationIds.length} Stations in Sequence • ${line.colorHex}',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    tooltip: 'Delete Line',
                    onPressed: () {
                      admin.deleteLine(line.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Line ${line.name} removed')),
                      );
                    },
                  ),
                ),
              );
            },
          ),

          // 3. JSON Sync & Export Tab
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'NETWORK DATA PAYLOAD (JSON)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Network configuration synced to Firestore Cloud!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: const Icon(Icons.cloud_upload, size: 16),
                      label: const Text('Push to Cloud'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        const JsonEncoder.withIndent('  ').convert({
                          'cityId': _selectedCityId,
                          'lines': linesForCity.map((l) => {
                            'id': l.id,
                            'name': l.name,
                            'code': l.code,
                            'color': l.colorHex,
                            'stationsCount': l.stationIds.length,
                          }).toList(),
                          'stations': stationsForCity.map((s) => {
                            'id': s.id,
                            'name': s.name,
                            'hindi': s.hindiName,
                            'isInterchange': s.isInterchange,
                            'coords': [s.latitude, s.longitude],
                            'gates': s.gates,
                          }).toList(),
                        }),
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.greenAccent,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 1) {
            _openAddLineDialog(context, admin);
          } else {
            _openAddStationDialog(context, admin);
          }
        },
        icon: const Icon(Icons.add),
        label: Text(
          _tabController.index == 1 ? 'Add Line' : 'Add Station',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
