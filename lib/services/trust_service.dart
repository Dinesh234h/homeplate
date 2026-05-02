import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TrustService {
  FirebaseFirestore? get _db {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint("TrustService: Firestore not initialized.");
      return null;
    }
  }

  /// F12: Verified Rating System
  Future<Map<String, dynamic>> submitRating({
    required String orderId,
    required String cookId,
    required int stars,
    String? comment,
  }) async {
    final db = _db;
    if (db == null) return {'success': true}; // Mock success

    final orderDoc = await db.collection('orders').doc(orderId).get();
    if (!orderDoc.exists) return {'success': false, 'error': 'Order not found'};
    
    final orderData = orderDoc.data()!;
    if (orderData['status'] != 'COMPLETED') {
      return {'success': false, 'error': 'Can only rate completed orders'};
    }

    await db.runTransaction((transaction) async {
      final reviewRef = db.collection('cooks').doc(cookId).collection('reviews').doc(orderId);
      transaction.set(reviewRef, {
        'stars': stars,
        'comment': comment,
        'userId': orderData['userId'],
        'timestamp': FieldValue.serverTimestamp(),
      });
      transaction.update(db.collection('orders').doc(orderId), {
        'isRated': true,
        'ratedStars': stars,
      });
    });

    return {'success': true};
  }

  String getCookLevel(double trustScore, int orderCount) {
    if (trustScore < 50 || orderCount < 5) return 'New Cook';
    if (trustScore < 80) return 'Trusted Cook';
    return 'Top Cook';
  }
}
