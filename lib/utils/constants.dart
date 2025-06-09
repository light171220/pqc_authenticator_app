class Constants {
  static const String apiBaseUrl = 'https://your-backend-api.com/api/v1';
  
  static const String appName = 'PQC Authenticator';
  static const String appVersion = '1.0.0';
  
  static const int defaultTotpDigits = 6;
  static const int defaultTotpPeriod = 30;
  static const String defaultTotpAlgorithm = 'SHA1';
  
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration refreshInterval = Duration(seconds: 1);
  
  static const String jwtTokenKey = 'jwt_token';
  static const String userDataKey = 'user_data';
  
  static const List<String> supportedAlgorithms = ['SHA1', 'SHA256', 'SHA512'];
  static const List<int> supportedDigits = [6, 8];
  static const List<int> supportedPeriods = [15, 30, 60];
}