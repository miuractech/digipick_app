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
  Map<String, int> _deviceStats = {'total': 0, 'active': 0, 'inactive': 0};

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isAuthorized => _isAuthorized;
  bool get isInitialized => _isInitialized;
  Map<String, dynamic>? get organization => _organization;
  Map<String, int> get deviceStats => _deviceStats;

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
      if (_user?.email != null) {
        _isAuthorized = await _authService.checkOrganizationEmail(_user!.email!);
        
        if (_isAuthorized) {
          await _loadOrganizationData(_user!.email!);
        } else {
          _organization = null;
          _deviceStats = {'total': 0, 'active': 0, 'inactive': 0};
        }
      } else {
        _isAuthorized = false;
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
        _organization = null;
        _deviceStats = {'total': 0, 'active': 0, 'inactive': 0};
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _loadOrganizationData(String email) async {
    _organization = await _authService.getOrganizationByEmail(email);
    if (_organization != null) {
      _deviceStats = await _authService.getDeviceStatistics(_organization!['id']);
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
      _organization = null;
      _deviceStats = {'total': 0, 'active': 0, 'inactive': 0};
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshDeviceStats() async {
    if (_organization != null) {
      _deviceStats = await _authService.getDeviceStatistics(_organization!['id']);
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
