import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:pendler/models/Stationboard.dart';
import 'package:pendler/services/LocationService.dart';
import 'package:pendler/services/TransportService.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

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

  String selectedStationId = 'Tippe auf eine Haltestelle';
  Station selectedStation = new Station();

  List<Stationboard> stationboards = new List<Stationboard>();

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
      theme: ThemeData(primarySwatch: Colors.red),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Pendler'),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              onPressed: reassemble,
            )
          ],
        ),
        body: SlidingUpPanel(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            panel: panelContent(),
            body: Container(
              child: FutureBuilder(
                  future: Future.wait([location, stations]),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        child: FlutterMap(
                          options: MapOptions(
                            center: LatLng((snapshot.data[0] as LocationData).latitude,
                                (snapshot.data[0] as LocationData).longitude),
                            zoom: 14,
                          ),
                          layers: [
                            TileLayerOptions(
                              urlTemplate: 'https://tile.osm.ch/switzerland/{z}/{x}/{y}.png',
                              tileProvider: CachedNetworkTileProvider(),
                            ),
                            MarkerLayerOptions(markers: [
                              Marker(
                                width: 80.0,
                                height: 80.0,
                                point: LatLng((snapshot.data[0] as LocationData).latitude,
                                    (snapshot.data[0] as LocationData).longitude),
                                builder: (ctx) => Container(
                                  child: Icon(
                                    Icons.my_location,
                                    color: Colors.blue,
                                    size: 30,
                                  ),
                                ),
                              ),
                              ...createMarker((snapshot.data[1] as List<Station>))
                            ])
                          ],
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }
                    return CircularProgressIndicator();
                  }),
            )),
      ),
    );
  }

  Widget panelContent() {
    return Container(
      child: Column(
        children: [
          Container(
            child: Text(
              'Abfahrtszeiten ab: ',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            alignment: Alignment.topLeft,
            padding: EdgeInsets.fromLTRB(20, 20, 0, 5),
          ),
          Row(
            children: <Widget>[
              Container(
                child: Icon(resolveTransportIcon(selectedStation.icon)),
                alignment: Alignment.topLeft,
                padding: EdgeInsets.fromLTRB(20, 0, 10, 0),
              ),
              Container(
                child: Flexible(
                  child: AutoSizeText(
                    ((() {
                      if (selectedStation.id != null) {
                        return selectedStation.name;
                      }
                      return 'Wähle Haltestelle!';
                    })()),
                    style: TextStyle(fontWeight: FontWeight.w200, fontSize: 30),
                    maxLines: 1,
                  ),
                ),
              )
            ],
          ),
          handleListView(),
        ],
      ),
    );
  }

  Widget handleListView() {
    return Container(
      child: Expanded(
        child: ListView.builder(
          itemCount: stationboards.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(title: Text(stationboards[index].name));
          },
        ),
      ),
    );
  }

  void setStationboards(String id) async {
    List<Stationboard> connections = await TransportService.fetchConnectionsFrom(id);
    setState(() {
      stationboards = connections;
    });
  }

  List<Marker> createMarker(List<Station> stations) {
    List<Marker> markers = new List<Marker>();
    for (Station station in stations) {
      if (station.coordinate.x != null && station.coordinate.y != null) {
        markers.add(new Marker(
          width: 30.0,
          height: 30.0,
          point: LatLng(station.coordinate.x, station.coordinate.y),
          builder: (ctx) => Container(
            child: RawMaterialButton(
              shape: new CircleBorder(),
              child: Icon(resolveTransportIcon(station.icon), color: Colors.white, size: 20),
              onPressed: () {
                setState(() {
                  this.selectedStationId = station.id;
                  this.selectedStation = station;
                  setStationboards(station.id);
                });
              },
              fillColor: ((() {
                if (selectedStationId == station.id) {
                  return Colors.blue;
                }
                return Colors.red;
              })()),
            ),
          ),
        ));
      }
    }

    return markers;
  }

  IconData resolveTransportIcon(String icon) {
    if (icon == null) {
      return Icons.help;
    } else {
      switch (icon) {
        case 'train':
          return Icons.directions_railway;
          break;
        case 'bus':
          return Icons.directions_bus;
          break;
        case 'tram':
          return Icons.tram;
          break;
        default:
          return Icons.transit_enterexit;
      }
    }
  }
}
