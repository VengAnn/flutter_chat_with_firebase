import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wechat_firebase/data/api.dart';
import 'package:flutter_wechat_firebase/models/chat_user.dart';
import 'package:flutter_wechat_firebase/models/message_model.dart';
import 'package:flutter_wechat_firebase/utils/all_color.dart';
import 'package:flutter_wechat_firebase/utils/my_date_util.dart';
import 'package:flutter_wechat_firebase/views/pages/view_profile_page.dart';
import 'package:flutter_wechat_firebase/widgets/message_card.dart';
import 'package:image_picker/image_picker.dart';

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

  // Define a FocusNode
  final FocusNode _textFocusNode = FocusNode();

  @override
  void dispose() {
    // Dispose the FocusNode
    _textFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final med_Global = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        //close text field or keyboard
        FocusScope.of(context).unfocus();
      },
      // ignore: deprecated_member_use
      child: WillPopScope(
        //if emojis are shown & back button is pressed then hide emojis
        //or else simple close current screen on back button click
        onWillPop: () {
          if (_showEmoji) {
            setState(() {
              _showEmoji = !_showEmoji;
            });

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
                                  ?.map((e) => MessageModel.fromJson(e.data()))
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
                //progress indicator showing uploading image when select uploading it's true
                if (_isUploading)
                  Align(
                    alignment: Alignment.centerRight,
                    child: CircularProgressIndicator(strokeWidth: 2),
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
    );
  }

  // app bar widget
  Widget _appBar(med_Global) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ViewProfilePage(chatUser: widget.chatUser)));
      },
      child: StreamBuilder(
          stream: APIs.getUserInfo(widget.chatUser),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final listUserInfo =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
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
                //user name & last seen time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //user name
                    Text(
                      listUserInfo.isNotEmpty
                          ? listUserInfo[0].name
                          : widget.chatUser.name,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500),
                    ),
                    //last seen time of user
                    Text(
                      listUserInfo.isNotEmpty
                          ? listUserInfo[0].isOnline
                              ? 'Online'
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: listUserInfo[0].lastActive)
                          : MyDateUtil.getLastActiveTime(
                              context: context,
                              lastActive: widget.chatUser.lastActive),
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            );
          }),
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
                      log('emoji ${_showEmoji}');
                      if (_showEmoji) {
                        // Close the original keyboard
                        FocusScope.of(context).unfocus();
                      }
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
                    onTap: () {
                      // Close the showEmoji when TextField is tapped
                      if (_showEmoji) {
                        setState(() {
                          _showEmoji = false;
                        });
                      }
                    },
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
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();

                    final List<XFile> images =
                        await picker.pickMultiImage(imageQuality: 70);

                    for (var i in images) {
                      // ignore: unnecessary_null_comparison
                      if (images != null) {
                        log('Image path: ${i.path}');
                        setState(() => _isUploading = true);
                        await APIs.sendChatImage(widget.chatUser, File(i.path));

                        //
                        setState(() => _isUploading = false);
                      }
                    }
                  },
                  icon: Icon(Icons.image, color: AllColor.pBlueColor),
                ),
                // take image from camera button
                IconButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();

                    final XFile? image = await picker.pickImage(
                        source: ImageSource.camera, imageQuality: 70);
                    if (image != null) {
                      log('Image path: ${image.path}');
                      setState(() => _isUploading = true);

                      await APIs.sendChatImage(
                        widget.chatUser,
                        File(image.path),
                      );
                      //
                      setState(() => _isUploading = false);
                    }
                  },
                  icon: Icon(
                    Icons.camera_alt_rounded,
                    color: AllColor.pBlueColor,
                  ),
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
              if (_listMessage.isEmpty) {
                //on first message (add user to my_user collection of chat users)
                APIs.sendFirstMessage(widget.chatUser,
                    _textMessageInputController.text, Type.text);
              } else {
                //simply send message
                APIs.sendMessage(widget.chatUser,
                    _textMessageInputController.text, Type.text);
              }
              _textMessageInputController.text = '';
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
