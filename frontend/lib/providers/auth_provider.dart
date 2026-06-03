import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_c03/services/params.dart';
import 'package:prbd_2526_c03/services/security.dart';

class ConnectedUser {
  final int id;
  final String email;
  final String name;
  final String role;

  const ConnectedUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
});
}

final authProvider = NotifierProvider<AuthNotifier, ConnectedUser?>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<ConnectedUser?> {

  @override
  ConnectedUser? build() {
    final token = Params.getValue('token');

    if (token == null) {
      return null;
    }

    return _userFromToken(token);
  }

  Future<void> login(String email, String password) async {
    final token = await Security.login(email, password);

    await Params.setValue('token', token);

    state = _userFromToken(token!);
  }

  Future<void> logout() async {
    await Params.clearValue('token');
    state = null;
  }

  ConnectedUser _userFromToken(String token) {
    final parts = token.split('.');
    final payload = parts[1];

    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final data = jsonDecode(decoded);

    return ConnectedUser(
      id: data['user_id'] as int,
      email: data['sub'] as String,
      name: data['name'] as String,
      role: data['role'] as String,
    );
  }
}