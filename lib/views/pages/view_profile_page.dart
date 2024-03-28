import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wechat_firebase/models/chat_user.dart';
import 'package:flutter_wechat_firebase/utils/my_date_util.dart';

class ViewProfilePage extends StatefulWidget {
  final ChatUser chatUser;

  const ViewProfilePage({
    super.key,
    required this.chatUser,
  });

  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  @override
  Widget build(BuildContext context) {
    final med_Global = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.chatUser.name),
      ),
      //body
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: SizedBox(
          height: double.maxFinite,
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //show profile
              ClipRRect(
                borderRadius: BorderRadius.circular(med_Global.height * 0.1),
                child: CachedNetworkImage(
                  width: med_Global.height * 0.2,
                  height: med_Global.height * 0.2,
                  fit: BoxFit.cover,
                  imageUrl: widget.chatUser.image,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              //email
              Text(
                widget.chatUser.email,
                style: TextStyle(
                  fontSize: 19,
                ),
              ),
              //add some space
              SizedBox(height: 10.0),
              //show about infoo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'About: ',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.chatUser.about,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Spacer(),
              //Joined on
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Joined on: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    MyDateUtil.getLastMessageTime(
                      context: context,
                      time: widget.chatUser.createAt,
                      showYear: true,
                    ),
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
