import 'package:ghastep/services/phonepe_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhonePePaymentManager {
  final PhonePeApiService apiService;
  final String clientId;
  final String clientSecret;
  final String clientVersion;

  PhonePePaymentManager({
    required this.apiService,
    required this.clientId,
    required this.clientSecret,
    required this.clientVersion,
  });

  static const String _tokenKey = 'phonepe_auth_token';
  static const String _expiryKey = 'phonepe_token_expiry';

  Future<String> _getValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final expiry = prefs.getInt(_expiryKey);

    // If token is valid, return it
    if (token != null && expiry != null && !_isTokenExpired(expiry)) {
      return token;
    }

    // Otherwise fetch new token
    final tokenData = await apiService.fetchAuthToken(
      clientId: clientId,
      clientSecret: clientSecret,
      clientVersion: clientVersion,
    );

    await prefs.setString(_tokenKey, tokenData['access_token']);
    await prefs.setInt(_expiryKey, tokenData['expires_at']);

    return tokenData['access_token'];
  }

  bool _isTokenExpired(int expiryTimestamp) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now >= expiryTimestamp;
  }

  Future<Map<String, dynamic>> createNewOrder({
    required String merchantOrderId,
    required int amount,
    int? expireAfter,
    Map<String, dynamic>? metaInfo,
    Map<String, dynamic>? paymentModeConfig,
  }) async {
    final token = await _getValidToken();
    return await apiService.createOrder(
      accessToken: token,
      merchantOrderId: merchantOrderId,
      amount: amount,
      expireAfter: expireAfter,
      metaInfo: metaInfo,
      paymentModeConfig: paymentModeConfig,
    );
  }
}
