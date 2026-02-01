import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import 'maintenance_form_provider.dart';
import '../profile/profile_screen.dart';

class MaintenanceFormScreen extends StatefulWidget {
  const MaintenanceFormScreen({super.key});

  @override
  State<MaintenanceFormScreen> createState() => _MaintenanceFormScreenState();
}

class _MaintenanceFormScreenState extends State<MaintenanceFormScreen> {
  final _issueCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final p = context.read<MaintenanceFormProvider>();
      p.reset(); // ✅ Clear any previous form values
      p.loadVehicles(); // ✅ Load the available vehicles
    });
  }

  @override
  void dispose() {
    _issueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<MaintenanceFormProvider>();

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
                    'Report Maintenance',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _Section(title: 'Vehicle'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEDEFF4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: p.vehicleId,
                  hint: const Text('Select vehicle'),
                  items: p.vehicles
                      .map(
                        (m) => DropdownMenuItem<int>(
                          value: m['id'] as int,
                          child: Text(m['label'] as String),
                        ),
                      )
                      .toList(),
                  onChanged: p.setVehicle,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _Section(title: 'Issue Description'),
            TextField(
              controller: _issueCtrl,
              onChanged: p.setIssue,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe the issue...',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color(0xFFEDEFF4),
              ),
            ),
            const SizedBox(height: 16),
            _Section(title: 'Photo (optional)'),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: p.pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Attach from gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kCyan,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    p.photoPath == null ? 'No file selected' : p.photoPath!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: p.valid && !p.loading
                    ? () async {
                        await p.submit();
                        p.reset(); // ✅ Clear form after submitting
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Maintenance request submitted'),
                            ),
                          );
                          Navigator.pop(context, true); // return success
                        }
                      }
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: kCyan,
                  foregroundColor: Colors.white,
                ),
                child: p.loading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Submit'),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  const _Section({required this.title});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
