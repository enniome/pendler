import 'package:flutter/services.dart';
import 'package:location/location.dart';

class LocationService {

  static Future<LocationData> getLocation() async {
    try {
      var location = new Location();
      return await location.getLocation();
    } on PlatformException catch (e) {
      if(e.code == 'PERMISSION_DENIED') {
        throw Exception('Permission denied! Activate your');
      } else {
        throw Exception(e.message);
      }
    }
  }

}