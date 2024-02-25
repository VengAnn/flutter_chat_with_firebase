import 'package:flutter/material.dart';
import 'package:flutter_wechat_firebase/pages/my_home_page.dart';
import 'package:flutter_wechat_firebase/utils/all_color.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isAnimated = false;

  @override
  void initState() {
    super.initState();
    // delay for see animation when show this page or screen
    Future.delayed(
      const Duration(milliseconds: 500),
      () {
        setState(() {
          _isAnimated = true;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var mediaQueryGlobal = MediaQuery.of(context).size;
    return Scaffold(
      // appbar
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text("Welcome We Chat"),
      ),
      //body
      body: Stack(
        children: [
          // this use animated Positioned
          AnimatedPositioned(
            top: mediaQueryGlobal.height * 0.1,
            right: _isAnimated
                ? mediaQueryGlobal.width * 0.31
                : -mediaQueryGlobal.width * 0.5,
            duration: Duration(seconds: 2),
            // image logo chat
            child: Image(
              width: mediaQueryGlobal.width * 0.3,
              image: AssetImage("assets/image_icon_launcher/chat_box.png"),
              fit: BoxFit.cover,
            ),
          ),
          //this row for elevatedButton sign with google
          Positioned(
            top: mediaQueryGlobal.height * 0.5,
            child: SizedBox(
              width: mediaQueryGlobal.width, //set mix width
              child: Padding(
                padding: EdgeInsets.all(mediaQueryGlobal.width * 0.02),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // this button login elevatedButton
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AllColor.pGreenColor.withAlpha(7),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MyHomePage(),
                            ),
                          );
                        },
                        icon: Padding(
                          padding:
                              EdgeInsets.all(mediaQueryGlobal.width * 0.02),
                          child: Image(
                            width: mediaQueryGlobal.width * 0.1,
                            image: AssetImage("assets/images/google.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        label: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Login with ",
                                style: TextStyle(
                                  color: AllColor.pBlackCOlor,
                                ),
                              ),
                              // this textSpan google
                              TextSpan(
                                text: "Google",
                                style: TextStyle(
                                  color: AllColor.pBlackCOlor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
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
