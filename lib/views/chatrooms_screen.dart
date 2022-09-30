import 'package:chatting_using_firebase/helper/authenticate.dart';
import 'package:chatting_using_firebase/helper/constants.dart';
import 'package:chatting_using_firebase/helper/helperfunctions.dart';
import 'package:chatting_using_firebase/services/auth.dart';
import 'package:chatting_using_firebase/services/database.dart';
import 'package:chatting_using_firebase/views/profile.dart';
import 'package:chatting_using_firebase/views/searchscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'conversation_screen.dart';
import 'package:lottie/lottie.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({
    Key? key,
  }) : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  String? currentusertoken;
  String? lastmessage;
  var i;
  var list = 0;
  String? user;
  AuthServices authServices = AuthServices();
  HelperFunctions helperFunctions = HelperFunctions();
  DatabaseMethods databaseMethods = DatabaseMethods();
  bool logout = false;
  String? token;
  @override
  void initState() {
    getUserInfo();
    chatRoomList();
    storeNotificationToken();
    super.initState();
  }

  chatRoomList() {
    List data123456 = [];
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .orderBy("time", descending: true)
        .where("users", arrayContains: Constants.myName)
        .snapshots()
        .listen((event) {
      data123456 = event.docs;
    });
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("ChatRoom")
            .orderBy("time", descending: true)
            .where("users", arrayContains: Constants.myName)
            .snapshots(),
        builder: (context, snapchat) {
          return ListView.builder(
              itemCount: data123456.length,
              itemBuilder: (BuildContext context, int index) {
                return MessageTile(
                  userName: data123456[index]["chatRoomId"]
                      .toString()
                      .replaceAll("-", "")
                      .replaceAll(Constants.myName, ''),
                  chatRoomID: data123456[index]["chatRoomId"],
                  time: data123456[index]["time"],
                  lastmessage: data123456[index]["lastmessage"],
                  chatroomid: data123456[index]["chatRoomId"],
                  count: data123456[index][
                      data123456[index]['users'][1].toString() ==
                              Constants.myName
                          ? data123456[index]['users'][0].toString()
                          : data123456[index]['users'][1].toString()],
                );
              });
        });
  }

  storeNotificationToken() async {
    token = await FirebaseMessaging.instance.getToken();
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({'token': token}, SetOptions(merge: true));
  }

  getUserInfo() async {
    var v = await HelperFunctions.getUserNameSharedPreference();

    setState(() {
      Constants.myName = v.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    var name = Constants.myName.toUpperCase().toString();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            InkWell(
                onTap: (() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Profile(),
                    ),
                  );
                }),
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: CircleAvatar(
                    //   radius: 18,
                    child: ClipOval(
                      child: Image.network(
                        'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )),
            Text(
              " $name",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        actions: [
          InkWell(
            onTap: (() async {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Center(child: Text("Alert")),
                  content: const Text("ARE YOU SURE WANT TO LOGOUT"),
                  actions: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                          child: const Text("NO"),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            setState(() {
                              authServices.signOut();
                              authServices.googleSignOut();
                              setState(() {
                                HelperFunctions
                                    .saveUserLoggedInSharedPreference(false);
                                HelperFunctions.saveUserNameSharedPreference(
                                    "");
                                HelperFunctions.saveUserEmailSharedPreference(
                                    "");
                                HelperFunctions.saveUserUIDSharedPreference('');
                                Constants.myName = '';
                              });

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Authenticate(),
                                ),
                              );
                            });
                          },
                          child: const Text("YES"),
                        ),
                      ],
                    )
                  ],
                ),
              );
            }),
            child: Row(
              children: const [
                Text("Logout"),
                Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(Icons.exit_to_app),
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        focusColor: Colors.yellow,
        foregroundColor: Colors.white,
        hoverColor: Colors.blue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Searchscreen(),
            ),
          );
        },
        child: Center(
          child: Lottie.asset("assets/images/lf30_editor_pgavd9wm.json"),
          heightFactor: 10,
        ),
      ),
      body: Container(
          child: Stack(
        children: [
          chatRoomList(),
        ],
      )),
    );
  }
}

class MessageTile extends StatefulWidget {
  final String userName;
  final String chatRoomID;
  final String lastmessage;
  final String? chatroomid;

  var time;

  var count;
  MessageTile(
      {Key? key,
      required this.time,
      required this.userName,
      required this.chatRoomID,
      required this.lastmessage,
      required this.count,
      required this.chatroomid})
      : super(key: key);

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  DatabaseMethods databaseMethods = DatabaseMethods();
  late QuerySnapshot searchsnapshot;
  String? searchUsertoken;
  @override
  Widget build(BuildContext context) {
    String readTimestamp(int timestamp) {
      var now = DateTime.now();
      var format = DateFormat('HH:mm a');
      var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      var diff = now.difference(date);
      int millis = widget.time;
      var dt = DateTime.fromMillisecondsSinceEpoch(millis);
      var d12 = DateFormat('hh:mm a').format(dt);
      var time = '';

      if (diff.inSeconds <= 0 ||
          diff.inSeconds > 0 && diff.inMinutes == 0 ||
          diff.inMinutes > 0 && diff.inHours == 0 ||
          diff.inHours > 0 && diff.inDays == 0) {
        //  time = format.format(date);
        time = d12;
      } else if (diff.inDays > 0 && diff.inDays < 7) {
        if (diff.inDays == 1) {
          time = diff.inDays.toString() + ' DAY AGO';
        } else {
          time = diff.inDays.toString() + ' DAYS AGO';
        }
      } else {
        if (diff.inDays == 7) {
          time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
        } else {
          time = (diff.inDays / 7).floor().toString() + ' WEEKS AGO';
        }
      }

      return time;
    }

    return GestureDetector(
      onTap: (() async {
        Map<String, dynamic> timemap = {"read ": true, widget.userName: 0};
        databaseMethods.uploadtime(
          timemap,
          widget.chatRoomID,
        );
        await databaseMethods.getUserByUserName(widget.userName).then((value) {
          setState(() {
            searchsnapshot = value;
          });
          searchsnapshot = value;

          searchUsertoken = searchsnapshot.docs[0]["token"];
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationScreen(
              chatRoomId: widget.chatRoomID.toString(),
              searchResultName: widget.userName,
              searchUserToken: searchUsertoken!,
            ),
          ),
        );
      }),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
        child: Center(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(50)),
                  child: Center(
                    child: Text(
                      widget.userName.substring(0, 1).toUpperCase(),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.01,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.31,
                    child: Text(
                      widget.userName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  Text(
                    widget.lastmessage,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ]),
            Column(
              children: [
                widget.count == 0
                    ? const SizedBox()
                    : Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(50)),
                        child: Center(
                          child: Text(
                            widget.count.toString(),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                Text(
                  //d12,
                  readTimestamp(widget.time),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        )),
      ),
    );
  }
}
