import 'package:cloud_firestore/cloud_firestore.dart';

class DistanceDocSnapshot {
  final DocumentSnapshot<Map<String, dynamic>> documentSnapshot;
  double distance;

  DistanceDocSnapshot(this.documentSnapshot, this.distance);
}
