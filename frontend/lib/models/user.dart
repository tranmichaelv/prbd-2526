import 'dart:math';

import 'package:prbd_2526_c03/services/security.dart';

class User {

  static String? validateFullName(String? fullName) {

    final value = fullName?.trim();

    if (value == null || value.isEmpty) {
      return 'Le nom complet requis';
    }
    if (value.length < 5) {
      return 'le nom complet doit contenir au moins 5 caractères';
    }
    return null;
  }

  static Future<String?> validateFullNameUnicity(String? value) async {

    String? error = validateFullName(value);
    if (error != null) {
      return error;
    }
    final fullName = value!.trim();

    var response = await Security.checkFullNameAvailable(fullName: fullName);
    return response ? null : 'Ce nom complet est déjà utilisé';
  }

  static String? validatePassword(String? value) {

    final password = value?.trim();
    if (password == null || password.isEmpty)
      return 'Veuillez confirmez votre mot de passe';

    final errors = <String>[];

    if (password.length < 8) {
      errors.add('au moins 8 charactères');
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      errors.add('une majuscule');
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      errors.add('une minuscule');
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      errors.add('un chiffre');
    }

    if (!RegExp(r'[,;.:!?/$%&@#]').hasMatch(password)) {
      errors.add('un caractère spécial');
    }

    if (errors.isNotEmpty) {
      return 'Le mot de passe doit contenir : ${errors.join(', ')}';
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    final passwordError = validatePassword(value);

    if (passwordError == null) {
      return passwordError;
    }
    if (password != value) {
      return 'Les deux mots de passe doivent être identique';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    final email = value?.trim();
    
    if (email == null || email.isEmpty)
      return 'Email requis';

    final format = RegExp(r'^[A-Za-z0-9._%+-]+@epfc\.eu$');
    if (!format.hasMatch(email)) {
      return 'Veuillez entrer une adresse email valide';
    }

    return null;
  }

  static Future<String?> validateEmailUnicity(String? value) async {
    final error = validateEmail(value);

    if (error != null) {
      return error;
    }

    final available = await Security.checkEmailAvailable(
      email: value!.trim(),
    );

    return available ? null : 'Cet email est déjà utilisé';
  }
}