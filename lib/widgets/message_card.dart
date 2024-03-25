import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wechat_firebase/data/api.dart';
import 'package:flutter_wechat_firebase/models/message_model.dart';
import 'package:flutter_wechat_firebase/utils/all_color.dart';
import 'package:flutter_wechat_firebase/utils/my_date_util.dart';

class MessageCard extends StatefulWidget {
  final MessageModel messageModel;

  const MessageCard({
    super.key,
    required this.messageModel,
  });

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.messageModel.fromId
        ? _greenMessage()
        : _blueMessage();
  }

  // sender or another user message
  Widget _blueMessage() {
    // update last read message if sender and reciever are different
    if (widget.messageModel.read!.isEmpty) {
      APIs.updateMessageReadStatus(widget.messageModel);
      log('message read updated');
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // message content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.cyanAccent,
              border: Border.all(color: Colors.lightBlue),
              // making borders curved
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Text(
              widget.messageModel.msg!,
              style: TextStyle(
                fontSize: 15.0,
                color: Colors.black,
              ),
            ),
          ),
        ),
        //message time send
        Text(
          //formate date time string
          MyDateUtil.getFormattedTime(
            context: context,
            time: widget.messageModel.send!,
          ),
          style: TextStyle(fontSize: 13, color: AllColor.pBlackCOlor),
        ),
      ],
    );
  }

  // our or user message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //message time send
        Row(
          children: [
            //double tick blue icon for message read
            if (widget.messageModel.read!.isNotEmpty)
              Icon(Icons.done_all_rounded, color: Colors.blue),

            // add some space
            SizedBox(width: 5.0),

            // send time
            Text(
              //formate date time string
              MyDateUtil.getFormattedTime(
                context: context,
                time: widget.messageModel.send!,
              ),
              style: TextStyle(fontSize: 13, color: AllColor.pBlackCOlor),
            ),
          ],
        ),

        // message content
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 141, 216, 144),
              border: Border.all(color: Colors.lightBlue),
              // making borders curved
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Text(
              "${widget.messageModel.msg!}",
              style: TextStyle(
                fontSize: 15.0,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
