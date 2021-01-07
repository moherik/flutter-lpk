import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lpk/constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
User user = _auth.currentUser;

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

Future<String> signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final UserCredential authResult =
      await _auth.signInWithCredential(credential);

  user = authResult.user;

  if (user != null) {
    var signin = await signinOrSignUp(
        name: user.displayName,
        email: user.email,
        avatar: user.photoURL,
        googleProviderId: user.uid);

    if (signin == true) return '$user';

    return null;
  }

  return null;
}

Future<void> signOutGoogle() async {
  await googleSignIn.signOut();

  final SharedPreferences prefs = await _prefs;
  prefs.remove("token");
}

Future<bool> signinOrSignUp(
    {String name, String email, String avatar, String googleProviderId}) async {
  final SharedPreferences prefs = await _prefs;

  final http.Response response = await http.post(
    '$API_ENDPOINT/api/signin',
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(<String, String>{
      'name': name,
      'email': email,
      'avatar': avatar,
      'google_provider_id': googleProviderId
    }),
  );

  if (response.statusCode == 200) {
    Map<String, dynamic> body = jsonDecode(response.body);
    prefs.setString("token", body['token']);
    return true;
  }

  return false;
}
