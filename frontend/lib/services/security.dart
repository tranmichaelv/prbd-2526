import 'dart:convert';

import 'api_client.dart';

class Security {

  static Future<String?> login(String mail, String password) async {
    final response = await ApiClient.post(
      'login',
      body: json.encode({'email': mail, 'password': password}),
      anonymous: true,
    );
    print(json.encode({
      'email': mail,
      'password': password
    }));
    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Email ou mot de passe incorrect');
    }

    final dynamic body = json.decode(response.body);
    String token = body['token'];
    return token;

  }

  static Future<bool> checkPseudoAvailable({String? pseudo}) async {
    final response = await ApiClient.post(
      'is_pseudo_available',
      body: json.encode({'pseudo': pseudo}),
      anonymous: true,
    );
    final dynamic body = json.decode(response.body);
    if (response.statusCode != 200) {
      throw Exception('Failed to validate pseudo\n\n${body['message']}');
    }
    return body;
  }

  static Future<bool> checkEmailAvailable({required String email}) async {
    final response = await ApiClient.post(
      'email_is_available',
      anonymous: true,
      body: jsonEncode({
        'email': email,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erreur vérification email: ${response.body}');
    }

    return jsonDecode(response.body) == true;
  }

  static Future<bool> checkFullNameAvailable({required String fullName}) async {
    final response = await ApiClient.post(
      'full_name_is_available',
      anonymous: true,
      body: jsonEncode({
        'full_name': fullName,
      }),
    );

    print('checkFullName status: ${response.statusCode}');
    print('checkFullName body: ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erreur vérification nom complet: ${response.body}');
    }

    return jsonDecode(response.body) == true;
  }

  static Future<void> signup({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    final response = await ApiClient.post(
      'signup',
      body: json.encode({
        'email': email,
        'password': password,
        'full_name': fullName,
        'phone': phone
      }),
      anonymous: true,
    );

    print('signup status: ${response.statusCode}');
    print('signup body: ${response.body}');


    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to signup\n\n${response.body}');
    }
  }
}