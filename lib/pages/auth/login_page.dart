import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wechat_firebase/components/dialog.dart';
import 'package:flutter_wechat_firebase/data/api.dart';
import 'package:flutter_wechat_firebase/pages/my_home_page.dart';
import 'package:flutter_wechat_firebase/utils/all_color.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  _handleGoogleBtnClick() {
    //for showing progress bar
    Dialogs.showProgressBar(context);

    _signInWithGoogle().then((user) {
      //for hiding progress bar
      Navigator.pop(context);

      if (user != null) {
        print('\nUser: ${user.user}');
        print('\nUserAdditionalInfo: ${user.additionalUserInfo}');
        //
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MyHomePage(),
          ),
        );
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('\n_signInWithGoogle: $e');
      Dialogs.showSnackBar(context, 'Something Went Wrong (Check Internet!)');
      return null;
    }
  }

  //sign out function
  // _signOut() async {
  //   await FirebaseAuth.instance.signOut();
  //   await GoogleSignIn().signOut();
  // }

  @override
  Widget build(BuildContext context) {
    var mediaQueryGlobal = MediaQuery.of(context).size;
    return Scaffold(
      // appbar
      appBar: AppBar(
        automaticallyImplyLeading: false, // hides the back button
        elevation: 1,
        backgroundColor: Colors.blue,
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
                          _handleGoogleBtnClick();
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
