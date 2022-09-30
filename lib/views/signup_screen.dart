import 'dart:developer';
import 'package:chatting_using_firebase/helper/helperfunctions.dart';
import 'package:chatting_using_firebase/services/auth.dart';
import 'package:chatting_using_firebase/services/database.dart';
import 'package:chatting_using_firebase/views/chatrooms_screen.dart';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SignUpscreen extends StatefulWidget {
  final Function toggleView;

  // ignore: use_key_in_widget_constructors
  const SignUpscreen(this.toggleView);
  @override
  State<SignUpscreen> createState() => _SignUpscreenState();
}

class _SignUpscreenState extends State<SignUpscreen> {
  final formKey = GlobalKey<FormState>();
  AuthServices authServices = AuthServices();
  DatabaseMethods databaseMethods = DatabaseMethods();
  TextEditingController userNameTextEditingcontroller = TextEditingController();
  TextEditingController emailTextEditingcontroller = TextEditingController();
  TextEditingController passwordTextEditingcontroller = TextEditingController();
  bool signupbutton = true;
  bool isLoading = false;
  String? token;
  var userUID;

  @override
  void dispose() {
    //  userNameTextEditingcontroller.dispose();
    passwordTextEditingcontroller.dispose();
    emailTextEditingcontroller.dispose();
    super.dispose();
  }

  signMeUp() async {
    if (formKey.currentState!.validate()) {
      isLoading = true;
      authServices
          .signUpWithEmailAndPassoword(emailTextEditingcontroller.text,
              passwordTextEditingcontroller.text)
          .then((value) async {
        if (value != null) {
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
          var v = value;
          userUID = v.uid;
          Map<String, String> userInfoMap = {
            "name": userNameTextEditingcontroller.text,
            "email": emailTextEditingcontroller.text
          };
          await databaseMethods.uploadUserInfo(userInfoMap, userUID);
          setState(() {
            isLoading = true;
            HelperFunctions.saveUserLoggedInSharedPreference(true);
            HelperFunctions.saveUserEmailSharedPreference(
                emailTextEditingcontroller.text);
            HelperFunctions.saveUserNameSharedPreference(
                userNameTextEditingcontroller.text);
            HelperFunctions.saveUserUIDSharedPreference(userUID);
          });
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const ChatRoom()));
        }
      });
      setState(() {
        signupbutton = true;
      });
    }
    log("not enterd if case");
    log(formKey.currentState!.validate().toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            "Chatting using Firebase",
          ),
          backgroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              SizedBox(
                height: 300,
                width: MediaQuery.of(context).size.width,
                child: Lottie.asset("assets/images/signuplottie.json"),
              ),
              SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 10,
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          validator: (value) {
                            return value!.isEmpty || value.length < 4
                                ? "Plase enter valid user name"
                                : null;
                          },
                          controller: userNameTextEditingcontroller,
                          decoration: const InputDecoration(
                              hintText: "Pick a unique name",
                              hintStyle: TextStyle(color: Colors.black)),
                        ),
                        TextFormField(
                          validator: (value) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(value!)
                                ? null
                                : "Please Enter valid Email";
                          },
                          controller: emailTextEditingcontroller,

                          /// this will not allow user to enter white spaces in field
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
                          validator: (value) {
                            return value!.length > 6
                                ? null
                                : "Please enter  length of 8 charater password";
                          },
                          controller: passwordTextEditingcontroller,
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
                            onPressed: () {
                              log("hello");
                            },
                            child: const Text(
                              "Forgot password",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            signupbutton ? signMeUp() : null;
                            setState(() {
                              signupbutton = false;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(250)),
                            height: MediaQuery.of(context).size.height * 0.08,
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: const Center(
                                child: Text(
                              "Sign up",
                              style: TextStyle(color: Colors.white),
                            )),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [Colors.grey, Colors.black38]),
                              borderRadius: BorderRadius.circular(250)),
                          height: MediaQuery.of(context).size.height * 0.08,
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: const Center(child: Text("Google")),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text("Already have a account"),
                              InkWell(
                                onTap: () {
                                  widget.toggleView();
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Sigin here",
                                    style: TextStyle(
                                        decoration: TextDecoration.underline),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
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
          ),
        ),
      ),
    );
  }
}
