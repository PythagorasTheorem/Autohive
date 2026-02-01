import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDb {
  AppDb._();
  static final AppDb instance = AppDb._();

  Database? _db;
  Database get db => _db!;

  // SIMPLE: copy assets/app.db only if it doesn't exist, then open it.
  Future<void> init() async {
    if (_db != null) return;

    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'app.db');

    // Copy once (first run only)
    if (!await File(dbPath).exists()) {
      final data = await rootBundle.load('assets/app.db');
      await File(dbPath).writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
    }

    _db = await openDatabase(dbPath);
    // Optional debug:
    // print('SQLite opened at: $dbPath');
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
