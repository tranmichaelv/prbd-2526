import 'package:flutter/material.dart';
import 'package:prbd_2526_c03/views/pages/home_client_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:prbd_2526_c03/views/pages/login_page.dart';
import 'package:prbd_2526_c03/views/pages/my_restaurants.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'EN')
      ],
      locale: const Locale('fr', 'FR'),

      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomeClientPageScreen(),
        '/manager': (context) => const MyRestaurantsPageScreen(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}