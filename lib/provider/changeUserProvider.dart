import 'package:flutter/material.dart';
import 'package:flutter_application_1/signin_Screen.dart';
import 'package:provider/provider.dart';
import '/provider/userProvider.dart'; // Import the UserProvider

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      home: LoginPage(),
    );
  }
}
