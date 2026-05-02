import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class MatchingService {
  FirebaseFirestore? get _db {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint("MatchingService: Firestore not initialized.");
      return null;
    }
  }

  /// F03: Geohash Spatial Matching
  /// F04: Dynamic Radius Expansion
  Future<List<DocumentSnapshot>> findNearbyCooks({
    required double lat,
    required double lng,
    double initialRadius = 1.0, 
    double maxRadius = 3.0,
    int minResults = 3,
  }) async {
    final db = _db;
    if (db == null) return []; // Fallback: empty list if Firestore unavailable

    double currentRadius = initialRadius;
    List<DocumentSnapshot> results = [];

    while (currentRadius <= maxRadius) {
      final GeoFirePoint center = GeoFirePoint(GeoPoint(lat, lng));
      final collectionReference = db.collection('cooks');
      
      final querySnapshot = await GeoCollectionReference(collectionReference)
          .fetchWithin(
            center: center,
            radiusInKm: currentRadius,
            field: 'location',
            geopointFrom: (data) => (data['location'] as Map<String, dynamic>)['geopoint'] as GeoPoint,
            strictMode: true,
          );

      results = querySnapshot;
      if (results.length >= minResults) break;
      currentRadius += 1.0;
    }

    return results;
  }

  List<DocumentSnapshot> rankCooks(
    List<DocumentSnapshot> cooks, 
    Map<String, dynamic> userPrefs,
    double userLat,
    double userLng,
  ) {
    cooks.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;
      double aScore = _calculateScore(aData, userPrefs, userLat, userLng);
      double bScore = _calculateScore(bData, userPrefs, userLat, userLng);
      return bScore.compareTo(aScore);
    });
    return cooks;
  }

  double _calculateScore(Map<String, dynamic> cookData, Map<String, dynamic> prefs, double lat, double lng) {
    double prefScore = (prefs['diet'] == cookData['diet']) ? 100 : 0;
    double distScore = (100 - (1.0 * 33)).clamp(0, 100);
    double trustScore = (cookData['trust_score'] ?? 60).toDouble();
    return (prefScore * 0.4) + (distScore * 0.3) + (trustScore * 0.3);
  }
}
