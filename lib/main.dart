import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:pendler/services/LocationService.dart';
import 'package:pendler/services/TransportService.dart';

import 'models/Station.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<List<Station>> stations;
  Future<LocationData> location;

  @override
  void initState() {
    super.initState();

    location = LocationService.getLocation();
    stations = TransportService.fetchStations(location);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pendler',
      theme: ThemeData(primarySwatch: Colors.amber),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Pendler'),
        ),
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FutureBuilder (
                    future: Future.wait([location, stations]),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Flexible(
                          child: FlutterMap(
                            options: MapOptions(
                              center: LatLng((snapshot.data[0] as LocationData).latitude, (snapshot.data[0] as LocationData).longitude),
                              zoom: 14,
                            ),
                            layers: [
                              TileLayerOptions(
                                urlTemplate:
                                'https://tile.osm.ch/switzerland/{z}/{x}/{y}.png',
                                tileProvider: CachedNetworkTileProvider(),
                              ),
                              MarkerLayerOptions(
                                markers: [
                                  Marker(
                                    width: 80.0,
                                    height: 80.0,
                                    point: LatLng(
                                        (snapshot.data[0] as LocationData).latitude,
                                        (snapshot.data[0] as LocationData).longitude
                                    ),
                                    builder: (ctx) => Container(
                                      child: Icon (
                                        Icons.my_location,
                                        color: Colors.blue,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                  ...createMarker((snapshot.data[1] as List<Station>))
                                ]
                              )
                            ],
                          )

                        );
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }
                      return CircularProgressIndicator();
                    }),
              ],
            )),
      ),
    );
  }

  List<Marker> createMarker(List<Station> stations) {
    List<Marker> markers = new List<Marker>();
    for (Station station in stations) {
      if (station.coordinate.x != null && station.coordinate.y != null) {
        markers.add(new Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(
              station.coordinate.x,
              station.coordinate.y
          ),
          builder: (ctx) => Container(
            child: Icon (
              Icons.train,
              color: Colors.blue,
              size: 30,
            ),
          ),
        ));
      }
    }

    return markers;
  }

}
