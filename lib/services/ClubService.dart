import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

import '../models/ClubsModel.dart';

class ClubService extends ChangeNotifier {
  static final ClubService _instance = ClubService._internal();
  List<Club> _clubs = [];

  factory ClubService() {
    return _instance;
  }

  ClubService._internal();

  Future<void> fetchClubs() async {
    print("fetch clubs");
    if (_clubs.isEmpty) {
      _clubs = await _getClubsFromFirebase();
      notifyListeners(); // Notify listeners when clubs are fetched
    }
  }

  List<Club> get clubs => _clubs;

  Future<List<Club>> _getClubsFromFirebase() async {
    print("_getClubsFromFirebase");

    List<Club> clubs = [];
    final database = FirebaseDatabase.instance;
    final ref = database.ref().child('clubs');
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      for (final child in snapshot.children) {
        Club club = Club.fromJson(Map<String, dynamic>.from(child.value as Map));
        clubs.add(club);
      }
    }
    return clubs;
  }
}