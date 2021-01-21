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
            ExpandableNotifier(
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
                          headerAlignment:
                              ExpandablePanelHeaderAlignment.center,
                          tapBodyToCollapse: true,
                        ),
                        header: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "Cara Penggunaan Aplikasi",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            )),
                        collapsed: Text(
                          "Bagaimana cara Menggunakan aplikasi Lokasi Pelayanan Kesehatan ini?",
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
                                  "Bagaimana cara Menggunakan aplikasi Lokasi Pelayanan Kesehatan ini?",
                                  softWrap: true,
                                  overflow: TextOverflow.fade,
                                )),
                            Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Text(
                                  "1. Buka Menu Temukan Lokasi",
                                  softWrap: true,
                                  overflow: TextOverflow.fade,
                                )),
                            Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Text(
                                  "2. Ijinkan Aplikasi mengakses GPS anda",
                                  softWrap: true,
                                  overflow: TextOverflow.fade,
                                )),
                            Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Text(
                                  "3. Pilihlah Tipe Lokasi Rumah Sakit atau Apotek",
                                  softWrap: true,
                                  overflow: TextOverflow.fade,
                                )),
                            Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Text(
                                  "4. Akan Muncul Daftar lokasi yang anda sudah pilih",
                                  softWrap: true,
                                  overflow: TextOverflow.fade,
                                )),
                            Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Text(
                                  "5. Pilih Lokasi tersebut untuk melihat detail lokasi",
                                  softWrap: true,
                                  overflow: TextOverflow.fade,
                                )),
                            Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Text(
                                  "6. Klik Petunjuk Arah untuk melihat rute dari GPS user ke lokasi tujuan",
                                  softWrap: true,
                                  overflow: TextOverflow.fade,
                                )),
                            Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Text(
                                  "7. Buka di Maps",
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
                              theme:
                                  const ExpandableThemeData(crossFadePoint: 0),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )),
            ExpandableNotifier(
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
                          headerAlignment:
                              ExpandablePanelHeaderAlignment.center,
                          tapBodyToCollapse: true,
                        ),
                        header: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "Cara Menambah Lokasi",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            )),
                        collapsed: Text(
                          "Bagaimana cara menambahkan lokasi tempat saya?",
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
                                  "Bagaimana cara menambahkan lokasi tempat saya?",
                                  softWrap: true,
                                  overflow: TextOverflow.fade,
                                )),
                            Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Text(
                                  "1. Klik menu Tambah Lokasi",
                                  softWrap: true,
                                  overflow: TextOverflow.fade,
                                )),
                            Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Text(
                                  "2. Jika anda belum melakukan login, anda harus login terlebih dahulu",
                                  softWrap: true,
                                  overflow: TextOverflow.fade,
                                )),
                            Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Text(
                                  "3. Masukkan keterangan lokasi anda",
                                  softWrap: true,
                                  overflow: TextOverflow.fade,
                                )),
                            Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Text(
                                  "4. Tekan tombol tambah lokasi",
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
                              theme:
                                  const ExpandableThemeData(crossFadePoint: 0),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
