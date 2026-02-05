import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/theme.dart';
import '../vehicles/vehicle.dart';
import '../vehicles/vehicles_provider.dart';
import 'vehicle_detail_provider.dart';
import '../profile/profile_screen.dart';

class VehicleDetailScreen extends StatefulWidget {
  final int vehicleId;
  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<VehicleDetailProvider>().load(widget.vehicleId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<VehicleDetailProvider>();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: SafeArea(
          child: Container(
            color: kNavy,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Image.asset('assets/logo/autohive_logo.png', height: 32),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Vehicle Detail',
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
      body: p.loading
          ? const Center(child: CircularProgressIndicator())
          : (p.vehicle == null)
          ? const Center(child: Text('Vehicle not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _heroImage(p.vehicle!),
                  const SizedBox(height: 12),
                  _vehicleInfoCard(p.vehicle!),
                  const SizedBox(height: 12),
                  if (p.activeBooking != null)
                    _currentBookingCard(p.activeBooking!),
                  const SizedBox(height: 12),
                  _serviceHistoryCard(p.history),
                  const SizedBox(height: 16),
                  // Edit button
                  ElevatedButton(
                    onPressed: () =>
                        _showEditVehicleDialog(context, p.vehicle!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kCyan,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text(
                      'Edit Vehicle Details',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Delete button
                  ElevatedButton(
                    onPressed: () =>
                        _showDeleteConfirmation(context, p.vehicle!.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text(
                      'Delete Vehicle',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int vehicleId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: const Text(
          'Are you sure you want to delete this vehicle? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _deleteVehicle(vehicleId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVehicle(int vehicleId) async {
    try {
      await context.read<VehiclesProvider>().deleteVehicle(vehicleId);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting vehicle: $e')));
      }
    }
  }

  Widget _heroImage(Vehicle v) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 180,
        color: const Color(0xFFEDEFF4),
        alignment: Alignment.center,
        child: (v.imagePath != null && v.imagePath!.isNotEmpty)
            ? _buildImageFromPath(v.imagePath!)
            : const Icon(Icons.directions_car, size: 72, color: Colors.black45),
      ),
    );
  }

  Widget _buildImageFromPath(String imagePath) {
    try {
      // Check if it's a file path or an asset path
      if (imagePath.startsWith('/')) {
        // It's a file path
        final file = File(imagePath);
        if (file.existsSync()) {
          return Image.file(
            file,
            height: 180,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
              );
            },
          );
        } else {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, size: 60, color: Colors.orange),
                SizedBox(height: 8),
                Text('Image not found', style: TextStyle(color: Colors.orange)),
              ],
            ),
          );
        }
      } else {
        // It's an asset path
        return Image.asset(
          imagePath,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
            );
          },
        );
      }
    } catch (e) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 60, color: Colors.red),
            const SizedBox(height: 8),
            Text('Error loading image', style: TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ),
      );
    }
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
    IconData? icon,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        padding: const EdgeInsets.all(12),
        color: const Color(0xFFEDEDED),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) Icon(icon, size: 18),
                if (icon != null) const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget _vehicleInfoCard(Vehicle v) {
    Color statusColor(String s) {
      switch (s) {
        case 'available':
          return const Color(0xFF2E7D32);
        case 'in_use':
          return const Color(0xFFEF6C00);
        case 'maintenance':
          return const Color(0xFFC62828);
        default:
          return Colors.black87;
      }
    }

    return _sectionCard(
      title: 'Vehicle Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand & Model
          _infoRow(
            icon: Icons.directions_car,
            label: 'Model',
            value: '${v.brand} ${v.model}',
          ),
          Divider(height: 16, color: Colors.grey.shade300),
          
          // Status
          _infoRow(
            icon: Icons.info_outline,
            label: 'Status',
            value: v.status
                .replaceAll('_', ' ')
                .split(' ')
                .map((w) => w[0].toUpperCase() + w.substring(1))
                .join(' '),
            valueColor: statusColor(v.status),
          ),
          Divider(height: 16, color: Colors.grey.shade300),
          
          // Year & Plate
          Row(
            children: [
              Expanded(
                child: _infoRow(
                  icon: Icons.calendar_today,
                  label: 'Year',
                  value: (v.year ?? 0) == 0 ? '—' : v.year.toString(),
                  compact: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _infoRow(
                  icon: Icons.tag,
                  label: 'Plate',
                  value: v.plate,
                  compact: true,
                ),
              ),
            ],
          ),
          Divider(height: 16, color: Colors.grey.shade300),
          
          // Colour & Fuel Type
          Row(
            children: [
              Expanded(
                child: _infoRow(
                  icon: Icons.palette,
                  label: 'Colour',
                  value: v.colour ?? '—',
                  compact: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _infoRow(
                  icon: Icons.local_gas_station,
                  label: 'Fuel',
                  value: v.fuelType ?? '—',
                  compact: true,
                ),
              ),
            ],
          ),
          Divider(height: 16, color: Colors.grey.shade300),
          
          // Mileage & Seats
          Row(
            children: [
              Expanded(
                child: _infoRow(
                  icon: Icons.speed,
                  label: 'Mileage',
                  value: _formatKm(v.mileageKm),
                  compact: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _infoRow(
                  icon: Icons.event_seat,
                  label: 'Seats',
                  value: v.seats?.toString() ?? '—',
                  compact: true,
                ),
              ),
            ],
          ),
          Divider(height: 16, color: Colors.grey.shade300),
          
          // Service Date
          _infoRow(
            icon: Icons.build,
            label: 'Next Service',
            value: _formatServiceDate(v.nextServiceDate),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool compact = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: kCyan),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: compact ? 11 : 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? '—' : value,
                style: TextStyle(
                  fontSize: compact ? 13 : 15,
                  color: valueColor ?? Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatServiceDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '—';
    try {
      // Convert from YYYY-MM-DD to DD-MM-YYYY
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      }
    } catch (e) {
      return '—';
    }
    return dateStr;
  }

  String _formatKm(dynamic km) {
    if (km == null) return '—';
    final s = km.toString();
    final n = s.replaceAll(RegExp(r'[^0-9]'), '');
    final buf = StringBuffer();
    for (int i = 0; i < n.length; i++) {
      buf.write(n[i]);
      final left = n.length - 1 - i;
      if (left > 0 && left % 3 == 0) buf.write(' ');
    }
    return '${buf.toString()} km';
  }

  Widget _currentBookingCard(dynamic b) {
    String fmt(String iso) {
      // YYYY-MM-DD -> DD Mon YYYY
      final m = {
        '01': 'Jan',
        '02': 'Feb',
        '03': 'Mar',
        '04': 'Apr',
        '05': 'May',
        '06': 'Jun',
        '07': 'Jul',
        '08': 'Aug',
        '09': 'Sep',
        '10': 'Oct',
        '11': 'Nov',
        '12': 'Dec',
      };
      try {
        final y = iso.substring(0, 4),
            mo = iso.substring(5, 7),
            d = iso.substring(8, 10);
        return '$d ${m[mo]} $y';
      } catch (_) {
        return iso;
      }
    }

    return _sectionCard(
      title: 'Current Booking',
      icon: Icons.event,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status   ${b.status[0].toUpperCase()}${b.status.substring(1)}',
            style: const TextStyle(height: 1.5),
          ),
          Text(
            'Date     ${fmt(b.pickupDate)} – ${fmt(b.returnDate)}',
            style: const TextStyle(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _serviceHistoryCard(List history) {
    String fmt(String iso) {
      final m = {
        '01': 'Jan',
        '02': 'Feb',
        '03': 'Mar',
        '04': 'Apr',
        '05': 'May',
        '06': 'Jun',
        '07': 'Jul',
        '08': 'Aug',
        '09': 'Sep',
        '10': 'Oct',
        '11': 'Nov',
        '12': 'Dec',
      };
      try {
        final y = iso.substring(0, 4),
            mo = iso.substring(5, 7),
            d = iso.substring(8, 10);
        return '$d ${m[mo]} $y';
      } catch (_) {
        return iso;
      }
    }

    return _sectionCard(
      title: 'Service history',
      icon: Icons.build,
      child: history.isEmpty
          ? const Text('No service history available.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: history.map<Widget>((it) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(it.title)),
                      Text(fmt(it.date)),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  void _showEditVehicleDialog(BuildContext context, Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => _EditVehicleDialogState(vehicle: vehicle),
    );
  }
}

class _EditVehicleDialogState extends StatefulWidget {
  final Vehicle vehicle;

  const _EditVehicleDialogState({required this.vehicle});

  @override
  State<_EditVehicleDialogState> createState() =>
      _EditVehicleDialogStateState();
}

class _EditVehicleDialogStateState extends State<_EditVehicleDialogState> {
  late TextEditingController _colourController;
  late TextEditingController _fuelTypeController;
  late TextEditingController _mileageController;
  late TextEditingController _seatsController;
  String? _selectedImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _colourController = TextEditingController(
      text: widget.vehicle.colour ?? '',
    );
    _fuelTypeController = TextEditingController(
      text: widget.vehicle.fuelType ?? '',
    );
    _mileageController = TextEditingController(
      text: widget.vehicle.mileageKm?.toString() ?? '',
    );
    _seatsController = TextEditingController(
      text: widget.vehicle.seats?.toString() ?? '',
    );
    _selectedImagePath = widget.vehicle.imagePath;
  }

  @override
  void dispose() {
    _colourController.dispose();
    _fuelTypeController.dispose();
    _mileageController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  Widget _buildImageWidget(String imagePath) {
    try {
      if (imagePath.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
              SizedBox(height: 8),
              Text('No image', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        );
      }
      
      final file = File(imagePath);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 40),
                  const SizedBox(height: 8),
                  const Text('Error loading image', style: TextStyle(fontSize: 10)),
                ],
              );
            },
          ),
        );
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning, color: Colors.orange, size: 40),
            const SizedBox(height: 8),
            const Text('File not found', style: TextStyle(fontSize: 10, color: Colors.orange)),
          ],
        );
      }
    } catch (e) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 40),
          const SizedBox(height: 8),
          Text('Error: $e', style: const TextStyle(fontSize: 9)),
        ],
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // Check if file exists
        final file = File(image.path);
        if (await file.exists()) {
          // Copy image to app documents directory
          try {
            final appDir = await getApplicationDocumentsDirectory();
            final vehicleImagesDir = Directory('${appDir.path}/vehicle_images');
            
            // Create directory if it doesn't exist
            if (!await vehicleImagesDir.exists()) {
              await vehicleImagesDir.create(recursive: true);
            }
            
            // Generate unique filename
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final filename = 'vehicle_${widget.vehicle.id}_$timestamp.jpg';
            final savedImagePath = '${vehicleImagesDir.path}/$filename';
            
            // Copy file to app directory
            await file.copy(savedImagePath);
            
            setState(() {
              _selectedImagePath = savedImagePath;
            });
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Image selected successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error saving image: $e')),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error: Image file not found')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting image: $e')),
        );
      }
    }
  }

  void _updateVehicle() {
    try {
      final int? mileage = _mileageController.text.isEmpty
          ? null
          : int.parse(_mileageController.text);
      final int? seats = _seatsController.text.isEmpty
          ? null
          : int.parse(_seatsController.text);

      // Validate image path if selected
      String? validatedImagePath = _selectedImagePath;
      if (validatedImagePath != null && validatedImagePath.isNotEmpty) {
        final file = File(validatedImagePath);
        if (!file.existsSync()) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image file is no longer available. Please select the image again.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
      }

      final updatedVehicle = Vehicle(
        id: widget.vehicle.id,
        brand: widget.vehicle.brand,
        model: widget.vehicle.model,
        plate: widget.vehicle.plate,
        year: widget.vehicle.year,
        status: widget.vehicle.status,
        imagePath: validatedImagePath,
        lat: widget.vehicle.lat,
        lng: widget.vehicle.lng,
        nextServiceDate: widget.vehicle.nextServiceDate,
        colour: _colourController.text.isEmpty ? null : _colourController.text,
        fuelType: _fuelTypeController.text.isEmpty
            ? null
            : _fuelTypeController.text,
        mileageKm: mileage,
        seats: seats,
      );

      context.read<VehiclesProvider>().updateVehicle(updatedVehicle);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehicle updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating vehicle: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Vehicle Details'),
      content: SingleChildScrollView(
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            // Image section
            Center(
              child: Column(
                children: [
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFFEDEFF4),
                    ),
                    child: _selectedImagePath != null
                        ? _buildImageWidget(_selectedImagePath!)
                        : const Icon(
                            Icons.directions_car,
                            size: 60,
                            color: Colors.black45,
                          ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Select Image'),
                  ),
                ],
              ),
            ),
            // Colour field
            SizedBox(
              width: double.infinity,
              child: TextField(
                controller: _colourController,
                decoration: InputDecoration(
                  labelText: 'Colour',
                  hintText: 'e.g., Red, Blue',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            // Fuel Type field
            SizedBox(
              width: double.infinity,
              child: TextField(
                controller: _fuelTypeController,
                decoration: InputDecoration(
                  labelText: 'Fuel Type',
                  hintText: 'e.g., Petrol, Diesel',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            // Mileage field
            SizedBox(
              width: double.infinity,
              child: TextField(
                controller: _mileageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Mileage (km)',
                  hintText: '0',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            // Seats field
            SizedBox(
              width: double.infinity,
              child: TextField(
                controller: _seatsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Number of Seats',
                  hintText: '5',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updateVehicle,
          style: ElevatedButton.styleFrom(backgroundColor: kCyan),
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}
