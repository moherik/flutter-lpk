import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lpk/constant.dart';
import 'package:lpk/screen/home_screen.dart';
import 'package:lpk/sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:lpk/model/location.dart';
import 'package:http/http.dart' as http;

class AddLocationScreen extends StatefulWidget {
  @override
  _AddLocationScreenState createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  int locationTypeId;

  final locationTxtController = TextEditingController();
  final titleTxtController = TextEditingController();
  final addressTxtController = TextEditingController();
  final websiteTxtController = TextEditingController();
  final phoneTxtController = TextEditingController();
  final descTxtController = TextEditingController();

  LatLng currentLatLng = LatLng(-7.126926, 112.333778);

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Tambah Lokasi"),
          backgroundColor: Colors.orange,
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              tooltip: "Logout",
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                          title: Text("Logout"),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: <Widget>[
                                Text('Apakah anda ingin logout dari akun ini?'),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('TIDAK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('YA'),
                              onPressed: () {
                                signOutGoogle().then((result) {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                });
                              },
                            ),
                          ]);
                    });
              },
            )
          ],
        ),
        body: ListView(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: GoogleMap(
                      rotateGesturesEnabled: false,
                      scrollGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                      zoomGesturesEnabled: false,
                      zoomControlsEnabled: false,
                      onMapCreated: _onMapCreated,
                      initialCameraPosition:
                          CameraPosition(target: currentLatLng, zoom: 15.0),
                      markers: _markers,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: locationTxtController,
                          decoration: InputDecoration(
                              labelText: "Lokasi (Latitude, Longitude)"),
                          readOnly: true,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Kolom ini harus diisi';
                            }
                            return null;
                          },
                        ),
                        DropdownButtonFormField(
                            value: null,
                            decoration:
                                InputDecoration(labelText: "Tipe Lokasi"),
                            validator: (value) =>
                                value == null ? 'Pilih tipe lokasi' : null,
                            items: <DropdownMenuItem>[
                              DropdownMenuItem<int>(
                                  value: 1, child: Text("Apotek")),
                              DropdownMenuItem<int>(
                                  value: 2, child: Text("Rumah Sakit")),
                              DropdownMenuItem<int>(
                                  value: 3, child: Text("Puskesmas")),
                              DropdownMenuItem<int>(
                                  value: 4, child: Text("Klinik")),
                              DropdownMenuItem<int>(
                                  value: 5, child: Text("Praktek Dokter")),
                              DropdownMenuItem<int>(
                                  value: 6, child: Text("Praktek Bidan")),
                            ],
                            onChanged: (value) async {
                              setState(() {
                                locationTypeId = value;
                              });
                            }),
                        TextFormField(
                          controller: titleTxtController,
                          decoration: InputDecoration(
                            labelText: "Nama Lokasi",
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Kolom ini harus diisi';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: addressTxtController,
                          decoration: InputDecoration(labelText: "Alamat"),
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Kolom ini harus diisi';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: websiteTxtController,
                          decoration: InputDecoration(labelText: "Website"),
                        ),
                        TextFormField(
                          controller: phoneTxtController,
                          decoration: InputDecoration(labelText: "No. Telepon"),
                        ),
                        TextFormField(
                          controller: descTxtController,
                          decoration: InputDecoration(labelText: "Deskripsi"),
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        () {
                          if (isLoading) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            return ElevatedButton(
                              child: Text("Tambah Lokasi"),
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  save(context);
                                }
                              },
                            );
                          }
                        }(),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  void _onMapCreated(GoogleMapController controller) async {
    await getCurrentLocation();

    _mapController = controller;

    _mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: currentLatLng, zoom: 15.0)));
  }

  Future<void> getCurrentLocation() async {
    final location = LocationManager.Location();
    var currentLocation = await location.getLocation();

    final lat = currentLocation.latitude;
    final lng = currentLocation.longitude;
    final _currentLatLng = LatLng(lat, lng);

    setState(() {
      _markers.add(Marker(
        markerId: MarkerId("current"),
        position: _currentLatLng,
      ));

      locationTxtController.text =
          "${_currentLatLng.latitude},${_currentLatLng.longitude}";

      currentLatLng = _currentLatLng;
    });
  }

  void save(context) async {
    final SharedPreferences prefs = await _prefs;

    setState(() {
      isLoading = true;
    });

    final newLocation = LocationModel(
            title: titleTxtController.text,
            address: addressTxtController.text,
            latLong: locationTxtController.text,
            phone: phoneTxtController.text,
            website: websiteTxtController.text,
            description: descTxtController.text,
            locationType: locationTypeId)
        .toJson();
    final jsonInput = jsonEncode(newLocation);

    print("input: $jsonInput");

    final response = await http.post('$API_ENDPOINT/api/locations',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
        body: jsonInput);

    if (response.statusCode == 201) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text("Sukses"),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('Berhasil menyimpan data.'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ]);
          });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text("Terjadi kesalahan"),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('Gagal menyimpan data.'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ]);
          });
    }

    setState(() {
      isLoading = false;
    });
  }
}
