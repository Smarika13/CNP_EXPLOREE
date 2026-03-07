import 'dart:convert';
import 'package:crypto/crypto.dart';

class EsewaService {
  // eSewa sandbox test credentials
  static const String _secretKey = "8gBm/:&EnhH.1/q";
  static const String productCode = "EPAYTEST";

  static String generateSignature({
    required String totalAmount,
    required String transactionUuid,
  }) {
    final String message =
        "total_amount=$totalAmount,transaction_uuid=$transactionUuid,product_code=$productCode";
    final List<int> key = utf8.encode(_secretKey);
    final List<int> bytes = utf8.encode(message);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return base64.encode(digest.bytes);
  }

  static String generateUuid() =>
      DateTime.now().millisecondsSinceEpoch.toString();
}
