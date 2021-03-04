import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/src/collection.dart';
import 'package:geoflutterfire/src/point.dart';

class Geoflutterfire {
  Geoflutterfire();

  GeoFireCollectionRef collection({required Query collectionRef}) {
    return GeoFireCollectionRef(collectionRef);
  }

  GeoFirePoint point({required double latitude, required double longitude}) {
    return GeoFirePoint(latitude, longitude);
  }
}
