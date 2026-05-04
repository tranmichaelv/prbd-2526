import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:prbd_2526_c03/app/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR',null);
  runApp(const MyApp());
}

/*class TestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: .fromSeed(seedColor: Colors.blue),
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('Test Page')),
        body: Center(
          child: Text('Welcome group c03!', style: TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}*/
