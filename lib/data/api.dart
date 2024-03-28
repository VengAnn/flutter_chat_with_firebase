import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_wechat_firebase/models/chat_user.dart';
import 'package:flutter_wechat_firebase/models/message_model.dart';

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
    final time = DateTime.now().millisecondsSinceEpoch.toString();

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
  static Future<void> updateUserInfo() async {
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

  //for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

  ///
  ///
  ///**************Chat Screen Related APIS ************///
  // chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc)

  // useful for getting conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for getting all message of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessage(
      ChatUser chatUserc) {
    return firestore
        .collection('chats/${getConversationID(chatUserc.id)}/messages')
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    // message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // message to send
    final MessageModel messageModel = MessageModel(
      toId: chatUser.id,
      fromId: user.uid,
      msg: msg,
      read: '',
      send: time,
      type: type,
    );

    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');

    await ref.doc(time).set(messageModel.toJson());
  }

  // update read status of message
  static Future<void> updateMessageReadStatus(MessageModel messageModel) async {
    firestore
        .collection('chats/${getConversationID(messageModel.fromId!)}/messages')
        .doc(messageModel.send)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser chatUser) {
    return firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages')
        .orderBy('send', descending: true) //it's mean big to small
        .limit(1) // get only one is big or highest value
        .snapshots();
  }

  //send chat image to firebase for storing image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    try {
      // getting image file extension
      final ext = file.path.split('.').last; //ext like png jpg or ...

      final ref = storage.ref().child(
          'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

      // Uploading image
      await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
      log('Image uploaded successfully');

      // updating image in firestore database
      final imageUrl = await ref.getDownloadURL();
      await sendMessage(chatUser, imageUrl, Type.image);
      log('sucessfully send Image Message');
    } catch (error, stackTrace) {
      log('Error uploading image: $error');
      log('Stack trace: $stackTrace');
    }
  }

  //
}
