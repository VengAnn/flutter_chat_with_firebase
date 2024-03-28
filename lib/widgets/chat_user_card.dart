import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_wechat_firebase/data/api.dart';
import 'package:flutter_wechat_firebase/models/chat_user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_wechat_firebase/models/message_model.dart';
import 'package:flutter_wechat_firebase/views/pages/chat_page.dart';
import 'package:flutter_wechat_firebase/utils/all_color.dart';
import 'package:flutter_wechat_firebase/utils/my_date_util.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser chatUser;
  ChatUserCard({super.key, required this.chatUser});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  //last message info (if null --> no message)
  MessageModel? _messageModel;
  @override
  Widget build(BuildContext context) {
    final med_Global = MediaQuery.of(context).size;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      //color: Colors.blue.shade100,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          // for navigating to chat screen or chat page
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ChatPage(chatUser: widget.chatUser)),
          );
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.chatUser),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            // loop data json to list
            final list =
                data?.map((e) => MessageModel.fromJson(e.data())).toList() ??
                    [];
            log('list: $list');
            if (list.isNotEmpty) {
              _messageModel = list[0];
              log('_messageModel: ${_messageModel!.send}');
            }

            return ListTile(
              // user profile picture
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(med_Global.height * 0.3),
                child: CachedNetworkImage(
                  imageUrl: widget.chatUser.image,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              // user name
              title: Text(widget.chatUser.name),

              // last message
              subtitle: Text(
                  _messageModel != null
                      ? _messageModel!.type == Type.image
                          ? 'image'
                          : _messageModel!.msg!
                      : widget.chatUser.about,
                  maxLines: 1),

              // last message time
              trailing: _messageModel == null
                  ? null // show nothing when no message is sent
                  : _messageModel!.read!.isEmpty &&
                          _messageModel!.fromId != APIs.user.uid
                      ?
                      // show for unread message
                      Container(
                          width: med_Global.width * 0.03,
                          height: med_Global.height * 0.015,
                          decoration: BoxDecoration(
                            color: AllColor.pColorRed,
                            borderRadius:
                                BorderRadius.circular(med_Global.height * 0.3),
                          ),
                        )
                      :
                      //message sent time
                      Text(
                          MyDateUtil.getLastMessageTime(
                            context: context,
                            time: _messageModel!.send!,
                          ),
                          style: const TextStyle(color: Colors.black54),
                        ),
            );
          },
        ),
      ),
    );
  }
}
