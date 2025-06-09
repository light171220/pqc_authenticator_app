class TotpCode {
  final String accountId;
  final String code;
  final int remainingSeconds;
  final DateTime generatedAt;

  TotpCode({
    required this.accountId,
    required this.code,
    required this.remainingSeconds,
    required this.generatedAt,
  });

  bool get isExpired => remainingSeconds <= 0;
  
  double get progress => remainingSeconds / 30.0;
}