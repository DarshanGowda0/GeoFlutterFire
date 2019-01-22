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
      _stream = _createStream(_query).shareReplay(maxSize: 1);
    } else {
      _query = _collectionReference;
      _stream = _createStream(_collectionReference).shareReplay(maxSize: 1);
    }
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
    return _collectionReference.add(data);
  }

  /// delete document with [id] from the collection
  Future<void> delete(id) {
    return _collectionReference.document(id).delete();
  }

  /// create or update a document with [id], [merge] defines whether the document should overwrite
  Future<void> setDoc(String id, var data, {bool merge = false}) {
    return _collectionReference.document(id).setData(data, merge: merge);
  }

  /// set a geo point with [latitude] and [longitude] using [field] as the object key to the document with [id]
  Future<void> setPoint(
      String id, String field, double latitude, double longitude) {
    var point = GeoFirePoint(latitude, longitude).data;
    return _collectionReference
        .document(id)
        .setData({'$field': point}, merge: true);
  }

  /// query firestore documents based on geographic [radius] from geoFirePoint [center]
  /// [field] specifies the name of the key in the document
  Stream<List<DocumentSnapshot>> within(
      GeoFirePoint center, double radius, String field) {
    int precision = Util.setPrecision(radius);
    String centerHash = center.hash.substring(0, precision);
    List<String> area = GeoFirePoint.neighborsOf(hash: centerHash);
    area.add(centerHash);

    var queries = area.map((hash) {
      Query tempQuery = _queryPoint(hash, field);
      return _createStream(tempQuery).map((QuerySnapshot querySnapshot) {
        return querySnapshot.documents;
      });
    });

    var mergedObservable = Observable.merge(queries);

    var filtered = mergedObservable.map((List<DocumentSnapshot> list) {
      var filteredList = list.where((DocumentSnapshot doc) {
        GeoPoint geoPoint = doc.data[field]['geopoint'];
        double distance =
            center.distance(lat: geoPoint.latitude, lng: geoPoint.longitude);
        return distance <= radius * 1.02; // buffer for edge distances;
      }).map((DocumentSnapshot documentSnapshot) {
        GeoPoint geoPoint = documentSnapshot.data[field]['geopoint'];
        documentSnapshot.data['distance'] =
            center.distance(lat: geoPoint.latitude, lng: geoPoint.longitude);
        return documentSnapshot;
      }).toList();
      filteredList.sort((a, b) {
        double distA = a.data['distance'] * 1000 * 1000;
        double distB = b.data['distance'] * 1000 * 1000;
        int val = distA.toInt() - distB.toInt();
        return val;
      });
      return filteredList;
    });
    return filtered.asBroadcastStream();
  }

  /// INTERNAL FUNCTIONS

  /// construct a query for the [geoHash] and [field]
  Query _queryPoint(String geoHash, String field) {
    String end = '$geoHash~';
    Query temp = _query;
    return temp.orderBy('$field.geohash').startAt([geoHash]).endAt([end]);
  }

  /// create an observable for [ref], [ref] can be [Query] or [CollectionReference]
  Observable<QuerySnapshot> _createStream(var ref) {
    return Observable<QuerySnapshot>(ref.snapshots());
  }
}
