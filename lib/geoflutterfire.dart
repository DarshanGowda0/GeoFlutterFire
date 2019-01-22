import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/point.dart';
import 'package:meta/meta.dart';
import 'collection.dart';

class Geoflutterfire {
  Geoflutterfire();

  GeoFireCollectionRef collection({@required Query collectionRef}) {
    return GeoFireCollectionRef(collectionRef);
  }

  GeoFirePoint point({@required double latitude, @required double longitude}) {
    return GeoFirePoint(latitude, longitude);
  }
}
