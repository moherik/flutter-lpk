import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';

class FAQScreen extends StatefulWidget {
  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FAQ"),
        backgroundColor: Colors.red,
      ),
      body: ExpandableTheme(
        data: const ExpandableThemeData(
          iconColor: Colors.blue,
          useInkWell: true,
        ),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: <Widget>[
            cardContent(Colors.indigo, "Cara Penggunaan Aplikasi",
                "Bagaimana cara menggunakan aplikas Lokasi Pelayanan Kesehatan ini?"),
            cardContent(Colors.amber, "Cara Menambah Lokasi",
                "Cara menambahkan lokasi kesehatan anda"),
          ],
        ),
      ),
    );
  }

  Widget cardContent(Color color, String title, String subtitle) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    theme: const ExpandableThemeData(
                      headerAlignment: ExpandablePanelHeaderAlignment.center,
                      tapBodyToCollapse: true,
                    ),
                    header: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          title,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        )),
                    collapsed: Text(
                      subtitle,
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              subtitle,
                              softWrap: true,
                              overflow: TextOverflow.fade,
                            )),
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              "1. Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                              softWrap: true,
                              overflow: TextOverflow.fade,
                            )),
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              "2. Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                              softWrap: true,
                              overflow: TextOverflow.fade,
                            )),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding: EdgeInsets.only(
                            left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: collapsed,
                          expanded: expanded,
                          theme: const ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
