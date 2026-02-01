import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import 'core/db.dart';
import 'core/theme.dart';

// Auth
import 'features/auth/login_screen.dart';
import 'features/auth/user_provider.dart';

// Vehicles (list)
import 'features/vehicles/vehicles_repository.dart';
import 'features/vehicles/vehicles_provider.dart';

// Vehicle detail
import 'features/vehicle_detail/vehicle_detail_provider.dart';

//maintenace list
import 'features/maintenance/maintenance_provider.dart';

//maintenace form
import 'features/maintenance/maintenance_form_provider.dart';

//dashboard
import 'features/dashboard/dashboard_provider.dart';

//booking
import 'features/booking/booking_form_provider.dart';

import 'features/dashboard/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Copy assets/app.db → documents directory if not already present
  //await AppDb.instance.reset();
  await AppDb.instance.init(); // <-- simple init

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = VehiclesRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => VehiclesProvider(repo)),
        ChangeNotifierProvider(create: (_) => VehicleDetailProvider(repo)),
        ChangeNotifierProvider(create: (_) => MaintenanceProvider()),
        ChangeNotifierProvider(create: (_) => MaintenanceFormProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => BookingFormProvider()),
      ],
      child: MaterialApp(
        title: 'AutoHive',
        debugShowCheckedModeBanner: false,
        theme: appTheme(),
        home: const LoginScreen(),
      ),
    );
  }
}
