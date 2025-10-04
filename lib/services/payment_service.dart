import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  // Sandbox credentials - ganti dengan production nanti
  static const String serverKey = 'YOUR_MIDTRANS_SERVER_KEY';
  static const String clientKey = 'YOUR_MIDTRANS_CLIENT_KEY';
  static const bool isProduction = false;
  
  static String get baseUrl => isProduction 
      ? 'https://app.midtrans.com' 
      : 'https://app.sandbox.midtrans.com';
  
  static String get apiUrl => isProduction
      ? 'https://api.midtrans.com'
      : 'https://api.sandbox.midtrans.com';

  Future<Map<String, dynamic>> createTransaction({
    required String orderId,
    required double amount,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
  }) async {
    final url = Uri.parse('$apiUrl/v2/charge');
    final auth = base64Encode(utf8.encode('$serverKey:'));

    final body = {
      'payment_type': 'gopay',
      'transaction_details': {
        'order_id': orderId,
        'gross_amount': amount.toInt(),
      },
      'customer_details': {
        'first_name': customerName,
        'email': customerEmail,
        'phone': customerPhone,
      },
      'gopay': {
        'enable_callback': true,
        'callback_url': 'https://your-app.com/payment/callback',
      }
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Basic $auth',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Payment failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Payment error: $e');
    }
  }

  Future<Map<String, dynamic>> createSnapTransaction({
    required String orderId,
    required double amount,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    List<Map<String, dynamic>>? items,
  }) async {
    final url = Uri.parse('$apiUrl/v1/payment-links');
    final auth = base64Encode(utf8.encode('$serverKey:'));

    final body = {
      'transaction_details': {
        'order_id': orderId,
        'gross_amount': amount.toInt(),
      },
      'customer_details': {
        'first_name': customerName,
        'email': customerEmail,
        'phone': customerPhone,
      },
      'item_details': items ?? [
        {
          'id': 'ITEM1',
          'price': amount.toInt(),
          'quantity': 1,
          'name': 'Order #$orderId',
        }
      ],
      'enabled_payments': [
        'gopay',
        'shopeepay',
        'qris',
        'bank_transfer',
        'echannel',
        'bca_va',
        'bni_va',
        'bri_va',
        'permata_va',
      ],
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Basic $auth',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Payment link creation failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Payment error: $e');
    }
  }

  Future<Map<String, dynamic>> checkPaymentStatus(String orderId) async {
    final url = Uri.parse('$apiUrl/v2/$orderId/status');
    final auth = base64Encode(utf8.encode('$serverKey:'));

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Basic $auth',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Status check failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Status check error: $e');
    }
  }
}