import 'package:sqflite/sqflite.dart';
import 'db.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() {
    return _instance;
  }
  
  AuthService._internal();
  
  late Database _db;
  
  Future<void> init() async {
    _db = AppDb.instance.db;
    // Ensure users table exists
    await _ensureUserTableExists();
  }
  
  Future<void> _ensureUserTableExists() async {
    try {
      // Check if users table exists by querying it
      await _db.query('users', limit: 1);
    } catch (e) {
      // Table doesn't exist, create it
      await _db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE NOT NULL,
          email TEXT UNIQUE NOT NULL,
          password TEXT NOT NULL,
          name TEXT NOT NULL,
          phone TEXT NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');
    }
  }
  
  // Register a new user
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final normalizedUsername = username.trim().toLowerCase();
      final normalizedEmail = email.trim().toLowerCase();
      
      // Check if username already exists
      final existingUser = await _db.query(
        'users',
        where: 'LOWER(username) = ?',
        whereArgs: [normalizedUsername],
      );
      
      if (existingUser.isNotEmpty) {
        throw Exception('Username already exists');
      }
      
      // Check if email already exists
      final existingEmail = await _db.query(
        'users',
        where: 'LOWER(email) = ?',
        whereArgs: [normalizedEmail],
      );
      
      if (existingEmail.isNotEmpty) {
        throw Exception('Email already registered');
      }
      
      // Insert new user
      await _db.insert(
        'users',
        {
          'username': normalizedUsername,
          'email': normalizedEmail,
          'password': password.trim(), // In production, hash this!
          'name': name.trim(),
          'phone': phone.trim(),
        },
      );
      
      return true;
    } catch (e) {
      rethrow;
    }
  }
  
  // Login user
  Future<Map<String, dynamic>?> login({
    required String username,
    required String password,
  }) async {
    try {
      final normalizedUsername = username.trim().toLowerCase();
      final trimmedPassword = password.trim();
      
      final users = await _db.query(
        'users',
        where: 'LOWER(username) = ? AND password = ?',
        whereArgs: [normalizedUsername, trimmedPassword],
      );
      
      if (users.isEmpty) {
        return null; // Invalid credentials
      }
      
      return users.first;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get user by username
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    try {
      final normalizedUsername = username.trim().toLowerCase();
      final users = await _db.query(
        'users',
        where: 'LOWER(username) = ?',
        whereArgs: [normalizedUsername],
      );
      
      return users.isNotEmpty ? users.first : null;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      return await _db.query('users');
    } catch (e) {
      rethrow;
    }
  }
  
  // Delete user (for admin purposes)
  Future<int> deleteUser(String username) async {
    try {
      final normalizedUsername = username.trim().toLowerCase();
      return await _db.delete(
        'users',
        where: 'LOWER(username) = ?',
        whereArgs: [normalizedUsername],
      );
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required int userId,
    String? name,
    String? email,
    String? phone,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (phone != null) updateData['phone'] = phone;
      
      if (updateData.isEmpty) return;
      
      await _db.update(
        'users',
        updateData,
        where: 'id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      rethrow;
    }
  }

  // Update user password
  Future<void> updatePassword({
    required int userId,
    required String newPassword,
  }) async {
    try {
      await _db.update(
        'users',
        {'password': newPassword},
        where: 'id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      rethrow;
    }
  }
}
