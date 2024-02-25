import 'package:flutter/material.dart';
import 'package:flutter_wechat_firebase/pages/auth/login_page.dart';
import 'package:flutter_wechat_firebase/pages/my_home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_wechat_firebase/pages/splash_page.dart';
import 'firebase_options.dart';

_initializeFirebare() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _initializeFirebare();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'We Chat',
      theme: ThemeData(),
      // home: MyHomePage(),
      home: SplashPage(),
    );
  }
}
