import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = true; // Start with loading true
  bool _isAuthorized = false;
  bool _disposed = false;
  bool _isInitialized = false;
  Map<String, dynamic>? _organization;
  List<Map<String, dynamic>> _userRoles = [];
  Map<String, dynamic>? _primaryUserRole;
  Map<String, int> _deviceStats = {'total': 0, 'active': 0, 'inactive': 0};

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isAuthorized => _isAuthorized;
  bool get isInitialized => _isInitialized;
  Map<String, dynamic>? get organization => _organization;
  List<Map<String, dynamic>> get userRoles => _userRoles;
  Map<String, dynamic>? get primaryUserRole => _primaryUserRole;
  Map<String, int> get deviceStats => _deviceStats;
  
  String? get userType => _primaryUserRole?['user_type'];
  dynamic get userDeviceAccess => _primaryUserRole?['devices'];
  bool get hasManagerRole => userType == 'manager' || userType == 'admin';
  bool get hasAllDeviceAccess => userDeviceAccess == "all";

  AuthProvider() {
    _initialize();
  }

  void _initialize() async {
    _user = _authService.currentUser;
    await _checkUserAuthorization();
    _isInitialized = true;
    
    _authService.authStateChanges.listen((AuthState data) async {
      _user = data.session?.user;
      await _checkUserAuthorization();
    });
  }

  Future<void> _checkUserAuthorization() async {
    if (_disposed) return;
    
    try {
      if (_user?.id != null) {
        _isAuthorized = await _authService.checkUserAuthorization(_user!.id);
        
        if (_isAuthorized) {
          await _loadUserRoleData(_user!.id);
        } else {
          _userRoles = [];
          _primaryUserRole = null;
          _organization = null;
          _deviceStats = {'total': 0, 'active': 0, 'inactive': 0};
        }
      } else {
        _isAuthorized = false;
        _userRoles = [];
        _primaryUserRole = null;
        _organization = null;
        _deviceStats = {'total': 0, 'active': 0, 'inactive': 0};
      }
      
      _isLoading = false;
      
      if (!_disposed) {
        notifyListeners();
      }
    } catch (e) {
      // Handle error silently to prevent crashes
      if (!_disposed) {
        _isAuthorized = false;
        _userRoles = [];
        _primaryUserRole = null;
        _organization = null;
        _deviceStats = {'total': 0, 'active': 0, 'inactive': 0};
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _loadUserRoleData(String userId) async {
    _userRoles = await _authService.getUserRoles(userId);
    _primaryUserRole = await _authService.getPrimaryUserRole(userId);
    
    if (_primaryUserRole != null) {
      _organization = _primaryUserRole!['organization'];
      _deviceStats = await _authService.getDeviceStatisticsForUser(userId);
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      _setLoading(true);
      final response = await _authService.signUp(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        // User authentication successful - authorization check will happen in auth state change
        return null; // Success
      } else {
        _setLoading(false);
        return 'Sign up failed';
      }
    } catch (e) {
      _setLoading(false);
      return e.toString();
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      _setLoading(true);
      final response = await _authService.signIn(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        // User authentication successful - authorization check will happen in auth state change
        return null; // Success
      } else {
        _setLoading(false);
        return 'Sign in failed';
      }
    } catch (e) {
      _setLoading(false);
      return e.toString();
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _isAuthorized = false;
      _userRoles = [];
      _primaryUserRole = null;
      _organization = null;
      _deviceStats = {'total': 0, 'active': 0, 'inactive': 0};
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshDeviceStats() async {
    if (_user?.id != null) {
      _deviceStats = await _authService.getDeviceStatisticsForUser(_user!.id);
      notifyListeners();
    }
  }

  Future<void> recheckAuthorization() async {
    await _checkUserAuthorization();
  }

  Future<String?> resetPassword(String email) async {
    try {
      _setLoading(true);
      await _authService.resetPassword(email);
      return null; // Success
    } catch (e) {
      return e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    if (!_disposed) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
