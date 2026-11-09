import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/admin_control_provider.dart';

class CityNetworkCmsScreen extends StatefulWidget {
  const CityNetworkCmsScreen({super.key});

  @override
  State<CityNetworkCmsScreen> createState() => _CityNetworkCmsScreenState();
}

class _CityNetworkCmsScreenState extends State<CityNetworkCmsScreen> {
  void _openAddCityDialog() {
    final nameCtrl = TextEditingController();
    final currencyCtrl = TextEditingController(text: '₹');
    final countryCtrl = TextEditingController(text: 'India');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Add Metro Network',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'City / Network Name (e.g. Lucknow Metro)'),
            ),
            TextField(
              controller: currencyCtrl,
              decoration: const InputDecoration(labelText: 'Currency Symbol (₹, \$, AED, €, £)'),
            ),
            TextField(
              controller: countryCtrl,
              decoration: const InputDecoration(labelText: 'Country'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                Provider.of<AdminControlProvider>(context, listen: false).addCity(
                  name: nameCtrl.text.trim(),
                  currency: currencyCtrl.text.trim(),
                  country: countryCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${nameCtrl.text} network added successfully!')),
                );
              }
            },
            child: const Text('Add Network'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminControlProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'City & Network CMS',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add City Network',
            onPressed: _openAddCityDialog,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: admin.cities.length,
        itemBuilder: (context, index) {
          final city = admin.cities[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.12)),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    city.currency,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              title: Text(
                city.name,
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                '${city.country} • ${city.linesCount} Lines • ${city.stationsCount} Stations',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade600),
              ),
              trailing: PopupMenuButton(
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'lines', child: Text('Manage Lines & Colors')),
                  const PopupMenuItem(value: 'stations', child: Text('Edit Stations & Gates')),
                  const PopupMenuItem(value: 'map', child: Text('Assign Vector Map')),
                ],
                onSelected: (val) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening CMS editor for ${city.name}')),
                  );
                },
              ),
            ),
          ),
        );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddCityDialog,
        icon: const Icon(Icons.add),
        label: Text(
          'Add City',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
