import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/src/models/distance_doc_snapshot.dart';
import 'package:geoflutterfire/src/models/point.dart';

import 'base.dart';

class GeoFireCollectionWithConverterRef<T> extends BaseGeoFireCollectionRef<T> {
  GeoFireCollectionWithConverterRef(Query<T> collectionReference)
      : super(collectionReference);

  Stream<List<DocumentSnapshot<T>>> within({
    required GeoFirePoint center,
    required double radius,
    required String field,
    required GeoPoint Function(T) geopointFrom,
    bool? strictMode,
  }) {
    return protectedWithin(
      center: center,
      radius: radius,
      field: field,
      geopointFrom: geopointFrom,
      strictMode: strictMode,
    );
  }

  Stream<List<DistanceDocSnapshot<T>>> withinWithDistance({
    required GeoFirePoint center,
    required double radius,
    required String field,
    required GeoPoint Function(T) geopointFrom,
    bool? strictMode,
  }) {
    return protectedWithinWithDistance(
      center: center,
      radius: radius,
      field: field,
      geopointFrom: geopointFrom,
      strictMode: strictMode,
    );
  }
}
