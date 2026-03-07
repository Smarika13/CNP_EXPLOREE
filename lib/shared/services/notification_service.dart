import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Handles guide booking notifications via EmailJS (free, no backend needed).
///
/// Setup: emailjs.com → free account → connect Gmail → create template.
/// Replace the three constants below with your EmailJS credentials.
class NotificationService {
  static final _db = FirebaseFirestore.instance;

  // ── EmailJS credentials (replace with your own from emailjs.com) ──────────
  static const _emailjsServiceId   = 'service_d2zom2b';
  static const _emailjsTemplateId  = 'template_ydtiojj';
  static const _receiptTemplateId  = 'template_receipt'; // create this template in EmailJS
  static const _emailjsPublicKey   = 'wPGfTPoaJ5Te_DysF';
  static const _emailjsPrivateKey  = '6sZqV3jILjwemUrGifA1b';

  // ─── Public entry point ───────────────────────────────────────────────────

  /// Fetches guide details from Firestore and sends email notification.
  static Future<void> notifyGuide({
    required String guideId,
    required String bookingId,
    required String activity,
    required String date,
    required String timeSlot,
    required int groupSize,
    required String visitorName,
  }) async {
    try {
      final guideDoc = await _db.collection('guides').doc(guideId).get();
      if (!guideDoc.exists) return;

      final data      = guideDoc.data()!;
      final guideName  = (data['name']  as String? ?? '').trim();
      final guideEmail = (data['email'] as String? ?? '').trim();

      if (guideEmail.isNotEmpty) {
        await _sendEmail(
          to: guideEmail,
          guideName: guideName,
          bookingId: bookingId,
          activity: activity,
          date: date,
          timeSlot: timeSlot,
          groupSize: groupSize,
          visitorName: visitorName,
        );
      }
    } catch (e) {
      // Notification failure must never break the booking flow
      debugPrint('[NotificationService] Failed to notify guide $guideId: $e');
    }
  }

  /// Sends a payment receipt email to the visitor/user.
  static Future<void> sendUserReceipt({
    required String userEmail,
    required String userName,
    required String activity,
    required String date,
    required String timeSlot,
    required int groupSize,
    required int totalAmount,
    required String paymentMethod,
    required String transactionId,
    required String bookingId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'service_id':  _emailjsServiceId,
          'template_id': _receiptTemplateId,
          'user_id':     _emailjsPublicKey,
          'accessToken': _emailjsPrivateKey,
          'template_params': {
            'user_email':      userEmail,
            'user_name':       userName,
            'activity':        activity,
            'date':            date,
            'time_slot':       timeSlot,
            'group_size':      groupSize.toString(),
            'total_amount':    'Rs. $totalAmount',
            'payment_method':  paymentMethod,
            'transaction_id':  transactionId,
            'booking_id':      bookingId,
          },
        }),
      );
      if (response.statusCode != 200) {
        debugPrint('[NotificationService] Receipt email error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('[NotificationService] Failed to send receipt to $userEmail: $e');
    }
  }

  // ─── Email ────────────────────────────────────────────────────────────────

  static Future<void> _sendEmail({
    required String to,
    required String guideName,
    required String bookingId,
    required String activity,
    required String date,
    required String timeSlot,
    required int groupSize,
    required String visitorName,
  }) async {
    final response = await http.post(
      Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'service_id':  _emailjsServiceId,
        'template_id': _emailjsTemplateId,
        'user_id':     _emailjsPublicKey,
        'accessToken': _emailjsPrivateKey,
        'template_params': {
          'guide_email':  to,
          'guide_name':   guideName,
          'activity':     activity,
          'date':         date,
          'time_slot':    timeSlot,
          'group_size':   groupSize.toString(),
          'visitor_name': visitorName,
          'booking_id':   bookingId,
        },
      }),
    );

    if (response.statusCode != 200) {
      debugPrint('[NotificationService] EmailJS error ${response.statusCode}: ${response.body}');
    }
  }

}
