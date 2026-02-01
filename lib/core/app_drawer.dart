import 'package:flutter/material.dart';
import '../features/vehicles/vehicles_screen.dart';
import '../features/maintenance/maintenance_screen.dart';
import 'theme.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/booking/booking_form_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: kNavy),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.directions_car, color: Colors.white, size: 36),
                SizedBox(height: 8),
                Text(
                  'AutoHive',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _drawerItem(
            context,
            Icons.directions_car,
            'Vehicle Inventory',
            const VehiclesScreen(),
          ),
          _drawerItem(
            context,
            Icons.build_circle,
            'Maintenance',
            const MaintenanceScreen(),
          ),
          _drawerItem(
            context,
            Icons.dashboard,
            'Dashboard',
            const DashboardScreen(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('New Booking'),
            onTap: () {
              Navigator.pop(context); // close the drawer
              Navigator.push(
                // <-- use push (NOT replacement) for a form
                context,
                MaterialPageRoute(builder: (_) => const BookingFormScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String label,
    Widget screen,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.pop(context); // close drawer
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
    );
  }
}
