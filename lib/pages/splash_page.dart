import 'package:flutter/material.dart';
import 'package:flutter_wechat_firebase/pages/my_home_page.dart';
import 'package:flutter_wechat_firebase/utils/all_color.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  // run when app start on this page initstate the first run
  @override
  void initState() {
    super.initState();
    //delay splash screen
    Future.delayed(
      Duration(seconds: 3),
      () {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => MyHomePage()));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var mediaQueryGlobal = MediaQuery.of(context).size;
    return Scaffold(
      //body
      body: Stack(
        children: [
          // this use animated Positioned
          Positioned(
            top: mediaQueryGlobal.height * 0.2,
            right: mediaQueryGlobal.width * 0.31,

            // image logo chat
            child: Image(
              width: mediaQueryGlobal.width * 0.3,
              image: AssetImage("assets/image_icon_launcher/chat_box.png"),
              fit: BoxFit.cover,
            ),
          ),
          //this text
          Positioned(
            top: mediaQueryGlobal.height * 0.7,
            child: Container(
              width: mediaQueryGlobal.width, //set mix width
              child: Padding(
                padding: EdgeInsets.all(mediaQueryGlobal.width * 0.02),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "MADE IN CAMBODIA",
                            style: TextStyle(
                              color: AllColor.pBlackCOlor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
