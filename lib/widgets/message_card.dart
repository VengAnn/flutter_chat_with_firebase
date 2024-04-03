import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_wechat_firebase/components/dialog.dart';
import 'package:flutter_wechat_firebase/data/api.dart';
import 'package:flutter_wechat_firebase/models/message_model.dart';
import 'package:flutter_wechat_firebase/utils/all_color.dart';
import 'package:flutter_wechat_firebase/utils/my_date_util.dart';
import 'package:gallery_saver/gallery_saver.dart';

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
    bool isMe = APIs.user.uid == widget.messageModel.fromId;
    return InkWell(
      onTap: () {
        //close text field or keyboard
        FocusScope.of(context).unfocus();
      },
      onLongPress: () {
        _showBottomSheet(isMe);
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
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
            child: widget.messageModel.type == Type.text
                ?
                // show text
                Text(
                    widget.messageModel.msg!,
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.black,
                    ),
                  )
                :
                //show image
                ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.messageModel.msg!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image, size: 70),
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
    final med_Global = MediaQuery.of(context).size;

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
            child: widget.messageModel.type == Type.text
                ?
                // show text
                Text(
                    "${widget.messageModel.msg!}",
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.black,
                    ),
                  )
                :
                //show image
                ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.messageModel.msg!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image, size: 70),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // bottom sheet for modifying message details
  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
      context: context,
      builder: (DialogContext) {
        return ListView(
          shrinkWrap: true,
          children: [
            // black divider
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(horizontal: 150.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            //add some space
            SizedBox(height: 10.0),

            widget.messageModel.type == Type.text
                ?
                //copy option
                _OptionItem(
                    icon: Icon(
                      Icons.copy_all_outlined,
                      size: 26,
                      color: Colors.blue,
                    ),
                    name: "Copy Text",
                    onTap: () async {
                      log('pressed copy');
                      await Clipboard.setData(
                              ClipboardData(text: widget.messageModel.msg!))
                          .then((value) {
                        // for hiding button sheet
                        Navigator.pop(DialogContext);

                        Dialogs.showSnackBar(DialogContext, 'Text copied!');
                      });
                    },
                  )
                :
                //save image
                _OptionItem(
                    icon: Icon(
                      Icons.download_for_offline,
                      size: 26,
                      color: Colors.blue,
                    ),
                    name: "Save Image",
                    onTap: () async {
                      try {
                        log('Image Url: ${widget.messageModel.msg}');
                        await GallerySaver.saveImage(widget.messageModel.msg!,
                                albumName: 'We Chat')
                            .then((success) {
                          //for hiding bottom sheet
                          Navigator.pop(context);
                          if (success != null && success) {
                            Dialogs.showSnackBar(
                                context, 'Image Successfully Saved!');
                          }
                        });
                      } catch (e) {
                        log('ErrorWhileSavingImg: $e');
                      }
                    },
                  ),

            if (isMe)
              //seperator or divider
              Divider(
                color: Colors.black,
                endIndent: 20,
                indent: 20,
              ),

            if (widget.messageModel.type == Type.text && isMe)
              //edit option
              _OptionItem(
                icon: Icon(
                  Icons.edit,
                  size: 26,
                  color: Colors.blue,
                ),
                name: "Edit Message",
                onTap: () {
                  //for hiding bottom sheet
                  Navigator.pop(context);

                  _showMessageUpdateDialog();
                },
              ),

            if (isMe)
              //Delete option
              _OptionItem(
                icon: Icon(
                  Icons.delete_forever,
                  size: 26,
                  color: Colors.red,
                ),
                name: "Delete Message",
                onTap: () async {
                  await APIs.deleteMessage(widget.messageModel).then((value) {
                    //for hiding bottom sheet
                    Navigator.pop(context);
                    //
                  });
                },
              ),

            //seperator or divider
            Divider(
              color: Colors.black,
              endIndent: 20,
              indent: 20,
            ),

            //send time
            _OptionItem(
              icon: Icon(
                Icons.remove_red_eye,
                size: 26,
                color: Colors.blue,
              ),
              name: "Sent At: ${MyDateUtil.getMessageTime(
                context: DialogContext,
                time: widget.messageModel.send!,
              )}",
              onTap: () {},
            ),

            //read time
            _OptionItem(
              icon: Icon(
                Icons.remove_red_eye,
                size: 26,
                color: Colors.green,
              ),
              name: widget.messageModel.read!.isEmpty
                  ? "Read At: Not seen yet"
                  : "Read At: ${MyDateUtil.getMessageTime(context: DialogContext, time: widget.messageModel.read!)}",
              onTap: () {},
            ),
          ],
        );
      },
    );
  }

  // dialog update message content
  void _showMessageUpdateDialog() {
    String updatedMsg = widget.messageModel.msg!;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          // title
          title: Row(
            children: [
              Icon(
                Icons.message,
                color: Colors.blue,
                size: 29,
              ),
              Text('Update Message'),
            ],
          ),

          // content
          content: TextFormField(
            initialValue: updatedMsg,
            maxLines: null,
            onChanged: (value) => updatedMsg = value,
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
            ),
          ),

          // actions
          actions: [
            // cancel button
            MaterialButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
            //update button
            MaterialButton(
              onPressed: () {
                //hide alert dialog
                Navigator.pop(dialogContext);

                APIs.updateMessage(widget.messageModel, updatedMsg);
              },
              child: const Text(
                'Update',
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }
}

//
class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final Function()? onTap;

  const _OptionItem({
    required this.icon,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 15.0, bottom: 15.0, top: 10.0),
        child: Row(
          children: [
            icon,
            Flexible(
              child: Text(
                '     $name',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
