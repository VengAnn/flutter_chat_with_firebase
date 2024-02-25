import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_wechat_firebase/pages/splash_page.dart';
import 'firebase_options.dart';

// async return obj future
// async* return obj stream
Future<void> _initializeFirebare() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  //set full screen for show see splash screen full
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  //for setting orientation to portraint only
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {
    _initializeFirebare();
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'We Chat',
      theme: ThemeData(),
      home: SplashPage(),
    );
  }
}
