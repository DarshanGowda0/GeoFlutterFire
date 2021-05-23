import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'streambuilder_test.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    title: 'Geo Flutter Fire example',
    home: MyApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Completer<GoogleMapController> _mapController = Completer();
  TextEditingController _latitudeController = TextEditingController();
  TextEditingController _longitudeController = TextEditingController();

  // firestore init
  final _firestore = FirebaseFirestore.instance;
  late Geoflutterfire geo;
  late Stream<List<DocumentSnapshot>> stream;
  var radius = BehaviorSubject.seeded(100.0);

  //Map markers
  List<Marker> markers = [];

  @override
  void initState() {
    super.initState();
    geo = Geoflutterfire();
    GeoFirePoint center = geo.point(latitude: 12.960632, longitude: 77.641603);
    stream = radius.switchMap((rad) {
      var collectionReference = _firestore.collection('locations');
      //          .where('name', isEqualTo: 'darshan');
      return geo.collection(collectionRef: collectionReference).within(center: center, radius: rad, field: 'position');

      /** Example to specify nested object
          var collectionReference = _firestore.collection('nestedLocations');
          //          .where('name', isEqualTo: 'darshan');
          return geo.collection(collectionRef: collectionReference).within(
          center: center, radius: rad, field: 'address.location.position');
       */
    });
  }

  @override
  void dispose() {
    super.dispose();
    radius.close();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('GeoFlutterFire'),
          actions: <Widget>[
            IconButton(
              onPressed: () => _showHome(),
              icon: Icon(Icons.home),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 30,
                      height: MediaQuery.of(context).size.height * (1 / 3),
                      child: GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(12.960632, 77.641603),
                          zoom: 15.0,
                        ),
                        markers: markers.toSet(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Slider(
                    min: 1,
                    max: 200,
                    divisions: 4,
                    value: _value,
                    label: _label,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.blue.withOpacity(0.2),
                    onChanged: (double value) => changed(value),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 100,
                      child: TextField(
                        controller: _latitudeController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                            labelText: 'lat',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            )),
                      ),
                    ),
                    Container(
                      width: 100,
                      child: TextField(
                        controller: _longitudeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'lng',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            )),
                      ),
                    ),
                    MaterialButton(
                      color: Colors.blue,
                      onPressed: () {
                        double lat = double.parse(_latitudeController.text);
                        double lng = double.parse(_longitudeController.text);
                        _addPoint(lat, lng);
                      },
                      child: Text(
                        'ADD',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
                MaterialButton(
                  color: Colors.amber,
                  child: Text(
                    'Add nested ',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    double lat = double.parse(_latitudeController.text);
                    double lng = double.parse(_longitudeController.text);
                    _addNestedPoint(lat, lng);
                  },
                ),
                MaterialButton(
                  color: Colors.blueGrey,
                  child: Text(
                    'Stream Test ',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StreamTestWidget()),
                    );
                  },
                )

              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
    stream.listen((List<DocumentSnapshot> documentList) {
      _updateMarkers(documentList);
    });
  }

  void _showHome() async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      const CameraPosition(
        target: LatLng(12.960632, 77.641603),
        zoom: 15.0,
      ),
    ));
  }

  void _addPoint(double lat, double lng) {
    GeoFirePoint geoFirePoint = geo.point(latitude: lat, longitude: lng);
    _firestore.collection('locations').add({'name': 'random name', 'position': geoFirePoint.data}).then((_) {
      print('added ${geoFirePoint.hash} successfully');
    });
    setState(() {

    });
  }

  //example to add geoFirePoint inside nested object
  void _addNestedPoint(double lat, double lng) {
    GeoFirePoint geoFirePoint = geo.point(latitude: lat, longitude: lng);
    _firestore.collection('nestedLocations').add({
      'name': 'random name',
      'address': {
        'location': {'position': geoFirePoint.data}
      }
    }).then((_) {
      print('added ${geoFirePoint.hash} successfully');
    });
  }

  void _addMarker(double lat, double lng) {
    var _marker = Marker(
      markerId: MarkerId(UniqueKey().toString()),
      position: LatLng(lat, lng),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
    );
    setState(() {
      markers.add(_marker);
    });
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    documentList.forEach((DocumentSnapshot document) {
      GeoPoint point = document['position']['geopoint'];
      _addMarker(point.latitude, point.longitude);
    });
  }

  double _value = 40.0;
  String _label = '';

  changed(value) {
    setState(() {
      _value = value;
      _label = '${_value.toInt().toString()} kms';
      markers.clear();
      radius.add(value);
    });
  }
}
