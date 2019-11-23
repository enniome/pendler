class Stop {
  final String departure;
  final String platform;

  Stop({this.departure, this.platform});

  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      departure: json['departure'],
      platform: json['platform']
    );
  }
}