import 'dart:convert';

import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:pendler/models/Station.dart';

class TransportService {
  static Future<List<Station>> fetchStations(Future<LocationData> locationDataFuture) async {

    LocationData locationData = await locationDataFuture;

    final response = await get('http://transport.opendata.ch/v1/locations?x=${locationData.longitude}&y=${locationData.latitude}');

    if (response.statusCode == 200) {
      Map map = json.decode(response.body);
      Iterable stationsList = map['stations'];

      return stationsList.map((model) => Station.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load stations.');
    }
  }
}
