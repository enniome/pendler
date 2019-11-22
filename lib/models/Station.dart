import 'Coordinate.dart';

class Station {
  final String id;
  final String name;
  final String score;
  final Coordinate coordinate;
  final int distance;

  Station({this.id, this.name, this.score, this.coordinate, this.distance});

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'],
      name: json['name'],
      score: json['score'],
      coordinate: Coordinate.fromJson(json['coordinate']),
      distance: json['distance']
    );
  }
}