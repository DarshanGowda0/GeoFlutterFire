import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/point.dart';
import 'package:rxdart/src/observables/observable.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Firestore _firestore = Firestore.instance;
  Geoflutterfire geo;
  Observable<DocumentSnapshot> stream;

  @override
  void initState() {
    super.initState();
    geo = Geoflutterfire(_firestore);
    GeoFirePoint center = geo.point(latitude: 34, longitude: -113);
    stream =
        geo.collection(collectionPath: 'data').within(center, 200, 'position');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Hash Val '),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            stream.listen((data) {
              print(data.data);
            });
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
