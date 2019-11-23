import 'Stop.dart';

class Stationboard {
  final Stop stop;
  final String name;
  final String to;
  final String number;

  Stationboard({this.stop, this.name, this.to, this.number});

  factory Stationboard.fromJson(Map<String, dynamic> json) {
    return Stationboard(
      stop: Stop.fromJson(json['stop']),
      name: json['name'],
      to: json['to'],
      number: json['number']
    );
  }
}