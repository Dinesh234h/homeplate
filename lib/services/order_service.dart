import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderService {
  FirebaseFirestore? get _db {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint("OrderService: Firestore not initialized.");
      return null;
    }
  }

  /// F06: Atomic Slot Reservation
  Future<Map<String, dynamic>> reserveSlot({
    required String cookId,
    required String slotId,
    required int quantity,
  }) async {
    final db = _db;
    if (db == null) return {'success': true}; // Fallback: Succeed in mock mode

    final slotRef = db.collection('cooks').doc(cookId).collection('slots').doc(slotId);

    return db.runTransaction((transaction) async {
      final snapshot = await transaction.get(slotRef);
      if (!snapshot.exists) return {'success': false, 'error': 'Slot not found'};

      final data = snapshot.data()!;
      int total = data['total_capacity'] ?? 0;
      int confirmed = data['confirmed_count'] ?? 0;
      int pending = data['pending_count'] ?? 0;
      int available = total - (confirmed + pending);

      if (available >= quantity) {
        transaction.update(slotRef, {'pending_count': pending + quantity});
        return {'success': true};
      } else {
        return {'success': false, 'error': 'Slot just filled'};
      }
    });
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _db?.collection('orders').doc(orderId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> logCommission(String cookId, double orderTotal) async {
    double commission = orderTotal * 0.08;
    await _db?.collection('cooks').doc(cookId).update({
      'fee_due': FieldValue.increment(commission),
    });
  }
}
