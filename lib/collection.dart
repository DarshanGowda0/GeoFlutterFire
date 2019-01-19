import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/point.dart';
import 'util.dart';
import 'package:rxdart/rxdart.dart';

class GeoFireCollectionRef {
  CollectionReference _collectionReference;
  Stream<QuerySnapshot> _stream;
  Query _query;

  GeoFireCollectionRef(String collectionPath, {Query query}) {
    _collectionReference = Firestore.instance.collection(collectionPath);
    if (query != null) _query = query;
    _stream = createStream(_collectionReference).shareReplay(maxSize: 1);
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

  setPoint(String id, String field, double latitude, double longitude) {
    var point = GeoFirePoint(latitude, longitude).data;
    return _collectionReference
        .document(id)
        .setData({'feild': point}, merge: true);
  }

  within(GeoFirePoint center, double radius, String field) {
    int precision = Util.setPrecision(radius);
    String centerHash = center.hash.substring(0, precision);
    List<String> area = center.neighbors;
    area.add(centerHash);

    Iterable<Observable<QuerySnapshot>> queries = area.map((hash) {
      _query = _queryPoint(hash, field);
      return createStream(_query).map((QuerySnapshot querySnapshot) {
        querySnapshot.documents.map((DocumentSnapshot documentSnapshot) {
          documentSnapshot.data.putIfAbsent('id', () => null);
          return documentSnapshot;
        });
      });
    });

//    var combo = Observable.combineLatest(queries, ())
  }

  _queryPoint(String geoHash, String field) {
    String end = '~';
    Query query;
    return query.orderBy('$field.geohash').startAt([geoHash]).endAt([end]);
  }

  Observable<QuerySnapshot> createStream(var ref) {
    return Observable<QuerySnapshot>(ref.snapshots());
  }
}
