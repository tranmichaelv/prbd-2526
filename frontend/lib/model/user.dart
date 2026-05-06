import 'package:prbd_2526_c03/services/security.dart';

class User {

  static String? validatePseudo(String? pseudo) {
    if (pseudo == null || pseudo.isEmpty) {
      return 'Le nom complet ne peut pas être vide  ';
    } else if (pseudo.length < 5) {
      return 'le nom complet doit contenir au moins 5 caractères';
    } else {
      return null;
    }
  }

  static Future<String?> validatePseudoUnicity(String? value) async {

    var response = await Security.checkPseudoAvailable(pseudo: value?.trim());
    return response ? null : 'not available';
  }

  static String? validatePassword(String? value) {
    return (value == null || value.isEmpty) ? 'required' : null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    String? passwordError = validatePassword(value);
    if (passwordError == null) {
      return passwordError;
    }
    if (password != value) {
      return 'Les deux mots de passe doivent être identique';
    }
    return null;
  }
}