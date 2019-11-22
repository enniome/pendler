 class Coordinate {
   final String type;
   final double x;
   final double y;

   Coordinate({this.type, this.x, this.y});

   factory Coordinate.fromJson(Map<String, dynamic> json) {
     return Coordinate(
       type: json['type'],
       x: json['x'],
       y: json['y'],
     );
   }
 }