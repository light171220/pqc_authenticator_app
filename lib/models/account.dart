class Account {
  final String id;
  final String name;
  final String issuer;
  final String secret;
  final int digits;
  final int period;
  final String algorithm;

  Account({
    required this.id,
    required this.name,
    required this.issuer,
    required this.secret,
    this.digits = 6,
    this.period = 30,
    this.algorithm = 'SHA1',
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      issuer: json['issuer'] ?? '',
      secret: json['secret'] ?? '',
      digits: json['digits'] ?? 6,
      period: json['period'] ?? 30,
      algorithm: json['algorithm'] ?? 'SHA1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'issuer': issuer,
      'secret': secret,
      'digits': digits,
      'period': period,
      'algorithm': algorithm,
    };
  }

  factory Account.fromUri(String uri) {
    final parsedUri = Uri.parse(uri);
    final params = parsedUri.queryParameters;
    final pathSegments = parsedUri.path.split('/');
    
    return Account(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: pathSegments.length > 1 ? pathSegments[1] : params['name'] ?? '',
      issuer: params['issuer'] ?? pathSegments.first,
      secret: params['secret'] ?? '',
      digits: int.tryParse(params['digits'] ?? '6') ?? 6,
      period: int.tryParse(params['period'] ?? '30') ?? 30,
      algorithm: params['algorithm'] ?? 'SHA1',
    );
  }
}