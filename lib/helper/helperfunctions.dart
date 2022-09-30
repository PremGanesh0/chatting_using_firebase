import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  static String sharedPreferenceUserLoggedInKey = "ISLOGGEDIN";
  static String sharedPreferenceUserNameKey = "USERNAMEKEY";
  static String sharedPreferenceUserEmailKey = "USEREMAILKEY";
  static String sharedPreferenceUserUIDkey = "USERUIDKEY";
  static String sharedPreferenceSearchUserName = "SEARCHUSERNAME";
  static String sharedPreferenceStopNotification = "STOPNOTIFICATION";

  /// saving data to sharedpreference

  static Future<bool> saveStopNotificationsSharedPreference(
      bool stopNotification) async {
    log("User logined into shared preference");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setBool(
        sharedPreferenceStopNotification, stopNotification);
  }

  static Future<bool> saveUserLoggedInSharedPreference(
      bool isUserLoggedIn) async {
    log("User logined into shared preference");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setBool(
        sharedPreferenceUserLoggedInKey, isUserLoggedIn);
  }

  static Future<bool> saveUserNameSharedPreference(String userName) async {
    log("User Name stored into shared preference $userName");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(sharedPreferenceUserNameKey, userName);
  }

  static Future<bool> saveUserUIDSharedPreference(String userUId) async {
    log("User UID stored into shared preference $userUId");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(sharedPreferenceUserUIDkey, userUId);
  }

  static Future<bool> saveUserEmailSharedPreference(String userEmail) async {
    log("Email stored into shared preference $userEmail");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(sharedPreferenceUserEmailKey, userEmail);
  }

  static Future<bool> saveSearchUserNameSharedPreference(
      String searchUserName) async {
    log("Search name save into shared preference $searchUserName");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(
        sharedPreferenceSearchUserName, searchUserName);
  }

  /// fetching data from sharedpreference

  static Future<bool?> getUserLoggedInSharedPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(sharedPreferenceUserLoggedInKey);
  }

  static Future<String?> getUserNameSharedPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    return preferences.getString(sharedPreferenceUserNameKey);
  }

  static Future<String?> getUserEmailSharedPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(sharedPreferenceUserEmailKey);
  }

  static Future<bool?> getStopNotifications() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(sharedPreferenceStopNotification);
  }

  static Future<String?> getSearchUserNameSharedPreference() async {
    print("Get search user name called: ");

    SharedPreferences preferences = await SharedPreferences.getInstance();
    print("This is from Method");
    print(preferences.getString(sharedPreferenceSearchUserName));
    print("This is from Method");
    return preferences.getString(sharedPreferenceSearchUserName);
  }
}
