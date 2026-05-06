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

  static Future<void> signup({required String pseudo, required String password,}) async {
    final response = await ApiClient.post(
      'signup',
      body: json.encode({'pseudo': pseudo, 'password': password}),
      anonymous: true,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to signup\n\n${response.body}');
    }
  }
}