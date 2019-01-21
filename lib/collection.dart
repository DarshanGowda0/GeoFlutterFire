import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/point.dart';
import 'util.dart';
import 'package:rxdart/rxdart.dart';

class GeoFireCollectionRef {
  CollectionReference _collectionReference;
  Stream<QuerySnapshot> _stream;
  Query _query;
  Firestore _firestore;

  GeoFireCollectionRef(this._firestore, String collectionPath, {Query query}) {
    _collectionReference = _firestore.collection(collectionPath);
    if (query != null) {
      _query = query;
      _stream = createStream(_query).shareReplay(maxSize: 1);
    } else {
      _query = _collectionReference;
      _stream = createStream(_collectionReference).shareReplay(maxSize: 1);
    }
  }

  snapshot() {
    return _stream;
  }

  data(String id) {
    return _stream.map((QuerySnapshot querySnapshot) {
      querySnapshot.documents.map((DocumentSnapshot documentSnapshot) {
        documentSnapshot.data.putIfAbsent('id', () => id);
        return documentSnapshot;
      });
    });
  }

  Future<DocumentReference> add(data) {
    return _collectionReference.add(data);
  }

  Future delete(id) {
    return _collectionReference.document(id).delete();
  }

  setDoc(String id, var data, {bool merge = false}) {
    return _collectionReference.document(id).setData(data, merge: merge);
  }

  Future<void> setPoint(
      String id, String field, double latitude, double longitude) {
    var point = GeoFirePoint(latitude, longitude).data;
    return _collectionReference
        .document(id)
        .setData({'$field': point}, merge: true);
  }

  Observable<DocumentSnapshot> within(
      GeoFirePoint center, double radius, String field) {
    int precision = Util.setPrecision(radius);
    String centerHash = center.hash.substring(0, precision);
    List<String> area = GeoFirePoint.neighborsOf(centerHash);
    area.add(centerHash);

    /*var queries = area.map((hash) {
      Query tempQuery = _queryPoint(hash, field);
      return createStream(tempQuery).map((QuerySnapshot querySnapshot) {
        var data = querySnapshot.documents.map((DocumentSnapshot documentSnapshot) {
          documentSnapshot.data
              .putIfAbsent('id', () => documentSnapshot.documentID);
          return documentSnapshot.data;
        });
        return data;
      });
    });*/

    var queries = area.map((hash) {
      Query tempQuery = _queryPoint(hash, field);
      return createStream(tempQuery).map((QuerySnapshot querySnapshot) {
        return querySnapshot.documents;
      });
    });

    var mergedObservable = Observable.merge(queries);
    var flattenedObservable = mergedObservable.expand((pair) => pair);
    var filtered = flattenedObservable.where((DocumentSnapshot doc) {
      GeoPoint geoPoint = doc.data[field]['geopoint'];
      double distance = center.distance(geoPoint.latitude, geoPoint.longitude);
      return distance <= radius * 1.02; // buffer for edge distances;
    }).map((DocumentSnapshot documentSnapshot) {
      GeoPoint geoPoint = documentSnapshot.data[field]['geopoint'];
      documentSnapshot.data.putIfAbsent('distance',
          () => center.distance(geoPoint.latitude, geoPoint.longitude));
      return documentSnapshot;
    }).shareReplay(maxSize: 1);
    return filtered;
  }

  Query _queryPoint(String geoHash, String field) {
    String end = '~';
    Query temp = _query;
    return temp.orderBy('$field.geohash').startAt([geoHash]).endAt([end]);
  }

  Observable<QuerySnapshot> createStream(var ref) {
    return Observable<QuerySnapshot>(ref.snapshots());
  }
}
