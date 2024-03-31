import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wechat_firebase/models/chat_user.dart';
import 'package:flutter_wechat_firebase/utils/all_color.dart';
import 'package:flutter_wechat_firebase/views/pages/view_profile_page.dart';

class ProfileDialog extends StatelessWidget {
  final ChatUser chatUser;
  const ProfileDialog({
    super.key,
    required this.chatUser,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      content: SizedBox(
        width: 80,
        height: 220,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  //user name
                  Text(
                    chatUser.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  Spacer(),
                  //button info
                  GestureDetector(
                    onTap: () {
                      //for hiding image dialog
                      Navigator.pop(context);

                      //move to view profile screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ViewProfilePage(chatUser: chatUser),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.info_outline,
                      color: AllColor.pBlueColor,
                      size: 30,
                    ),
                  ),
                ],
              ),
              //profile image
              ClipRRect(
                borderRadius: BorderRadius.circular(80),
                child: CachedNetworkImage(
                  width: 150,
                  fit: BoxFit.cover,
                  imageUrl: chatUser.image,
                  errorWidget: (context, url, error) =>
                      const CircleAvatar(child: Icon(CupertinoIcons.person)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
