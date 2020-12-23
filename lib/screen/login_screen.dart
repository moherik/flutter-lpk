import 'package:flutter/material.dart';
import 'package:lpk/screen/home_screen.dart';
import 'package:lpk/sign_in.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // FlutterLogo(size: 150,),
              Text(
                "Aplikasi Lokasi Pelayanan Kesehatan",
                style: _textStyle(),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 50,
              ),
              _signInButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget _signInButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () async {
        signInWithGoogle().then((result) =>
        {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => HomeScreen()))
        });
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(image: AssetImage("assets/google_logo.png"), height: 35.0),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Masuk dengan Google',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )
            ]),
      ),
    );
  }

  TextStyle _textStyle() {
    return TextStyle(fontSize: 30, fontWeight: FontWeight.w600);
  }
}
