import 'dart:developer';

import 'package:chatting_using_firebase/services/auth.dart';
import 'package:chatting_using_firebase/services/database.dart';
import 'package:chatting_using_firebase/views/chatrooms_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import '../helper/helperfunctions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInScreen extends StatefulWidget {
  final Function toggleView;
  const SignInScreen(this.toggleView, {Key? key}) : super(key: key);
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  QuerySnapshot? snapshotUserInfo;
  DatabaseMethods databaseMethods = DatabaseMethods();
  AuthServices authServices = AuthServices();
  final formKey = GlobalKey<FormState>();
  TextEditingController emailTextEditingcontroller = TextEditingController();
  TextEditingController passwordTextEditingcontroller = TextEditingController();
  bool isLoading = false;
  String? usernamefromsignin;
  late GoogleSignInAccount _userObj;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  var userUID;
  googleSigin() {
    setState(() {
      isLoading = true;
    });
    var googlesignIncredentials = authServices.signInWithGoogle();
    googlesignIncredentials.then((value) async {
      var v = value;
      userUID = v.user!.uid;
      log(userUID.toString());
      Map<String, String> userInfoMap = {
        "name": v.user!.providerData[0].displayName!,
        "email": v.user!.providerData[0].email!,
      };
      databaseMethods.uploadUserInfo(userInfoMap, userUID);
      setState(() {
        isLoading = true;
        HelperFunctions.saveUserLoggedInSharedPreference(true);
        HelperFunctions.saveUserEmailSharedPreference(
            v.user!.providerData[0].email!);
        HelperFunctions.saveUserNameSharedPreference(
            v.user!.providerData[0].displayName!);
        HelperFunctions.saveUserUIDSharedPreference(userUID!);
      });
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const ChatRoom()));
    });
  }

  signIn() {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      authServices
          .signinWithEmailAndPassword(emailTextEditingcontroller.text,
              passwordTextEditingcontroller.text)
          .then((value) {
        if (value != null) {
          print("FIREBASE RESPONSE...............");
          print(value.toString());
          if (value.toString() == "Instance of 'Usermodel'") {
          } else {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Center(child: Text("Alert")),
                content: Text(value.toString()),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      setState(() {
                        isLoading = false;
                      });
                    },
                    child: const Text("close"),
                  ),
                ],
              ),
            );
          }
        }

        if (value != null) {
          databaseMethods
              .getUserByUserEmail(emailTextEditingcontroller.text)
              .then((value) async {
            snapshotUserInfo = value;
            HelperFunctions.saveUserNameSharedPreference(
                snapshotUserInfo?.docs[0]["name"]);
            print(usernamefromsignin);
            setState(() {
              isLoading = true;
              HelperFunctions.saveUserEmailSharedPreference(
                  emailTextEditingcontroller.text);
              HelperFunctions.saveUserLoggedInSharedPreference(true);
              HelperFunctions.saveSearchUserNameSharedPreference('');
            });

            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const ChatRoom()));
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chatting using Firebase",
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Builder(builder: (context) {
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 50,
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child:
                                Lottie.asset("assets/images/loginlottie.json"),
                          ),
                          TextFormField(
                            controller: emailTextEditingcontroller,
                            validator: (value) {
                              return RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(value!)
                                  ? null
                                  : "Please Enter valid Email";
                            },
                            onChanged: (val) {
                              final trimVal = val.trim();
                              if (val != trimVal) {
                                setState(() {
                                  emailTextEditingcontroller.text = trimVal;
                                  emailTextEditingcontroller.selection =
                                      TextSelection.fromPosition(
                                          TextPosition(offset: trimVal.length));
                                });
                              }
                            },
                            decoration: const InputDecoration(
                                hintText: "Email",
                                hintStyle: TextStyle(color: Colors.black)),
                          ),
                          TextFormField(
                            onChanged: (val) {
                              final trimVal = val.trim();
                              if (val != trimVal) {
                                setState(() {
                                  emailTextEditingcontroller.text = trimVal;
                                  emailTextEditingcontroller.selection =
                                      TextSelection.fromPosition(
                                          TextPosition(offset: trimVal.length));
                                });
                              }
                            },
                            controller: passwordTextEditingcontroller,
                            validator: (value) {
                              return value!.length > 6
                                  ? null
                                  : "Please enter  length of 8 charater password";
                            },
                            decoration: const InputDecoration(
                                hintText: "password",
                                hintStyle: TextStyle(color: Colors.black)),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Container(
                            alignment: Alignment.topRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                "Forgot password",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: (() {
                              signIn();
                            }),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(250)),
                              height: MediaQuery.of(context).size.height * 0.08,
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: const Center(
                                  child: Text(
                                "Sign In",
                                style: TextStyle(color: Colors.white),
                              )),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          InkWell(
                            onTap: () {
                              googleSigin();
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(250)),
                                height:
                                    MediaQuery.of(context).size.height * 0.08,
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.asset(
                                          "assets/images/GoogleLOGO.jpg"),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    const Text(
                                      "Sign up with Google",
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text(
                                    "Don't have a account",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      widget.toggleView();
                                    },
                                    child: const Text(
                                      "  Register here",
                                      style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontSize: 16),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            isLoading == true
                ? SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                        child: Lottie.asset("assets/images/loading.json",
                            height: 250, frameRate: FrameRate(240))),
                  )
                : const SizedBox(),
          ],
        );
      }),
    );
  }
}
