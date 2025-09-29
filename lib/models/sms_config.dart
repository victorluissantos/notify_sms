class SMSConfig {
  final String url;
  final String bearerToken;
  final String user;
  final String password;
  final int intervalSeconds;

  SMSConfig({
    required this.url,
    required this.bearerToken,
    required this.user,
    required this.password,
    required this.intervalSeconds,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'bearerToken': bearerToken,
      'user': user,
      'password': password,
      'intervalSeconds': intervalSeconds,
    };
  }

  factory SMSConfig.fromJson(Map<String, dynamic> json) {
    return SMSConfig(
      url: json['url'] ?? '',
      bearerToken: json['bearerToken'] ?? '',
      user: json['user'] ?? '',
      password: json['password'] ?? '',
      intervalSeconds: json['intervalSeconds'] ?? 10,
    );
  }

  SMSConfig copyWith({
    String? url,
    String? bearerToken,
    String? user,
    String? password,
    int? intervalSeconds,
  }) {
    return SMSConfig(
      url: url ?? this.url,
      bearerToken: bearerToken ?? this.bearerToken,
      user: user ?? this.user,
      password: password ?? this.password,
      intervalSeconds: intervalSeconds ?? this.intervalSeconds,
    );
  }
}
