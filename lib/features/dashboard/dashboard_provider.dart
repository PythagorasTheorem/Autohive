import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/db.dart';

class DashboardProvider extends ChangeNotifier {
  final Database _db = AppDb.instance.db;

  int available = 0;
  int inUse = 0;
  int maintenance = 0;
  bool loading = false;

  Future<void> load() async {
    loading = true; notifyListeners();

    final rows = await _db.rawQuery("""
      SELECT
        SUM(CASE WHEN status='available' THEN 1 ELSE 0 END) AS available,
        SUM(CASE WHEN status='in_use' THEN 1 ELSE 0 END)    AS in_use,
        SUM(CASE WHEN status='maintenance' THEN 1 ELSE 0 END) AS maintenance
      FROM vehicles
    """);

    if (rows.isNotEmpty) {
      final r = rows.first;
      available   = (r['available'] as int?) ?? 0;
      inUse       = (r['in_use'] as int?) ?? 0;
      maintenance = (r['maintenance'] as int?) ?? 0;
    } else {
      available = inUse = maintenance = 0;
    }

    loading = false; notifyListeners();
  }

  Future<void> refresh() => load();

  int get total => available + inUse + maintenance;
}
