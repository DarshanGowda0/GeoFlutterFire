import 'dart:async';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/point.dart';
import 'package:geoflutterfire/util.dart';
import 'package:meta/meta.dart';
import 'collection.dart';

class Geoflutterfire {
  Firestore _firestore;

  Geoflutterfire(this._firestore);

  GeoFireCollectionRef collection(
      {@required String collectionPath, Query query}) {
    return GeoFireCollectionRef(_firestore, collectionPath, query: query);
  }

  GeoFirePoint point({@required double latitude, @required double longitude}) {
    return GeoFirePoint(latitude, longitude);
  }

  static List<double> getHash() {
    List<double> something = Util().decode_bbox("tdr1zdkb0");
    return something;
  }

  something() {}
}
