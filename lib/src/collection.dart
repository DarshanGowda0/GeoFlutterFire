import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/src/models/DistanceDocSnapshot.dart';
import 'package:geoflutterfire/src/point.dart';
import 'package:rxdart/rxdart.dart';

import 'util.dart';

class GeoFireCollectionRef {
  Query _collectionReference;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _stream;

  GeoFireCollectionRef(this._collectionReference) {
    _stream = _createStream(_collectionReference).shareReplay(maxSize: 1);
  }

  /// return QuerySnapshot stream
  Stream<QuerySnapshot<Map<String, dynamic>>> snapshot() {
    return _stream;
  }

  /// add a document to collection with [data]
  Future<DocumentReference> add(Map<String, dynamic> data) {
    if (!(_collectionReference is CollectionReference))
      throw Exception('cannot call add on Query, use collection reference instead');
    CollectionReference colRef = _collectionReference as CollectionReference;
    return colRef.add(data);
  }

  /// delete document with [id] from the collection
  Future<void> delete(id) {
    if (!(_collectionReference is CollectionReference))
      throw Exception('cannot call add on Query, use collection reference instead');
    CollectionReference colRef = _collectionReference as CollectionReference;
    return colRef.doc(id).delete();
  }

  /// create or update a document with [id], [merge] defines whether the document should overwrite
  Future<void> setDoc(String id, var data, {bool merge = false}) {
    if (!(_collectionReference is CollectionReference))
      throw Exception('cannot call add on Query, use collection reference instead');
    CollectionReference colRef = _collectionReference as CollectionReference;
    return colRef.doc(id).set(data, SetOptions(merge: merge));
  }

  /// set a geo point with [latitude] and [longitude] using [field] as the object key to the document with [id]
  Future<void> setPoint(String id, String field, double latitude, double longitude) {
    if (!(_collectionReference is CollectionReference))
      throw Exception('cannot call add on Query, use collection reference instead');
    CollectionReference colRef = _collectionReference as CollectionReference;
    var point = GeoFirePoint(latitude, longitude).data;
    return colRef.doc(id).set({'$field': point}, SetOptions(merge: true));
  }

  /// query firestore documents based on geographic [radius] from geoFirePoint [center]
  /// [field] specifies the name of the key in the document
  Stream<List<DocumentSnapshot<Map<String, dynamic>>>> within({
    required GeoFirePoint center,
    required double radius,
    required String field,
    bool strictMode = false,
  }) {
    int precision = Util.setPrecision(radius);
    String centerHash = center.hash.substring(0, precision);
    List<String> area = GeoFirePoint.neighborsOf(hash: centerHash)..add(centerHash);

    Iterable<Stream<List<DistanceDocSnapshot>>> queries = area.map((hash) {
      Query<Object?> tempQuery = _queryPoint(hash, field);
      return _createStream(tempQuery).map((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
        return querySnapshot.docs.map((element) => DistanceDocSnapshot(element, 0)).toList();
      });
    });

    Stream<List<DistanceDocSnapshot>> mergedObservable = mergeObservable(queries);

    Stream<List<DocumentSnapshot<Map<String, dynamic>>>> filtered =
        mergedObservable.map((List<DistanceDocSnapshot> list) {
      Iterable<DistanceDocSnapshot> mappedList = list.map((DistanceDocSnapshot distanceDocSnapshot) {
        // split and fetch geoPoint from the nested Map
        List<String> fieldList = field.split('.');
        Map<String, dynamic> geoPointField = {};
        if (distanceDocSnapshot.documentSnapshot.data() != null) {
          geoPointField
              .addAll(distanceDocSnapshot.documentSnapshot.data()![fieldList[0]] as Map<String, dynamic>);
        }
        if (fieldList.length > 1) {
          for (int i = 1; i < fieldList.length; i++) {
            geoPointField = geoPointField[fieldList[i]];
          }
        }
        final GeoPoint geoPoint = geoPointField['geopoint'];
        distanceDocSnapshot.distance = center.distance(lat: geoPoint.latitude, lng: geoPoint.longitude);
        return distanceDocSnapshot;
      });

      List<DistanceDocSnapshot> filteredList = strictMode
          ? mappedList
              .where(
                  (DistanceDocSnapshot doc) => doc.distance <= radius * 1.02 // buffer for edge distances;
                  )
              .toList()
          : mappedList.toList();
      filteredList.sort((a, b) {
        double distA = a.distance;
        double distB = b.distance;
        int val = (distA * 1000).toInt() - (distB * 1000).toInt();
        return val;
      });
      return filteredList.map((element) => element.documentSnapshot).toList();
    });
    return filtered.asBroadcastStream();
  }

  Stream<List<DistanceDocSnapshot>> mergeObservable(Iterable<Stream<List<DistanceDocSnapshot>>> queries) {
    Stream<List<DistanceDocSnapshot>> mergedObservable =
        Rx.combineLatest(queries, (List<List<DistanceDocSnapshot>> originalList) {
      final reducedList = <DistanceDocSnapshot>[];
      originalList.forEach((t) {
        reducedList.addAll(t);
      });
      return reducedList;
    });
    return mergedObservable;
  }

  /// INTERNAL FUNCTIONS

  /// construct a query for the [geoHash] and [field]
  Query _queryPoint(String geoHash, String field) {
    final end = '$geoHash~';
    final temp = _collectionReference;
    return temp.orderBy('$field.geohash').startAt([geoHash]).endAt([end]);
  }

  /// create an observable for [ref], [ref] can be [Query] or [CollectionReference]
  Stream<QuerySnapshot<Map<String, dynamic>>> _createStream(var ref) {
    return ref.snapshots();
  }
}
