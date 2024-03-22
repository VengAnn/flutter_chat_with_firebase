import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wechat_firebase/components/dialog.dart';
import 'package:flutter_wechat_firebase/data/api.dart';
import 'package:flutter_wechat_firebase/models/chat_user.dart';
import 'package:flutter_wechat_firebase/pages/auth/login_page.dart';
import 'package:flutter_wechat_firebase/utils/all_color.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  final ChatUser user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String? _image; //save the path string from image gallery

  @override
  Widget build(BuildContext context) {
    final med_Global = MediaQuery.of(context).size;
    return GestureDetector(
      // for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Profile Screen"),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: med_Global.width * 0.02),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //user profile picture
                      Stack(
                        children: [
                          _image != null
                              ?
                              // local image
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      med_Global.height / 2),
                                  child: Image.file(
                                    File(_image!),
                                    width: med_Global.width * 0.6,
                                    height: med_Global.height * 0.3,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              :
                              //image from server
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      med_Global.height / 2),
                                  child: CachedNetworkImage(
                                    width: med_Global.width * 0.6,
                                    height: med_Global.height * 0.3,
                                    fit: BoxFit.cover,
                                    imageUrl: widget.user.image,
                                    errorWidget: (context, url, error) =>
                                        const CircleAvatar(
                                            child: Icon(CupertinoIcons.person)),
                                  ),
                                ),
                          //
                          Positioned(
                            bottom: 0,
                            right: 15,
                            child: MaterialButton(
                              elevation: 5,
                              shape: CircleBorder(),
                              color: AllColor.pWhiteCOlor,
                              minWidth: double.minPositive,
                              onPressed: () {
                                __showButtonSheet();
                              },
                              child: Icon(
                                Icons.edit,
                                color: AllColor.pBlueColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  //
                  SizedBox(
                    height: med_Global.height * 0.02,
                  ),
                  //show email
                  Text(
                    widget.user.email,
                    style: TextStyle(color: AllColor.pColorGrey, fontSize: 16),
                  ),
                  //
                  SizedBox(
                    height: med_Global.height * 0.02,
                  ),
                  //text form field name
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (value) => APIs.me.name = value ?? '',
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : 'Required Field',
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      hintText: "Input the name",
                      label: Text("Name"),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              width: 1.0, color: AllColor.pBlueColor)),
                    ),
                  ),
                  //
                  SizedBox(
                    height: med_Global.height * 0.02,
                  ),
                  //text form field about
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (value) => APIs.me.about = value ?? '',
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : 'Required Field',
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.info),
                      hintText: "about",
                      label: Text("about"),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              width: 1.0, color: AllColor.pBlueColor)),
                    ),
                  ),
                  //
                  SizedBox(
                    height: med_Global.height * 0.02,
                  ),
                  //button update
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AllColor.pBlueColor,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        //print('inside validate');
                        _formKey.currentState!.save();
                        APIs.udpateUserInfo();
                        Dialogs.showSnackBar(
                            context, "Profile update successfully`💖");
                      }
                    },
                    label: Text("UPDATE"),
                    icon: Icon(Icons.edit),
                  ),
                ],
              ),
            ),
          ),
        ),

        // floating button to add ...
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(right: 20),
          child: FloatingActionButton.extended(
            onPressed: () async {
              // for showing progress dialog
              Dialogs.showProgressBar(context);

              // sign out from app
              await FirebaseAuth.instance.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  // for hiding progress dialog
                  Navigator.pop(context);

                  // for moving to home screen
                  Navigator.pop(context);

                  // replacing home screen to login screen
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => LoginPage()));
                });
              });
            },
            label: Text("Logout"),
            icon: Icon(Icons.logout_outlined),
          ),
        ),
      ),
    );
  }

  //buttonSheet for picking the profile picture for user
  void __showButtonSheet() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        ),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 20, bottom: 10),
            children: [
              Text(
                "Pick Profile Picture",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              //button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //pick from gallery button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      fixedSize: Size(120, 60),
                    ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery, imageQuality: 80);
                      if (image != null) {
                        log('Image path: ${image.path} --MimeType: ${image.mimeType}');
                        setState(() {
                          _image = image.path;
                        });

                        //updating the selecting image to firebase storage
                        APIs.updateProfilePicture(File(_image!));

                        //for hiding buttonSheet
                        Navigator.pop(context);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image(
                          image: AssetImage('assets/images/add_image.png')),
                    ),
                  ),
                  //take picture from camera button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      fixedSize: Size(120, 60),
                    ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 80);
                      if (image != null) {
                        log('Image path: ${image.path}');
                        setState(() {
                          _image = image.path;
                        });

                        APIs.updateProfilePicture(File(_image!));

                        //for hiding buttonSheet
                        Navigator.pop(context);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset('assets/images/camera.png'),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }
}
