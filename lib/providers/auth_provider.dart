import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/binance_api_service.dart';

class AuthProvider extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  static const String _apiKeyKey = 'binance_api_key';
  static const String _secretKeyKey = 'binance_secret_key';
  static const String _isTestnetKey = 'binance_is_testnet';

  BinanceApiService? _apiService;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  bool _isTestnet = false;

  BinanceApiService? get apiService => _apiService;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isTestnet => _isTestnet;

  AuthProvider() {
    _loadStoredCredentials();
  }

  Future<void> _loadStoredCredentials() async {
    try {
      final apiKey = await _storage.read(key: _apiKeyKey);
      final secretKey = await _storage.read(key: _secretKeyKey);
      final testnetStr = await _storage.read(key: _isTestnetKey);
      
      if (apiKey != null && secretKey != null) {
        _isTestnet = testnetStr == 'true';
        _apiService = BinanceApiService(
          apiKey: apiKey,
          secretKey: secretKey,
          isTestnet: _isTestnet,
        );
        
        // Test the connection
        final isConnected = await _apiService!.testConnectivity();
        if (isConnected) {
          _isAuthenticated = true;
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'Failed to load stored credentials: $e';
      notifyListeners();
    }
  }

  Future<bool> login(String apiKey, String secretKey, {bool isTestnet = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final apiService = BinanceApiService(
        apiKey: apiKey,
        secretKey: secretKey,
        isTestnet: isTestnet,
      );

      // Test connectivity first
      final isConnected = await apiService.testConnectivity();
      if (!isConnected) {
        throw Exception('Cannot connect to Binance API. Please check your internet connection and try again. If using a corporate/school network, it may be blocking cryptocurrency sites.');
      }

      // Test authentication by getting account info
      await apiService.getAccountInfo();

      // If we get here, authentication was successful
      _apiService = apiService;
      _isAuthenticated = true;
      _isTestnet = isTestnet;

      // Store credentials securely
      try {
        await _storage.write(key: _apiKeyKey, value: apiKey);
        await _storage.write(key: _secretKeyKey, value: secretKey);
        await _storage.write(key: _isTestnetKey, value: isTestnet.toString());
      } catch (storageError) {
        // If secure storage fails, we can still continue with the session
        // The user will just need to re-enter credentials next time
        print('Warning: Could not save credentials securely: $storageError');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Clear stored credentials
      await _storage.delete(key: _apiKeyKey);
      await _storage.delete(key: _secretKeyKey);
      await _storage.delete(key: _isTestnetKey);

      _apiService = null;
      _isAuthenticated = false;
      _isTestnet = false;
      _error = null;
    } catch (e) {
      _error = 'Logout failed: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> validateCredentials() async {
    if (_apiService == null) return false;

    try {
      await _apiService!.getAccountInfo();
      return true;
    } catch (e) {
      _error = 'Credentials validation failed: $e';
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }
}