# GeoFlutterFire

GeoFlutterFire is an open-source library that allows you to store and query a set of keys based on their geographic location. At its heart, GeoFlutterFire simply stores locations with string keys. Its main benefit, however, is the possibility of retrieving only those keys within a given geographic area - all in realtime.

GeoFlutterFire uses the Firebase Firestore Database for data storage, allowing query results to be updated in realtime as they change. GeoFlutterFire selectively loads only the data near certain locations, keeping your applications light and responsive, even with extremely large datasets.

GeoFlutterFire is designed as a lightweight add-on to cloud_firestore plugin. To keep things simple, GeoFlutterFire stores data in its own format within your Firestore database. This allows your existing data format and Security Rules to remain unchanged while still providing you with an easy solution for geo queries.


Heavily influenced by [GeoFireX](https://github.com/codediodeio/geofirex) :fire::fire: from [Jeff Delaney](https://github.com/codediodeio) :sunglasses:


## Getting Started

You should ensure that you add GeoFlutterFire as a dependency in your flutter project.
```yaml
dependencies:
    geoflutterfire: ^2.0.0
```

You can also reference the git repo directly if you want:
```yaml
dependencies:
    fluro:
        git: git://github.com/DarshanGowda0/GeoFlutterFire.git
```

You should then run `flutter packages get` or update your packages in IntelliJ.

## Example

There is a detailed example project in the `example` folder. Check that out or keep reading!

## Initialize

You need a firebase project with [Firestore](https://pub.dartlang.org/packages/cloud_firestore) setup.
```dart
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Init firestore and geoFlutterFire
Geoflutterfire geo = GeoFlutterFire();
Firestore _firestore = Firestore.instance;
```

## Writing Geo data
Add geo data to your firestore document using `GeoFirePoint`
```dart
GeoFirePoint myLocation = geo.point(latitude: 12.960632, longitude: 77.641603);
```
Next, add the GeoFirePoint to you document using Firestore's add method
```dart
 _firestore
        .collection('locations')
        .add({'name': 'random name', 'position': myLocation.data});
```

Calling `geoFirePoint.data` returns an object that contains a [geohash string](https://www.movable-type.co.uk/scripts/geohash.html) and a [Firestore GeoPoint](https://firebase.google.com/docs/reference/android/com/google/firebase/firestore/GeoPoint). It should look like this in your database. You can name the object whatever you want and even save multiple points on a single document.

![](https://firebasestorage.googleapis.com/v0/b/geo-test-c92e4.appspot.com/o/point1.png?alt=media&token=0c833700-3dbd-476a-99a9-41c1143dbe97)

## Query Geo data
To query a collection of documents with 50kms from a point
```dart
// Create a geoFirePoint
GeoFirePoint center = geo.point(latitude: 12.960632, longitude: 77.641603);

// get the collection reference or query
var collectionReference = _firestore.collection('locations');

double radius = 50;
String field = 'position';

Stream<List<DocumentSnapshot>> stream = geo.collection(collectionRef: collectionReference).within(center, radius, field);
```

The within function returns a Stream of the list of DocumentSnapshot data, plus some useful metadata like distance from the centerpoint.
```dart
stream.listen((List<DocumentSnapshot> documentList) {
        // doSomething()
      });
```

You now have a realtime stream of data to visualize on a map.
![](https://firebasestorage.googleapis.com/v0/b/geoflutterfire.appspot.com/o/geflutterfire.gif?alt=media&token=8dc3aa9c-ee68-4dfe-9093-c3c1c48979dc)

## :notebook: API

### `collection(collectionRef: CollectionReference)`

Creates a GeoCollectionRef which can be used to make geo queries, alternatively can also be used to write data just like firestore's add / set functionality.

Example:

```dart
// Collection ref
// var collectionReference = _firestore.collection('locations').where('city', isEqualTo: 'bangalore');
var collectionReference = _firestore.collection('locations');
var geoRef = geo.collection(collectionRef: collectionReference);
```
Note: collectionReference can be of type CollectionReference or Query

#### Performing Geo-Queries

`geoRef.within(center: GeoFirePoint, radius: double, field: String)`

Query the parent Firestore collection by geographic distance. It will return documents that exist within X kilometers of the center-point.
`field` supports nested objects in the firestore document.

Example:
```dart
// For GeoFirePoint stored at the root of the firestore document
geoRef.within(center: centerGeoPoint, radius: 50, field: 'position');

// For GeoFirePoint nested in other objects of the firestore document
geoRef.within(center: centerGeoPoint, radius: 50, field: 'address.location.position');
```

Each documentSnapshot.data also contains _distance_ calculated on the query.

**Returns:** `Stream<List<DocumentSnapshot>>`

#### Write Data

Write data just like you would in Firestore

`geoRef.add(data)`

Or use one of the client's conveniece methods

- `geoRef.setDoc(String id, var data, {bool merge})` - Set a document in the collection with an ID.
- `geoRef.setPoint(String id, String field, double latitude, double longitude)`- Add a geohash to an existing doc

#### Read Data

In addition to Geo-Queries, you can also read the collection like you would normally in Firestore, but as an Observable

- `geoRef.data()`- Stream of documentSnapshot
- `geoRef.snapshot()`- Stream of Firestore QuerySnapshot

### `point(latitude: double, longitude: double)`

Returns a GeoFirePoint allowing you to create geohashes, format data, and calculate relative distance.

Example: `var point = geo.point(38, -119)`

#### Getters

- `point.hash` Returns a geohash string at precision 9
- `point.geoPoint` Returns a Firestore GeoPoint
- `point.data` Returns data object suitable for saving to the Firestore database

#### Geo Calculations

- `point.distance(latitude, longitude)` Haversine distance to a point

## :zap: Tips

### Scale to Massive Collections

It's possibe to build Firestore collections with billions of documents. One of the main motivations of this project was to make geoqueries possible on a queried subset of data. You can pass a Query instead of a CollectionReference into the collection(), then all geoqueries will be scoped with the contstraints of that query.

Note: This query requires a composite index, which you will be prompted to create with an error from Firestore on the first request.

Example:

```dart
var queryRef = _firestore.collection('locations').where('city', isEqualTo: 'bangalore');
var stream = geo
              .collection(collectionRef: queryRef)
              .within(center: center, radius: rad, field: 'position');
```

### Make Dynamic Queries the RxDart Way

```dart
var radius = BehaviorSubject(seedValue: 1.0);
var collectionReference = _firestore.collection('locations');

stream = radius.switchMap((rad) {
      return geo
          .collection(collectionRef: collectionReference)
          .within(center: center, radius: rad, field: 'position');
    });

// Now update your query
radius.add(25);
```
