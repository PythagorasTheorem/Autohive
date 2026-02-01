import 'package:flutter/foundation.dart';
import 'vehicle.dart';
import 'vehicles_repository.dart';

class VehiclesProvider extends ChangeNotifier {
  final VehiclesRepository _repo;
  VehiclesProvider(this._repo);

  List<Vehicle> _all = [];
  String _filter = 'all'; // all | available | in_use | maintenance
  String _query = '';

  List<Vehicle> get visible {
    Iterable<Vehicle> v = _all;
    if (_filter != 'all') {
      v = v.where((e) => e.status == _filter);
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      v = v.where(
        (e) =>
            e.brand.toLowerCase().contains(q) ||
            e.model.toLowerCase().contains(q) ||
            e.plate.toLowerCase().contains(q),
      );
    }
    return v.toList();
  }

  String get filter => _filter;
  String get query => _query;

  Future<void> load() async {
    _all = await _repo.getAll();
    notifyListeners();
  }

  void setFilter(String f) {
    _filter = f;
    notifyListeners();
  }

  Future<void> setSearch(String q) async {
    _query = q;
    notifyListeners();
  }

  Future<void> refresh() => load();

  Future<void> addVehicle(Vehicle vehicle) async {
    await _repo.insert(vehicle);
    await load();
  }

  Future<void> deleteVehicle(int id) async {
    await _repo.delete(id);
    await load();
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    await _repo.update(vehicle);
    await load();
  }
}
