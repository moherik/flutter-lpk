import 'package:flutter/material.dart';
import 'package:lpk/screen/add_location.dart';
import 'package:lpk/sign_in.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;

  Widget build(BuildContext context) {
    Widget child;
    if (isLoading) {
      child = Center(
        child: CircularProgressIndicator(),
      );
    } else {
      child = _signInButton();
    }

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
              Image.asset(
                "assets/logo.png",
                width: 150.0,
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                "Aplikasi Lokasi Pelayanan Kesehatan",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 30,
              ),
              child
            ],
          ),
        ),
      ),
    );
  }

  Widget _signInButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        setState(() {
          isLoading = true;
        });

        signInWithGoogle().then((result) {
          if (result != null) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => AddLocationScreen()));
          }

          setState(() {
            isLoading = false;
          });
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
