import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wechat_firebase/data/api.dart';
import 'package:flutter_wechat_firebase/models/chat_user.dart';
import 'package:flutter_wechat_firebase/models/message_model.dart';
import 'package:flutter_wechat_firebase/utils/all_color.dart';
import 'package:flutter_wechat_firebase/widgets/message_card.dart';
import 'package:flutter/foundation.dart' as foundation;

class ChatPage extends StatefulWidget {
  final ChatUser chatUser;

  const ChatPage({
    super.key,
    required this.chatUser,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // for storing all messages
  List<MessageModel> _listMessage = [];

  // for handling message text change
  final _textMessageInputController = TextEditingController();

  //showEmoji -- for storing value of showing or hiding emoji
  //isUploading -- for checking if image is uploading or not?
  bool _showEmoji = false, _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final med_Global = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          //if emojis are shown & back button is pressed then hide emojis
          //or else simple close current screen on back button click
          onWillPop: () {
            if (_showEmoji) {
              setState(() => _showEmoji = !_showEmoji);
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              elevation: 2.0,
              flexibleSpace: SafeArea(child: _appBar(med_Global)),
            ),
            body: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder(
                      stream: APIs.getAllMessage(widget.chatUser),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          // if data loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const SizedBox();

                          // if some or all data is loaded then show it
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            // if (data != null && data.isNotEmpty) {
                            //   log('data ${jsonEncode(data[0].data())}');
                            // }

                            _listMessage = data
                                    ?.map(
                                        (e) => MessageModel.fromJson(e.data()))
                                    .toList() ??
                                [];

                            if (_listMessage.isNotEmpty) {
                              // list view builder
                              return ListView.builder(
                                itemCount: _listMessage.length,
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return MessageCard(
                                      messageModel: _listMessage[index]);
                                },
                              );
                            } else {
                              return Center(
                                child: Text(
                                  'Say Hii! 👋',
                                  style: TextStyle(fontSize: 20),
                                ),
                              );
                            }
                        }
                      },
                    ),
                  ),

                  ///bottom chat input field
                  _chatInput(),
                  //
                  //show emojis on keyboard emoji button click & vice versa
                  if (_showEmoji)
                    SizedBox(
                      height: med_Global.height * .35,
                      child: EmojiPicker(
                        textEditingController: _textMessageInputController,
                        config: Config(
                          bgColor: const Color.fromARGB(255, 234, 248, 255),
                          columns: 8,
                          emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // app bar widget
  Widget _appBar(med_Global) {
    return Row(
      children: [
        //button back
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: AllColor.pBlackCOlor,
            ),
          ),
        ),

        //user profile picture
        ClipRRect(
          borderRadius: BorderRadius.circular(med_Global.height * 0.1),
          child: CachedNetworkImage(
            width: med_Global.height * 0.06,
            height: med_Global.height * 0.06,
            fit: BoxFit.cover,
            imageUrl: widget.chatUser.image,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
        //add some spacing
        SizedBox(width: 5.0),
        //
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${widget.chatUser.name}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AllColor.pBlackCOlor,
                fontSize: 20,
              ),
            ),
            Text("Last Screnn on 1 dec 2024"),
          ],
        ),
      ],
    );
  }

  //bottom chat input field
  Widget _chatInput() {
    return Row(
      children: [
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            child: Row(
              children: [
                // emoji button
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showEmoji = !_showEmoji;
                    });
                  },
                  icon: Icon(
                    Icons.emoji_emotions,
                    color: AllColor.pBlackCOlor,
                  ),
                ),
                //
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: _textMessageInputController,
                    decoration: InputDecoration(
                      hintText: "Type something...",
                      hintStyle: TextStyle(color: AllColor.pBlueColor),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                // pick image from gallery button
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.image, color: AllColor.pBlueColor),
                ),
                // pick image from camera button
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.camera_alt_rounded,
                      color: AllColor.pBlueColor),
                ),
              ],
            ),
          ),
        ),

        //button send message
        MaterialButton(
          padding: EdgeInsets.all(10.0),
          color: AllColor.pGreenColor,
          minWidth: 0,
          shape: CircleBorder(),
          onPressed: () {
            if (_textMessageInputController.text.isNotEmpty) {
              APIs.sendMessage(
                  widget.chatUser, _textMessageInputController.text);
              _textMessageInputController.text = "";
            }
          },
          child: Icon(
            Icons.send,
            color: AllColor.pWhiteCOlor,
          ),
        ),
      ],
    );
  }
}
