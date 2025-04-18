import 'package:cloud_firestore/cloud_firestore.dart';

class Collections {
  const Collections();

  final String patients = 'patients';
  final String devices = 'devices';
  final String notificationProfiles = 'notificationProfiles';
}

class WitnessingDatabase {
  WitnessingDatabase._();

  static const Collections collections = Collections();
  static final FirebaseFirestore _firestoreDB = FirebaseFirestore.instance;

  static FirebaseFirestore get instance => _firestoreDB;
}
