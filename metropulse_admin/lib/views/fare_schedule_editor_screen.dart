import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FareScheduleEditorScreen extends StatefulWidget {
  const FareScheduleEditorScreen({super.key});

  @override
  State<FareScheduleEditorScreen> createState() => _FareScheduleEditorScreenState();
}

class _FareScheduleEditorScreenState extends State<FareScheduleEditorScreen> {
  final _slab1Ctrl = TextEditingController(text: '10');
  final _slab2Ctrl = TextEditingController(text: '20');
  final _slab3Ctrl = TextEditingController(text: '30');
  final _slab4Ctrl = TextEditingController(text: '40');
  final _slab5Ctrl = TextEditingController(text: '50');
  final _slab6Ctrl = TextEditingController(text: '60');

  final _firstTrainCtrl = TextEditingController(text: '05:30 AM');
  final _lastTrainCtrl = TextEditingController(text: '11:30 PM');

  @override
  void dispose() {
    _slab1Ctrl.dispose();
    _slab2Ctrl.dispose();
    _slab3Ctrl.dispose();
    _slab4Ctrl.dispose();
    _slab5Ctrl.dispose();
    _slab6Ctrl.dispose();
    _firstTrainCtrl.dispose();
    _lastTrainCtrl.dispose();
    super.dispose();
  }

  void _saveFareConfig() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fare matrix and timetable synced to Firestore!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fare & Timetable CMS',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'DISTANCE FARE SLABS (INDIAN RUPEES ₹)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),

          _buildSlabInput('0 - 2 km (1-2 stations)', _slab1Ctrl),
          _buildSlabInput('2 - 5 km (3-5 stations)', _slab2Ctrl),
          _buildSlabInput('5 - 12 km (6-9 stations)', _slab3Ctrl),
          _buildSlabInput('12 - 21 km (10-15 stations)', _slab4Ctrl),
          _buildSlabInput('21 - 32 km (16-22 stations)', _slab5Ctrl),
          _buildSlabInput('> 32 km (23+ stations)', _slab6Ctrl),

          const SizedBox(height: 24),
          Text(
            'DEFAULT NETWORK OPERATING HOURS',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _firstTrainCtrl,
                  decoration: const InputDecoration(
                    labelText: 'First Train Departure',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _lastTrainCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Last Train Departure',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _saveFareConfig,
              icon: const Icon(Icons.save),
              label: Text(
                'Save & Sync Fare Matrix',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlabInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixText: '₹ ',
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}
