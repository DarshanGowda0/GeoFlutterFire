import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'point.dart';
import 'collection.dart';

class Geoflutterfire {
  Geoflutterfire();

  GeoFireCollectionRef collection(
      {@required Query collectionRef, int limitby}) {
    return GeoFireCollectionRef(collectionRef, limitby);
  }

  GeoFirePoint point({@required double latitude, @required double longitude}) {
    return GeoFirePoint(latitude, longitude);
  }
}
