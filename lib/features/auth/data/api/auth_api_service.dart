import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/registration_model.dart';

class AuthApiService {
  static const String baseUrl = 'https://your-api-base-url.com/api';
  
  // Send OTP for registration
  Future<Map<String, dynamic>> sendRegistrationOTP({
    required String phoneNumber,
    required int driverType,
    String? companyCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-registration-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'driverType': driverType,
          'companyCode': companyCode,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send OTP: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Send OTP for login
  Future<Map<String, dynamic>> sendLoginOTP({
    required String phoneNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-login-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send login OTP: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOTP({
    required String phoneNumber,
    required String otp,
    required bool isLogin,
  }) async {
    try {
      final endpoint = isLogin ? 'verify-login-otp' : 'verify-registration-otp';
      final response = await http.post(
        Uri.parse('$baseUrl/auth/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to verify OTP: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Submit complete registration
  Future<Map<String, dynamic>> submitRegistration({
    required RegistrationModel registrationModel,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/complete-registration'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(registrationModel.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to complete registration: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Login with verified phone number
  Future<Map<String, dynamic>> loginUser({
    required String phoneNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}