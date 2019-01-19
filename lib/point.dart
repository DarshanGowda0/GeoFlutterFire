import 'util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GeoFirePoint {
  static Util _util = Util();
  double latitude, longitude;
  var app;

  GeoFirePoint(double latitude, double longitude) {
    this.latitude = latitude;
    this.longitude = longitude;
    app = Firestore.instance;
  }

  static distance(Coordinates to, Coordinates from) {
    return Util.distance(to, from);
  }

  String get hash {
    return _util.encode(this.latitude, this.longitude, 9);
  }

  List<String> get neighbors {
    return _util.neighbors(this.hash);
  }

  GeoPoint get geoPoint {
    return GeoPoint(this.latitude, this.longitude);
  }

  Coordinates get coords {
    return Coordinates(this.latitude, this.longitude);
  }

  get data {
    return {'geopoint': this.geoPoint, 'geohash': this.hash};
  }

  haversineDistance(lat, lng) {
    return GeoFirePoint.distance(this.coords, Coordinates(lat, lng));
  }
}

class Coordinates {
  double latitude;
  double longitude;

  Coordinates(this.latitude, this.longitude);
}
