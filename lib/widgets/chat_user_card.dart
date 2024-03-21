import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_wechat_firebase/models/chat_user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_wechat_firebase/utils/all_color.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    final med_Global = MediaQuery.of(context).size;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      //color: Colors.blue.shade100,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {},
        child: ListTile(
          // user profile picture
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(med_Global.height * 0.3),
            child: CachedNetworkImage(
              imageUrl: widget.user.image,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
          // user name
          title: Text(widget.user.name),

          // last message
          subtitle: Text(widget.user.about, maxLines: 1),

          // last message time
          trailing: Container(
            width: med_Global.width * 0.03,
            height: med_Global.height * 0.015,
            decoration: BoxDecoration(
              color: AllColor.pColorRed,
              borderRadius: BorderRadius.circular(med_Global.height * 0.3),
            ),
          ),
        ),
      ),
    );
  }
}
