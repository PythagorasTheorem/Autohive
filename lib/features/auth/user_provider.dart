import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _currentUser;

  Map<String, dynamic>? get currentUser => _currentUser;
  
  bool get isLoggedIn => _currentUser != null;
  
  String get username => _currentUser?['username'] ?? '';
  String get email => _currentUser?['email'] ?? '';
  String get name => _currentUser?['name'] ?? '';
  String get phone => _currentUser?['phone'] ?? '';
  int? get userId => _currentUser?['id'];

  void setUser(Map<String, dynamic> user) {
    _currentUser = user;
    notifyListeners();
  }

  void updateUser({
    String? name,
    String? email,
    String? phone,
  }) {
    if (_currentUser != null) {
      if (name != null) _currentUser!['name'] = name;
      if (email != null) _currentUser!['email'] = email;
      if (phone != null) _currentUser!['phone'] = phone;
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
