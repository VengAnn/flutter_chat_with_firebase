import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_wechat_firebase/components/dialog.dart';
import 'package:flutter_wechat_firebase/data/api.dart';
import 'package:flutter_wechat_firebase/models/chat_user.dart';
import 'package:flutter_wechat_firebase/views/pages/profile_page.dart';
import 'package:flutter_wechat_firebase/utils/all_color.dart';
import 'package:flutter_wechat_firebase/widgets/chat_user_card.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // storing all users
  List<ChatUser> _listUser = [];

  // storing searched items
  List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();

    APIs.getSelfInfo();

    //for updating user active status according to lifecycle events
    //resume -- active or online
    //pause -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }

        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false); //it's mean offline
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding the the focus textField search  or hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      // ignore: deprecated_member_use
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            _isSearching = !_isSearching;
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 1,
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: () {},
              icon: Icon(Icons.home_outlined),
            ),
            centerTitle: true,
            title: _isSearching
                ? TextField(
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: "Name, Email, ..."),
                    autofocus: true,
                    style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                    // when search text changes then updated search list
                    onChanged: (value) {
                      // search logic
                      _searchList.clear();

                      for (var i in _listUser) {
                        if (i.name
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            i.email
                                .toLowerCase()
                                .contains(value.toLowerCase())) {
                          _searchList.add(i);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                  )
                : Text("We Chat"),
            actions: [
              //search user button
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(_isSearching
                    ? CupertinoIcons.clear_circled_solid
                    : Icons.search),
              ),

              // more feature button
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ProfilePage(
                              user: APIs.me,
                            )),
                  );
                },
                icon: Icon(Icons.more_vert_outlined),
              ),
            ],
          ),

          body: StreamBuilder(
            stream: APIs.getMyusersId(),
            // Get id only known users
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
              // If data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());

              // If some or all data is loaded, then show it
                case ConnectionState.active:
                case ConnectionState.done:
                // Ensure snapshot has data and is not null
                  if (snapshot.hasData && snapshot.data?.docs != null) {
                    final userIds = snapshot.data?.docs.map((e) => e.id).toList() ?? [];

                    // If the userIds list is empty, show a message
                    if (userIds.isEmpty) {
                      return Center(child: Text("No users found to display!"));
                    }

                    // If userIds are available, query Firestore
                    return StreamBuilder(
                      stream: APIs.getAllUsers(userIds),
                      // Get only those users, whose ids are provided
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                        // If data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const Center(
                                child: CircularProgressIndicator());

                        // If some or all data is loaded then show it
                          case ConnectionState.active:
                          case ConnectionState.done:
                          // Ensure snapshot has data and is not null
                            if (snapshot.hasData && snapshot.data?.docs != null) {
                              final data = snapshot.data!.docs;
                              _listUser = data
                                  .map((e) => ChatUser.fromJson(e.data()))
                                  .toList();

                              if (_listUser.isNotEmpty) {
                                // List view builder
                                return ListView.builder(
                                  itemCount: _isSearching
                                      ? _searchList.length
                                      : _listUser.length,
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return ChatUserCard(
                                        chatUser: _isSearching
                                            ? _searchList[index]
                                            : _listUser[index]);
                                  },
                                );
                              } else {
                                return const Center(child: Text("No connections found!"));
                              }
                            } else {
                              return const Center(child: Text("No data found!"));
                            }
                        }
                      },
                    );
                  } else {
                    return const Center(child: Text("No user IDs found!"));
                  }
              }
            },
          ),

          // floating button to add ...
          floatingActionButton: GestureDetector(
            onTap: () async {
              _addChatUserDialog();
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AllColor.pBlueColor,
              ),
              child: Icon(
                Icons.add_comment,
                color: AllColor.pWhiteCOlor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // for adding new chat user
  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: Row(
                children: const [
                  Icon(
                    Icons.person_add,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text('  Add User')
                ],
              ),

              //content
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Email Id',
                    prefixIcon: const Icon(Icons.email, color: Colors.blue),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.blue, fontSize: 16))),

                //add button
                MaterialButton(
                    onPressed: () async {
                      //hide alert dialog
                      Navigator.pop(context);

                      if (email.isNotEmpty) {
                        bool userAdded = await APIs.addChatUser(email);
                        if (userAdded) {
                          Dialogs.showSnackBar(context, 'User Added Successfully!');
                        } else {
                          Dialogs.showSnackBar(context, 'User Not Found or Cannot Add!');
                        }
                      }
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
  }
}
