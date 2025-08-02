import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  static SharedPreferences? _prefs;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> login(
    String userType,
    String userName, {
    String? password,
  }) async {
    if (userType == 'Anesthesia' && password != '123') {
      return false;
    }

    await _prefs?.setString('userType', userType);
    await _prefs?.setString('userName', userName);
    return true;
  }

  Future<void> logout() async {
    await _prefs?.clear();
  }

  String? get userType => _prefs?.getString('userType');
  String? get userName => _prefs?.getString('userName');
  bool get isLoggedIn => userType != null;
}
