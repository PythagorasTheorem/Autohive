import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../core/theme.dart';
import 'maintenance_provider.dart';
import 'maintenance_item.dart';
import 'package:autohive/core/app_drawer.dart';
import 'maintenance_form_screen.dart';
import '../profile/profile_screen.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});
  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MaintenanceProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<MaintenanceProvider>();

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
                    'Maintenance',
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
        onPressed: () async {
          final ok = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MaintenanceFormScreen()),
          );
          if (ok == true && context.mounted) {
            // Refresh list (pending tab will show the new request)
            await context.read<MaintenanceProvider>().refresh();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: p.refresh,
        child: Column(
          children: [
            // Tabs with count badges
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _tabBadge(
                      label: 'Pending Requests',
                      count: p.pendingCount,
                      selected: p.tab == 'pending',
                      onTap: () => p.setTab('pending'),
                    ),
                    const SizedBox(width: 8),
                    _tabBadge(
                      label: 'Completed Requests',
                      count: p.completedCount,
                      selected: p.tab == 'completed',
                      onTap: () => p.setTab('completed'),
                    ),
                  ],
                ),
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEFF4),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _search,
                  onChanged: p.setSearch,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search),
                    hintText: 'Search maintenance...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            // List
            Expanded(
              child: p.visible.isEmpty
                  ? const Center(child: Text('No requests found'))
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: p.visible.length,
                      itemBuilder: (_, i) => _MaintenanceCard(
                        item: p.visible[i],
                        showCompleteIcon: p.tab == 'pending',
                        onComplete: (reqId, vehId) => context
                            .read<MaintenanceProvider>()
                            .markCompleted(requestId: reqId, vehicleId: vehId),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabBadge({
    required String label,
    required int count,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: kCyan,
      backgroundColor: const Color(0xFFEDEFF4),
      labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: selected ? Colors.white : Colors.black87),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: selected ? Colors.white.withOpacity(.2) : Colors.black12,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MaintenanceCard extends StatelessWidget {
  final MaintenanceItem item;
  final bool showCompleteIcon; // only on pending tab
  final void Function(int requestId, int vehicleId) onComplete;

  const _MaintenanceCard({
    required this.item,
    required this.showCompleteIcon,
    required this.onComplete,
  });

  String _since(String iso) {
    try {
      final y = iso.substring(0, 4);
      final m = iso.substring(5, 7);
      final d = iso.substring(8, 10);
      return '(Since $d/$m/$y)';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: (item.imagePath != null && item.imagePath!.isNotEmpty)
                  ? _buildMaintenanceImage(item.imagePath!)
                  : Container(
                      width: 100,
                      height: 60,
                      color: const Color(0xFFEDEFF4),
                      child: const Icon(Icons.directions_car),
                    ),
            ),
            const SizedBox(width: 12),
            // Texts (no plate per your request)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.brand} ${item.model}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        _since(item.createdAt),
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(item.issue),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Complete action (only on pending)
            if (showCompleteIcon)
              IconButton(
                icon: const Icon(Icons.check_circle, size: 28),
                color: const Color(0xFF2E7D32),
                tooltip: 'Mark as completed',
                onPressed: () => onComplete(item.id, item.vehicleId),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceImage(String imagePath) {
    if (imagePath.startsWith('/')) {
      // File path - try to load as local file
      final file = File(imagePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: 100,
          height: 60,
          fit: BoxFit.cover,
        );
      } else {
        // File doesn't exist, return placeholder
        return Container(
          width: 100,
          height: 60,
          color: const Color(0xFFEDEFF4),
          child: const Icon(Icons.image_not_supported),
        );
      }
    } else {
      // Asset path
      return Image.asset(
        imagePath,
        width: 100,
        height: 60,
        fit: BoxFit.cover,
      );
    }
  }
}
