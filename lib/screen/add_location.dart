import 'package:flutter/material.dart';

class AddLocationScreen extends StatefulWidget {
  @override
  _AddLocationScreenState createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Peta Pelayanan Kesehatan"),
          backgroundColor: Colors.teal,
        ),
        body: Center(
          child: Text("Tambah lokasi"),
        )
    );
  }
}