import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rxdart/rxdart.dart';

class StreamTestWidget extends StatefulWidget {
  @override
  _StreamTestWidgetState createState() => _StreamTestWidgetState();
}

class _StreamTestWidgetState extends State<StreamTestWidget> {
  Stream<List<DocumentSnapshot>> stream;
  Firestore _firestore = Firestore.instance;
  Geoflutterfire geo;

  // ignore: close_sinks
  var radius = BehaviorSubject.seeded(1.0);

  @override
  void initState() {
    super.initState();
    geo = Geoflutterfire();
    GeoFirePoint center = geo.point(latitude: 12.960632, longitude: 77.641603);
    stream = radius.switchMap((rad) {
      var collectionReference = _firestore.collection('locations');
      return geo.collection(collectionRef: collectionReference).within(
          center: center, radius: rad, field: 'position', strictMode: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          StreamBuilder(
            stream: stream,
            builder: (BuildContext context,
                AsyncSnapshot<List<DocumentSnapshot>> snapshots) {
              if (snapshots.connectionState == ConnectionState.active &&
                  snapshots.hasData) {
                print('data ${snapshots.data}');
                return Container(
                  height: MediaQuery.of(context).size.height * 2 / 3,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      DocumentSnapshot doc = snapshots.data[index];
                      print(
                          'doc with id ${doc.documentID} distance ${doc.data['distance']}');
                      GeoPoint point = doc.data['position']['geopoint'];
                      return ListTile(
                        title: Text(
                          '${doc.documentID}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${point.latitude}, ${point.longitude}'),
                        trailing: Text(
                            '${doc.data['documentType'] == DocumentChangeType.added ? 'Added' : 'Modified'}'),
                      );
                    },
                    itemCount: snapshots.data.length,
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },

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
        ],
      ),
    );
  }

  double _value = 20.0;
  String _label = '';

  changed(value) {
    setState(() {
      _value = value;
      print(_value);
      _label = '${_value.toInt().toString()} kms';
    });
    radius.add(value);
  }
}
