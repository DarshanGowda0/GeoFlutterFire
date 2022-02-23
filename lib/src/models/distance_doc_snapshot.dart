import 'package:cloud_firestore/cloud_firestore.dart';

class DistanceDocSnapshot<T> {
  final DocumentSnapshot<T> documentSnapshot;
  final double kmDistance;

  DistanceDocSnapshot({
    required this.documentSnapshot,
    required this.kmDistance,
  });
}
