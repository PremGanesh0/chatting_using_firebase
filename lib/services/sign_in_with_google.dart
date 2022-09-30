// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';


// class Authentication {
//  static final GoogleSignIn _googleSignIn = GoogleSignIn();
//  static final FirebaseAuth _auth = FirebaseAuth.instance;

//  static Future<void> googleLogin() async {
//     FirebaseUser user;

//    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
//    final GoogleSignInAuthentication googleAuth =
//    await googleUser.authentication;

//    final AuthCredential credential = GoogleAuthProvider.getCredential(
//        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

//    final AuthResult authResult = await _auth.signInWithCredential(credential);
//    user = authResult.user;

//    if (authResult.additionalUserInfo.isNewUser) {
//      await Database.addUser(user);
//    }
//  }

//  static Future<void> googleLogout() async {
//    await _auth.signOut();
//  }
// }