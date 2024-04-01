import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_wechat_firebase/models/chat_user.dart';
import 'package:flutter_wechat_firebase/models/message_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';
import 'dart:convert';

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

  // for accessing firebase messaging (Push Notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t; // pass token
        log('Push Token: $t');
      }
    });

    //To handle messages while your application is in the foreground, listen to the onMessage stream
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        log('Got a message whilst in the foreground!');
        log('Message data: ${message.data}');

        if (message.notification != null) {
          log('Message also contained a notification: ${message.notification}');
        }
      },
    );
  }

  // for sending push notification
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.name, //our name should be send
          "body": msg,
          "android_channel_id": "chats"
        },
        // "data": {
        //   "some_data": "User ID: ${me.id}",
        // },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAPMJNynQ:APA91bFb-4FyXf0QgXn3CQibkgNkl6DPiW53NVWsOdVaZrrG09lW0wY7CMo_jofCUbY1yYQsKTanys0US7ah7hl7s5DPYHfBE2Ej9-vQ_ogyTF-NIPgZOVIAOXSg-B08EIP5fdJUOT5l'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  // for checking user exists or not?
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();

        // for setting user status to active
        APIs.updateActiveStatus(true);

        log("My data ${user.data()}");
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
      'push_token': me.pushToken,
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

    await ref.doc(time).set(messageModel.toJson()).then(
          (value) =>
              sendPushNotification(chatUser, type == Type.text ? msg : 'image'),
        );
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

  //delete message
  static Future<void> deleteMessage(MessageModel messageModel) async {
    await firestore
        .collection('chats/${getConversationID(messageModel.toId!)}/messages/')
        .doc(messageModel.send)
        .delete();
    if (messageModel.type == Type.image)
      await storage.refFromURL(messageModel.msg!).delete();
  }
}
