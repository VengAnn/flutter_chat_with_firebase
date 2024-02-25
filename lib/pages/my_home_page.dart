import 'package:flutter/material.dart';
import 'package:flutter_wechat_firebase/utils/all_color.dart';

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
      // floating button to add ...
      floatingActionButton: Container(
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
    );
  }
}
