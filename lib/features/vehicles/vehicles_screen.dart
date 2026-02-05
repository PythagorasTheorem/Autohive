import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../core/theme.dart';
import 'vehicles_provider.dart';
import 'vehicle.dart';
import '../vehicle_detail/vehicle_detail_screen.dart';
import 'package:autohive/core/app_drawer.dart';
import '../profile/profile_screen.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});
  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<VehiclesProvider>().load());
  }

  void _showAddVehicleDialog(BuildContext context, VehiclesProvider provider) {
    showDialog(
      context: context,
      builder: (_) => _AddVehicleDialog(provider: provider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<VehiclesProvider>();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: SafeArea(
          child: Container(
            color: kNavy,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Builder(
                  // ✅ open drawer
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
                Image.asset('assets/logo/autohive_logo.png', height: 32),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Vehicle Inventory',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kCyan,
        onPressed: () => _showAddVehicleDialog(context, p),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: p.refresh,
        child: Column(
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEFF4),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _ctrl,
                  onChanged: p.setSearch,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search),
                    hintText: 'Search vehicles...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            // Filters
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
              child: Wrap(
                spacing: 8,
                children: [
                  _Chip(
                    label: 'All',
                    value: 'all',
                    selected: p.filter == 'all',
                    onTap: () => p.setFilter('all'),
                  ),
                  _Chip(
                    label: 'Available',
                    value: 'available',
                    selected: p.filter == 'available',
                    onTap: () => p.setFilter('available'),
                  ),
                  _Chip(
                    label: 'Maintenance',
                    value: 'maintenance',
                    selected: p.filter == 'maintenance',
                    onTap: () => p.setFilter('maintenance'),
                  ),
                  _Chip(
                    label: 'In-use',
                    value: 'in_use',
                    selected: p.filter == 'in_use',
                    onTap: () => p.setFilter('in_use'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // List
            Expanded(
              child: p.visible.isEmpty
                  ? const Center(child: Text('No vehicles found'))
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: p.visible.length,
                      itemBuilder: (_, i) => _VehicleCard(item: p.visible[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label, value;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: kCyan,
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
      backgroundColor: const Color(0xFFEDEFF4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle item;
  const _VehicleCard({required this.item});

  Color _statusColor(String s) {
    switch (s) {
      case 'available':
        return const Color(0xFF2E7D32); // green
      case 'in_use':
        return const Color(0xFFEF6C00); // orange
      case 'maintenance':
        return const Color(0xFFC62828); // red
      default:
        return Colors.grey;
    }
  }

  Color _serviceColor(String? isoDate) {
    if (isoDate == null || isoDate.trim().isEmpty) return Colors.black54;
    try {
      final due = DateTime.parse(isoDate); // expects YYYY-MM-DD
      final today = DateTime.now();
      final diff = due
          .difference(DateTime(today.year, today.month, today.day))
          .inDays;
      if (diff < 0) return const Color(0xFFC62828); // overdue = red
      if (diff <= 30) return const Color(0xFFF9A825); // <=30 days = amber
      return Colors.black87; // ok
    } catch (_) {
      return Colors.black54;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VehicleDetailScreen(vehicleId: item.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Left: image or placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: (item.imagePath != null && item.imagePath!.isNotEmpty)
                    ? _buildVehicleImage(item.imagePath!)
                    : Container(
                        width: 88,
                        height: 56,
                        color: const Color(0xFFEDEFF4),
                        child: const Icon(Icons.directions_car),
                      ),
              ),
              const SizedBox(width: 12),
              // Right: details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.brand.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Plate: ${item.plate}',
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Text(
                          'Status: ',
                          style: TextStyle(color: Colors.black54),
                        ),
                        Text(
                          item.status.replaceAll('_', ' ').toTitleCase(),
                          style: TextStyle(
                            color: _statusColor(item.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Text(
                          'Next Service: ',
                          style: TextStyle(color: Colors.black54),
                        ),
                        Text(
                          item.nextServiceDate ?? '—',
                          style: TextStyle(
                            color: _serviceColor(item.nextServiceDate),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleImage(String imagePath) {
    if (imagePath.startsWith('/')) {
      // File path - try to load as local file
      final file = File(imagePath);
      if (file.existsSync()) {
        return Image.file(file, width: 88, height: 56, fit: BoxFit.cover);
      } else {
        // File doesn't exist, return placeholder
        return Container(
          width: 88,
          height: 56,
          color: const Color(0xFFEDEFF4),
          child: const Icon(Icons.image_not_supported),
        );
      }
    } else {
      // Asset path
      return Image.asset(imagePath, width: 88, height: 56, fit: BoxFit.cover);
    }
  }
}

class _AddVehicleDialog extends StatefulWidget {
  final VehiclesProvider provider;
  const _AddVehicleDialog({required this.provider});

  @override
  State<_AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<_AddVehicleDialog> {
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _serviceCtrl = TextEditingController();
  String _selectedStatus = 'available';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _serviceCtrl.addListener(_formatServiceDate);
  }

  void _formatServiceDate() {
    String input = _serviceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (input.length > 8) {
      input = input.substring(0, 8);
    }

    String formatted = '';
    for (int i = 0; i < input.length; i++) {
      formatted += input[i];
      // Add hyphens after 2nd and 4th digits
      if ((i == 1 || i == 3) && i < input.length - 1) {
        formatted += '-';
      }
    }

    if (_serviceCtrl.text != formatted) {
      _serviceCtrl.value = _serviceCtrl.value.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  @override
  void dispose() {
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _plateCtrl.dispose();
    _yearCtrl.dispose();
    _serviceCtrl.removeListener(_formatServiceDate);
    _serviceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_brandCtrl.text.isEmpty || _plateCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Brand and Plate are required')),
      );
      return;
    }
    if (_serviceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service date is required (DD-MM-YYYY)')),
      );
      return;
    }
    // Validate and convert DD-MM-YYYY to YYYY-MM-DD
    String isoDateStr;
    try {
      final input = _serviceCtrl.text.trim();
      final regex = RegExp(r'^(\d{2})-(\d{2})-(\d{4})$');
      final match = regex.firstMatch(input);

      if (match == null) {
        throw Exception('Invalid format');
      }

      final day = int.parse(match.group(1)!);
      final month = int.parse(match.group(2)!);
      final year = int.parse(match.group(3)!);

      if (day < 1 || day > 31) {
        throw Exception('Day must be between 01 and 31');
      }
      if (month < 1 || month > 12) {
        throw Exception('Month must be between 01 and 12');
      }

      // Validate the date (this will throw if invalid, e.g., Feb 30)
      DateTime(year, month, day);
      isoDateStr =
          '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    } catch (e) {
      if (mounted) {
        String errorMsg = 'Invalid date format. Use DD-MM-YYYY';
        if (e.toString().contains('Day must')) {
          errorMsg = e.toString().replaceFirst('Exception: ', '');
        } else if (e.toString().contains('Month must')) {
          errorMsg = e.toString().replaceFirst('Exception: ', '');
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final vehicle = Vehicle(
        id: 0, // will be auto-generated
        brand: _brandCtrl.text.trim(),
        model: _modelCtrl.text.trim(),
        plate: _plateCtrl.text.trim().toUpperCase(),
        year: int.tryParse(_yearCtrl.text),
        status: _selectedStatus,
        imagePath: null,
        lat: null,
        lng: null,
        nextServiceDate: isoDateStr,
        colour: null,
        fuelType: null,
        mileageKm: null,
        seats: null,
      );

      await widget.provider.addVehicle(vehicle);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = 'Error: $e';
        if (e.toString().contains('UNIQUE constraint failed')) {
          errorMsg =
              'Plate number already exists. Please use a different plate.';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Vehicle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Brand
            TextField(
              controller: _brandCtrl,
              decoration: const InputDecoration(
                labelText: 'Brand *',
                hintText: 'e.g., Toyota',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            // Model
            TextField(
              controller: _modelCtrl,
              decoration: const InputDecoration(
                labelText: 'Model',
                hintText: 'e.g., Corolla',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            // Plate
            TextField(
              controller: _plateCtrl,
              decoration: const InputDecoration(
                labelText: 'Plate Number *',
                hintText: 'e.g., ABC-123',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            // Year
            TextField(
              controller: _yearCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Year',
                hintText: 'e.g., 2023',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            // Status
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'available', child: Text('Available')),
                DropdownMenuItem(value: 'in_use', child: Text('In Use')),
                DropdownMenuItem(
                  value: 'maintenance',
                  child: Text('Maintenance'),
                ),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _selectedStatus = v);
              },
            ),
            const SizedBox(height: 12),
            // Next Service Date
            TextField(
              controller: _serviceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Next Service Date *',
                hintText: 'DD-MM-YYYY',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          style: ElevatedButton.styleFrom(backgroundColor: kCyan),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add Vehicle'),
        ),
      ],
    );
  }
}
