import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_wechat_firebase/models/chat_user.dart';

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing clound firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // for storing self information
  static late ChatUser me;

  // to return current user
  static User get user => auth.currentUser!;

  // for checking user exists or not?
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        log("my data ${user.data()}");
      } else {
        await creatUser().then((value) => getSelfInfo());
      }
    });
  }

  // for creating a new user
  static Future<void> creatUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    final chatUser = ChatUser(
      image: user.photoURL.toString(),
      name: user.displayName.toString(),
      about: "Hey, I'm using weChat!",
      isOnline: false,
      lastActive: time,
      id: user.uid,
      createAt: time,
      email: user.email.toString(),
      pushToken: '',
    );

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // for getting all users form firebase database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore.collection('users').snapshots();
  }

  // for updating user information
  static Future<void> udpateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  // update profile picture of user
  static Future<void> updateProfilePicture(File file) async {
    try {
      // Getting image file extension
      final ext = file.path.split('.').last;
      log('Extension: $ext');

      // Storage file ref with path
      final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');
      log('ref ext');

      // Uploading image
      await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
      log('Image uploaded successfully');

      // Updating image in Firestore database
      me.image = await ref.getDownloadURL();
      await firestore
          .collection('users')
          .doc(user.uid)
          .update({'image': me.image});
      log('Image URL updated in Firestore');
    } catch (error) {
      log('Error updating profile picture: $error');
    }
  }
}
