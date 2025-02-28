import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
import 'package:flutter_application_1/service/notifi_service.dart';
import 'package:provider/provider.dart';
import 'favorites_provider.dart';
import 'product_provider.dart';
import 'provider/userProvider.dart';
import 'onboardingscreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'signin_Screen.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final NotifiService notifiService = NotifiService();
  await notifiService.iniNotification();

  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  await dotenv.load(fileName: '.env');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fashion Store',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      routes: {
        '/signin': (context) => const LoginPage(),
        '/home': (context) => const OnboardingScreen(),
      },
      // home: const NotificationPage(title: 'Notification Test'),
      home: const OnboardingScreen(),
    );
  }
}



// import 'dart:convert';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

// void main() {
//   runApp(const MyApp());
// }

// String prettyPrint(Map json) {
//   JsonEncoder encoder = const JsonEncoder.withIndent('  ');
//   String pretty = encoder.convert(json);
//   return pretty;
// }

// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   Map<String, dynamic>? _userData;
//   AccessToken? _accessToken;
//   bool _checking = true;

//   @override
//   void initState() {
//     super.initState();
//     _checkIfIsLogged();
//   }

//   Future<void> _checkIfIsLogged() async {
//     final accessToken = await FacebookAuth.instance.accessToken;
//     setState(() {
//       _checking = false;
//     });
//     if (accessToken != null) {
//       print("is Logged:::: ${prettyPrint(accessToken.toJson())}");
//       // now you can call to  FacebookAuth.instance.getUserData();
//       final userData = await FacebookAuth.instance.getUserData();
//       // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");
//       _accessToken = accessToken;
//       setState(() {
//         _userData = userData;
//       });
//     }
//   }

//   void _printCredentials() {
//     print(
//       prettyPrint(_accessToken!.toJson()),
//     );
//   }

//   Future<void> _login() async {
//     final LoginResult result = await FacebookAuth.instance
//         .login(); 
//     if (result.status == LoginStatus.success) {
//       _accessToken = result.accessToken;
//       _printCredentials();
//       final userData = await FacebookAuth.instance.getUserData();
//       _userData = userData;
//     } else {
//       print(result.status);
//       print(result.message);
//     }

//     setState(() {
//       _checking = false;
//     });
//   }

//   Future<void> _logOut() async {
//     await FacebookAuth.instance.logOut();
//     _accessToken = null;
//     _userData = null;
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Facebook Auth Example'),
//         ),
//         body: _checking
//             ? const Center(
//                 child: CircularProgressIndicator(),
//               )
//             : SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: <Widget>[
//                       Text(
//                         _userData != null
//                             ? prettyPrint(_userData!)
//                             : "NO LOGGED",
//                       ),
//                       const SizedBox(height: 20),
//                       _accessToken != null
//                           ? Text(
//                               prettyPrint(_accessToken!.toJson()),
//                             )
//                           : Container(),
//                       const SizedBox(height: 20),
//                       CupertinoButton(
//                         color: Colors.blue,
//                         child: Text(
//                           _userData != null ? "LOGOUT" : "LOGIN",
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                         onPressed: _userData != null ? _logOut : _login,
//                       ),
//                       const SizedBox(height: 50),
//                     ],
//                   ),
//                 ),
//               ),
//       ),
//     );
//   }
// }
