import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Dummy vehicle locations
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

  late GoogleMapController _mapController;
  MapType _currentMapType = MapType.normal;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initMarkers();
  }

  void _initMarkers() {
    for (var i = 0; i < _vehicles.length; i++) {
      final v = _vehicles[i];
      final id = 'vehicle_$i';
      _markers.add(
        Marker(
          markerId: MarkerId(id),
          position: LatLng(v['lat'] as double, v['lng'] as double),
          infoWindow: InfoWindow(
            title: v['name'] as String,
            snippet: v['status'] as String,
          ),
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _goToVehicle(int index) async {
    final v = _vehicles[index];
    final pos = LatLng(v['lat'] as double, v['lng'] as double);
    await _mapController.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: pos, zoom: 15)),
    );
  }

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
                  onPressed: () {},
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
            child: Container(
              color: const Color(0xFFE8F4F8),
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                mapType: _currentMapType,
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    _vehicles[0]['lat'] as double,
                    _vehicles[0]['lng'] as double,
                  ),
                  zoom: 13,
                ),
                markers: _markers,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
                compassEnabled: true,
              ),
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
                      return _vehicleStatusCard(v['name'], v['status'], i);
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

  Widget _mapMarker(String status, Color color) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(
            Icons.directions_car,
            size: 12,
            color: Colors.white,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            status,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _legendItem(String status, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(status, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _vehicleStatusCard(String name, String status, int index) {
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

    return InkWell(
      onTap: () => _goToVehicle(index),
      child: Card(
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
      ),
    );
  }
}
