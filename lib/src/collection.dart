import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/src/models/DistanceDocSnapshot.dart';
import 'package:geoflutterfire/src/point.dart';
import 'package:meta/meta.dart';
import 'util.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

class GeoFireCollectionRef {
  Query _collectionReference;
  Stream<QuerySnapshot> _stream;

  GeoFireCollectionRef(this._collectionReference)
      : assert(_collectionReference != null) {
    _stream = _createStream(_collectionReference).shareReplay(maxSize: 1);
  }

  /// return QuerySnapshot stream
  Stream<QuerySnapshot> snapshot() {
    return _stream;
  }

  /// return the Document mapped to the [id]
  Stream<List<DocumentSnapshot>> data(String id) {
    return _stream.map((QuerySnapshot querySnapshot) {
      querySnapshot.documents.where((DocumentSnapshot documentSnapshot) {
        return documentSnapshot.documentID == id;
      });
      return querySnapshot.documents;
    });
  }

  /// add a document to collection with [data]
  Future<DocumentReference> add(Map<String, dynamic> data) {
    try {
      CollectionReference colRef = _collectionReference;
      return colRef.add(data);
    } catch (e) {
      throw Exception(
          'cannot call add on Query, use collection reference instead');
    }
  }

  /// delete document with [id] from the collection
  Future<void> delete(id) {
    try {
      CollectionReference colRef = _collectionReference;
      return colRef.document(id).delete();
    } catch (e) {
      throw Exception(
          'cannot call delete on Query, use collection reference instead');
    }
  }

  /// create or update a document with [id], [merge] defines whether the document should overwrite
  Future<void> setDoc(String id, var data, {bool merge = false}) {
    try {
      CollectionReference colRef = _collectionReference;
      return colRef.document(id).setData(data, merge: merge);
    } catch (e) {
      throw Exception(
          'cannot call set on Query, use collection reference instead');
    }
  }

  /// set a geo point with [latitude] and [longitude] using [field] as the object key to the document with [id]
  Future<void> setPoint(
      String id, String field, double latitude, double longitude) {
    try {
      CollectionReference colRef = _collectionReference;
      var point = GeoFirePoint(latitude, longitude).data;
      return colRef.document(id).setData({'$field': point}, merge: true);
    } catch (e) {
      throw Exception(
          'cannot call set on Query, use collection reference instead');
    }
  }

  /// query firestore documents based on geographic [radius] from geoFirePoint [center]
  /// [field] specifies the name of the key in the document
  Stream<List<DocumentSnapshot>> within(
      {@required GeoFirePoint center,
      @required double radius,
      @required String field,
      bool strictMode = false}) {
    int precision = Util.setPrecision(radius);
    String centerHash = center.hash.substring(0, precision);
    List<String> area = GeoFirePoint.neighborsOf(hash: centerHash)
      ..add(centerHash);

    Iterable<Stream<List<DistanceDocSnapshot>>> queries = area.map((hash) {
      Query tempQuery = _queryPoint(hash, field);
      return _createStream(tempQuery).map((QuerySnapshot querySnapshot) {
        return querySnapshot.documents.map((element) => DistanceDocSnapshot(element,null)).toList();
      });
    });

    Stream<List<DistanceDocSnapshot>> mergedObservable = mergeObservable(queries);

    var filtered = mergedObservable.map((List<DistanceDocSnapshot> list) {
      var mappedList = list.map((DistanceDocSnapshot distanceDocSnapshot) {
        // split and fetch geoPoint from the nested Map
        List<String> fieldList = field.split('.');
        var geoPointField = distanceDocSnapshot.documentSnapshot.data[fieldList[0]];
        if (fieldList.length > 1) {
          for (int i = 1; i < fieldList.length; i++) {
            geoPointField = geoPointField[fieldList[i]];
          }
        }
        GeoPoint geoPoint = geoPointField['geopoint'];
        distanceDocSnapshot.distance = center.distance(lat: geoPoint.latitude, lng: geoPoint.longitude);
        return distanceDocSnapshot;
      });

      var filteredList = strictMode
          ? mappedList.where((DistanceDocSnapshot doc) {
              double distance = doc.distance;
              return distance <= radius * 1.02; // buffer for edge distances;
            }).toList()
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
     Stream<List<DistanceDocSnapshot>> mergedObservable = Rx.combineLatest(queries,
        (List<List<DistanceDocSnapshot>> originalList) {
      var reducedList = <DistanceDocSnapshot>[];
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
    String end = '$geoHash~';
    Query temp = _collectionReference;
    return temp.orderBy('$field.geohash').startAt([geoHash]).endAt([end]);
  }

  /// create an observable for [ref], [ref] can be [Query] or [CollectionReference]
  Stream<QuerySnapshot> _createStream(var ref) {
    return ref.snapshots();
  }
}
