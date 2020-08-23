# geoflutterfire_example

Demonstrates how to use the geoflutterfire plugin.

```dart
   import 'package:flutter/material.dart';
   import 'package:geoflutterfire/geoflutterfire.dart';
   import 'package:cloud_firestore/cloud_firestore.dart';
   import 'package:geoflutterfire/src/point.dart';
   import 'package:google_maps_flutter/google_maps_flutter.dart';
   import 'package:rxdart/rxdart.dart';

   void main() => runApp(MaterialApp(
         title: 'Geo Flutter Fire example',
         home: MyApp(),
         debugShowCheckedModeBanner: false,
       ));

   class MyApp extends StatefulWidget {
     @override
     _MyAppState createState() => _MyAppState();
   }

   class _MyAppState extends State<MyApp> {
     GoogleMapController _mapController;
     TextEditingController _latitudeController, _longitudeController;

     // firestore init
     final _firestore = FirebaseFirestore.instance;
     Geoflutterfire geo;
     Stream<List<DocumentSnapshot>> stream;
     var radius = BehaviorSubject(seedValue: 1.0);

     @override
     void initState() {
       super.initState();
       _latitudeController = TextEditingController();
       _longitudeController = TextEditingController();

       geo = Geoflutterfire();
       GeoFirePoint center = geo.point(latitude: 12.960632, longitude: 77.641603);
       stream = radius.switchMap((rad) {
         var collectionReference = _firestore.collection('locations');
   //          .where('name', isEqualTo: 'darshan');
         return geo
             .collection(collectionRef: collectionReference)
             .within(center: center, radius: rad, field: 'position');

         /*
         ****Example to specify nested object****

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
                 onPressed: _mapController == null
                     ? null
                     : () {
                         _showHome();
                       },
                 icon: Icon(Icons.home),
               )
             ],
           ),
           body: Container(
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
                 )
               ],
             ),
           ),
         ),
       );
     }

     void _onMapCreated(GoogleMapController controller) {
       setState(() {
         _mapController = controller;
   //      _showHome();
         //start listening after map is created
         stream.listen((List<DocumentSnapshot> documentList) {
           _updateMarkers(documentList);
         });
       });
     }

     void _showHome() {
       _mapController.animateCamera(CameraUpdate.newCameraPosition(
         const CameraPosition(
           target: LatLng(12.960632, 77.641603),
           zoom: 15.0,
         ),
       ));
     }

     void _addPoint(double lat, double lng) {
       GeoFirePoint geoFirePoint = geo.point(latitude: lat, longitude: lng);
       _firestore
           .collection('locations')
           .add({'name': 'random name', 'position': geoFirePoint.data}).then((_) {
         print('added ${geoFirePoint.hash} successfully');
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
       var _marker = MarkerOptions(
         position: LatLng(lat, lng),
         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
       );
       setState(() {
         _mapController.addMarker(_marker);
       });
     }

     void _updateMarkers(List<DocumentSnapshot> documentList) {
       documentList.forEach((DocumentSnapshot document) {
         GeoPoint point = document.data['position']['geopoint'];
         _addMarker(point.latitude, point.longitude);
       });
     }

     double _value = 20.0;
     String _label = '';

     changed(value) {
       setState(() {
         _value = value;
         _label = '${_value.toInt().toString()} kms';
         _mapController.clearMarkers();
       });
       radius.add(value);
     }
   }
```
