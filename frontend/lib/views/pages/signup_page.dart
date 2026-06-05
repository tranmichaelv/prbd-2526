import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_c03/core/tools/validating_text_editing_controller.dart';
import 'package:prbd_2526_c03/models/user.dart';
import 'package:prbd_2526_c03/providers/reference_time_provider.dart';
import 'package:prbd_2526_c03/services/security.dart';
import 'package:prbd_2526_c03/views/pages/login_page.dart';
import 'package:prbd_2526_c03/views/widgets/simuled_time.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SignupPage(),
    ),
  );
}

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => SignupState();
}

class SignupState extends ConsumerState<SignupPage> {
  late ValidatingTextEditingController nameController;
  late ValidatingTextEditingController emailController;
  late ValidatingTextEditingController passwordController;
  late ValidatingTextEditingController confirmPasswordController;

  final phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();

    nameController = ValidatingTextEditingController(
      validator: User.validateFullName,
      asyncValidator: User.validateFullNameUnicity,
    );
    nameController.onAfterValidated = () => setState(() {});

    emailController = ValidatingTextEditingController(
      validator: User.validateEmail,
      asyncValidator: User.validateEmailUnicity,
    );
    emailController.onAfterValidated = () => setState(() {});

    passwordController = ValidatingTextEditingController(
      validator: User.validatePassword,
    );
    passwordController.onAfterValidated = () {
      confirmPasswordController.validate();
      setState(() {});
    };

    confirmPasswordController = ValidatingTextEditingController(
      validator: (value) {
        return User.validateConfirmPassword(
          value,
          passwordController.text,
        );
      },
    );
    confirmPasswordController.onAfterValidated = () => setState(() {});
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();

    super.dispose();
  }

  void _clearForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    phoneController.clear();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final referenceTime =  ref.watch(referenceTimeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Inscription'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: _clearForm,
          ),
        ],
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: GestureDetector(
                onTap: () {
                  SimuledTime().show(context);
                },
                child: Tooltip(
                  message:
                  'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
                  child: Text(
                    DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR')
                        .format(referenceTime),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                const Icon(Icons.person_add, size: 80, color: Colors.blue),
                const SizedBox(height: 32),
                const Text(
                  'Créez votre compte',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                TextFormField(
                  controller: nameController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: 'Nom complet',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person),
                    errorText: nameController.errorText,
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: emailController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email),
                    errorText: emailController.errorText,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: passwordController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    errorText: passwordController.errorText,
                  ),
                  obscureText: true,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: confirmPasswordController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    errorText: confirmPasswordController.errorText,
                  ),
                  obscureText: true,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: phoneController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone (optionnel)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('S\'inscrire'),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text('Déjà un compte ? Se connecter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!await _validateForm()) {
      return;
    }

    final fullName = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final phone = phoneController.text.trim();

    try {
      await Security.signup(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone.isEmpty ? null : phone,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte créé avec succès'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l inscription'),
        ),
      );
    }
  }

  Future<bool> _validateForm() async {
    await nameController.validateAndWait();
    await emailController.validateAndWait();
    await passwordController.validateAndWait();
    await confirmPasswordController.validateAndWait();

    return _isFormValid;
  }

  bool get _isFormValid {
    return nameController.isValid == true &&
        emailController.isValid == true &&
        passwordController.isValid == true &&
        confirmPasswordController.isValid == true;
  }
}