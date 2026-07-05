import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  bool _isAuthenticated = false;
  String _userRole = 'client';

  bool get isAuthenticated => _isAuthenticated;
  String get userRole => _userRole;

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  void setUserRole(String role) {
    _userRole = role;
    notifyListeners();
  }
}
