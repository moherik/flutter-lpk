import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lpk/screen/about_screen.dart';
import 'package:lpk/screen/faq_screen.dart';
import 'package:lpk/screen/location_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Widget build(BuildContext context) {
    var mediaQueryData = MediaQuery.of(context);
    final double widthScreen = mediaQueryData.size.width;
    final double heightScreen = mediaQueryData.size.height;
    final double radius = 60.0;

    AppBar appBar = AppBar(
      title: Text(
        "Lokasi Pelayanan Kesehatan",
      ),
      centerTitle: true,
      backgroundColor: Colors.deepPurple,
    );

    return Scaffold(
      appBar: appBar,
      body: Container(
        color: Colors.white,
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio:
              widthScreen / (heightScreen - appBar.preferredSize.height - 24.0),
          children: <Widget>[
            _gridItem(
                color: Colors.teal,
                borderRadius:
                    BorderRadius.only(bottomRight: Radius.circular(radius)),
                icon: Icons.map_outlined,
                label: "Temukan Lokasi",
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LocationScreen()));
                }),
            _gridItem(
                color: Colors.red,
                borderRadius:
                    BorderRadius.only(bottomLeft: Radius.circular(radius)),
                icon: Icons.help_outline,
                label: "F A Q",
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => FAQScreen()));
                }),
            _gridItem(
                color: Colors.indigo,
                borderRadius:
                    BorderRadius.only(topRight: Radius.circular(radius)),
                icon: Icons.info_outline,
                label: "Tentang Aplikasi",
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AboutScreen()));
                }),
            _gridItem(
                color: Colors.orange,
                borderRadius:
                    BorderRadius.only(topLeft: Radius.circular(radius)),
                icon: Icons.exit_to_app_outlined,
                label: "Keluar",
                onTap: () {
                  return showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                            title: Text("Keluar Aplikasi?"),
                            content: Text(
                                "Apakah anda ingin keluar dari aplikasi ini?"),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("YA"),
                                onPressed: () {
                                  SystemNavigator.pop();
                                },
                              ),
                              FlatButton(
                                child: Text("TIDAK"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ]);
                      });
                }),
          ],
        ),
      ),
    );
  }

  Widget _gridItem(
      {Color color,
      BorderRadiusGeometry borderRadius,
      IconData icon,
      String label,
      onTap}) {
    return Material(
      color: color,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              color: Colors.white,
              size: 90,
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ))),
          ],
        ),
      ),
    );
  }
}
