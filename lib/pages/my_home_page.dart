import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wechat_firebase/data/api.dart';
import 'package:flutter_wechat_firebase/utils/all_color.dart';
import 'package:flutter_wechat_firebase/widgets/chat_user_card.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.home_outlined),
        ),
        centerTitle: true,
        title: Text("We Chat"),
        actions: [
          // search button
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search),
          ),
          // more feature button
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert_outlined),
          ),
        ],
      ),

      body: StreamBuilder(
        stream: APIs.firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data?.docs;
            for (var i in data!) {
              log('Data: ${i.data()}');
            }
          } else if (snapshot.hasError) {
            log('Error: ${snapshot.error}');
          }
          return ListView.builder(
            itemCount: 16,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return ChatUserCard();
            },
          );
        },
      ),
      // floating button to add ...
      floatingActionButton: GestureDetector(
        onTap: () async {
          await FirebaseAuth.instance.signOut();
          await GoogleSignIn().signOut();
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AllColor.pBlueColor,
          ),
          child: Icon(
            Icons.add_comment,
            color: AllColor.pWhiteCOlor,
          ),
        ),
      ),
    );
  }
}
