import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme.dart';
import '../profile/profile_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  
  // Mauritius center coordinates
  static const LatLng _mauritiusCenter = LatLng(-20.3480, 57.5522);
  
  // Dummy vehicle locations (within Mauritius)
  final List<Map<String, dynamic>> _vehicles = [
    {
      'name': 'BMW (Plate: 1234 XX 19)',
      'status': 'In Use',
      'lat': -20.1609,
      'lng': 57.5012,
    },
    {
      'name': 'AUDI (Plate: 5678 XY 24)',
      'status': 'Available',
      'lat': -20.1650,
      'lng': 57.5050,
    },
    {
      'name': 'TOYOTA (Plate: 9876 YZ 22)',
      'status': 'Maintenance',
      'lat': -20.1580,
      'lng': 57.4980,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  void _initializeMarkers() {
    _markers = _vehicles.asMap().entries.map((entry) {
      final idx = entry.key;
      final vehicle = entry.value;
      return Marker(
        markerId: MarkerId('vehicle_$idx'),
        position: LatLng(vehicle['lat'], vehicle['lng']),
        infoWindow: InfoWindow(
          title: vehicle['name'],
          snippet: 'Status: ${vehicle['status']}',
        ),
        icon: _getMarkerIcon(vehicle['status']),
      );
    }).toSet();
  }

  BitmapDescriptor _getMarkerIcon(String status) {
    switch (status) {
      case 'Available':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'In Use':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case 'Maintenance':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    'Map',
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
      body: Column(
        children: [
          // Interactive Google Map
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: const CameraPosition(
                target: _mauritiusCenter,
                zoom: 9.5,
              ),
              markers: _markers,
              myLocationButtonEnabled: false,
              myLocationEnabled: false,
              zoomControlsEnabled: true,
              compassEnabled: true,
            ),
          ),
          // Vehicle list
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vehicles Status',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _vehicles.length,
                    itemBuilder: (_, i) {
                      final v = _vehicles[i];
                      return _vehicleStatusCard(v['name'], v['status']);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vehicleStatusCard(String name, String status) {
    Color statusColor(String s) {
      switch (s) {
        case 'Available':
          return Colors.green;
        case 'In Use':
          return Colors.orange;
        case 'Maintenance':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    return Card(
      margin: const EdgeInsets.only(right: 8),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor(status).withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 11,
                  color: statusColor(status),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
