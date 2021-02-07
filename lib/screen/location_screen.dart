import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:lpk/screen/location_detail_screen.dart';

const _apiKey = "AIzaSyAM3iXSkcBdDnQlxunGkEditNA0p0B2Xpg";
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: _apiKey);

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  double zoomLevel = 12;
  final locationScaffoldKey = GlobalKey<ScaffoldState>();

  Set<Marker> _markers = {};
  GoogleMapController _mapController;
  LatLng _initialCameraPosition = LatLng(-7.126926, 112.333778);
  List<PlacesSearchResult> places = [];
  bool isLoading = false;
  String errorMessage;
  String type;
  String keyword;
  int range = 5000;

  TextEditingController keywordSearch = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;

    final center = await getUserLocation();

    _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: center == null ? LatLng(0, 0) : center, zoom: zoomLevel)));
  }

  @override
  Widget build(BuildContext context) {
    String typeLabel = "Pilih Tipe Lokasi!";
    IconData typeIcon = Icons.info_outline;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: Text("Peta Pelayanan Kesehatan"),
          backgroundColor: Colors.teal,
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.refresh_outlined),
                tooltip: 'Refresh',
                onPressed: () {
                  refresh();
                })
          ]),
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            bottom: 120,
            right: 0,
            left: 0,
            child: Container(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _initialCameraPosition,
                  zoom: zoomLevel,
                ),
                zoomControlsEnabled: false,
                myLocationEnabled: true,
                markers: _markers,
              ),
            ),
          ),
          () {
            if (type == null) {
              return Container();
            } else {
              return Positioned(
                left: 10,
                top: 10,
                child: Container(
                  width: MediaQuery.of(context).size.width - 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: TextField(
                      controller: keywordSearch,
                      onChanged: (val) async {
                        setState(() {
                          this.keyword = val;
                        });
                        await refresh();
                      },
                      decoration: InputDecoration(
                          hintText: "Cari lokasi",
                          suffix: InkWell(
                            child: Icon(Icons.close),
                            onTap: () async {
                              setState(() {
                                this.keyword = "";
                                keywordSearch.clear();
                              });
                              await refresh();
                            },
                          )),
                    ),
                  ),
                ),
              );
            }
          }(),
          Positioned(
            left: 10,
            bottom: 180,
            // bottom: 400,
            child: Row(
              children: [
                RaisedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext build) {
                          return Container(
                            child: Wrap(
                              children: <Widget>[
                                _placeCategoryItem(
                                  icon: Icons.local_hospital_outlined,
                                  label: "Rumah Sakit",
                                  type: "hospital",
                                  autoClose: true,
                                ),
                                _placeCategoryItem(
                                  icon: Icons.medical_services_outlined,
                                  label: "Apotek",
                                  type: "pharmacy",
                                  autoClose: true,
                                ),
                                _placeCategoryItem(
                                  icon: Icons.local_hospital_outlined,
                                  label: "Puskesmas",
                                  type: "hospital",
                                  keyword: "puskesmas",
                                  autoClose: true,
                                ),
                                _placeCategoryItem(
                                  icon: Icons.local_hospital_outlined,
                                  label: "Klinik",
                                  type: "hospital",
                                  keyword: "klinik",
                                  autoClose: true,
                                ),
                                _placeCategoryItem(
                                  icon: Icons.local_hospital_outlined,
                                  label: "Prakter Dokter",
                                  type: "hospital",
                                  keyword: "praktek dokter",
                                  autoClose: true,
                                ),
                                _placeCategoryItem(
                                  icon: Icons.local_hospital_outlined,
                                  label: "Praktek Bidan",
                                  type: "hospital",
                                  keyword: "praktek bidan",
                                  autoClose: true,
                                ),
                              ],
                            ),
                          );
                        });
                  },
                  icon: Icon(typeIcon),
                  label: Text(typeLabel),
                  color: Colors.white,
                ),
                SizedBox(
                  width: 10,
                ),
                () {
                  if (type == null) {
                    return Container();
                  } else {
                    return RaisedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext build) {
                              return Container(
                                child: ListView(
                                  children: <Widget>[
                                    _rangeItem(
                                        label: "5 km",
                                        range: 5000,
                                        zoomLevel: 12),
                                    _rangeItem(
                                        label: "2.5 km",
                                        range: 2500,
                                        zoomLevel: 13),
                                    _rangeItem(
                                        label: "1 km",
                                        range: 1000,
                                        zoomLevel: 15),
                                    _rangeItem(
                                        label: "500 m",
                                        range: 500,
                                        zoomLevel: 16),
                                    _rangeItem(
                                        label: "250 m",
                                        range: 250,
                                        zoomLevel: 16),
                                    _rangeItem(
                                        label: "100 m",
                                        range: 100,
                                        zoomLevel: 16),
                                    _rangeItem(
                                        label: "50 m",
                                        range: 50,
                                        zoomLevel: 18),
                                  ],
                                ),
                              );
                            });
                      },
                      icon: Icon(Icons.compass_calibration_outlined),
                      label: Text("${range.toString()}m"),
                      color: Colors.white,
                    );
                  }
                }(),
              ],
            ),
          ),
          DraggableScrollableSheet(
              initialChildSize: 0.3,
              minChildSize: 0.3,
              maxChildSize: 0.8,
              builder: (BuildContext build, ScrollController scrollController) {
                return Container(
                  child: Material(
                    elevation: 16.0,
                    shadowColor: Colors.grey[50],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0)),
                    child: Container(
                        child: (() {
                      if (isLoading) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (type == null) {
                        return ListView(children: <Widget>[
                          _placeCategoryItem(
                            icon: Icons.local_hospital_outlined,
                            label: "Rumah Sakit",
                            type: "hospital",
                          ),
                          _placeCategoryItem(
                            icon: Icons.medical_services_outlined,
                            label: "Apotek",
                            type: "pharmacy",
                          ),
                          _placeCategoryItem(
                            icon: Icons.local_hospital_outlined,
                            label: "Puskesmas",
                            type: "hospital",
                            keyword: "puskesmas",
                          ),
                          _placeCategoryItem(
                            icon: Icons.local_hospital_outlined,
                            label: "Klinik",
                            type: "hospital",
                            keyword: "klinik",
                          ),
                          _placeCategoryItem(
                            icon: Icons.local_hospital_outlined,
                            label: "Prakter Dokter",
                            type: "hospital",
                            keyword: "praktek dokter",
                          ),
                          _placeCategoryItem(
                            icon: Icons.local_hospital_outlined,
                            label: "Praktek Bidan",
                            type: "hospital",
                            keyword: "praktek bidan",
                          ),
                        ]);
                      } else if (errorMessage != null) {
                        return Text(errorMessage);
                      } else {
                        return ListView(
                          controller: scrollController,
                          children: buildPlacesList(),
                        );
                      }
                    }())),
                  ),
                );
              }),
        ],
      ),
    );
  }

  void refresh() async {
    final center = await getUserLocation();

    _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: center == null ? LatLng(0, 0) : center, zoom: zoomLevel)));

    getNearbyPlaces(center);
  }

  Future<LatLng> getUserLocation() async {
    final location = LocationManager.Location();
    var currentLocation = await location.getLocation();
    try {
      final lat = currentLocation.latitude;
      final lng = currentLocation.longitude;
      return LatLng(lat, lng);
    } on Exception {
      currentLocation = null;
      return null;
    }
  }

  void getNearbyPlaces(LatLng center) async {
    setState(() {
      this.places = [];
      this.isLoading = true;
      this.errorMessage = null;
    });

    final location = Location(center.latitude, center.longitude);
    final result = await _places.searchNearbyWithRadius(location, range,
        type: type, keyword: keyword);

    setState(() {
      this.isLoading = false;
      if (result.status == "OK") {
        this.places = result.results;
        _markers.clear();
        result.results.forEach((f) {
          _markers.add(Marker(
            position: LatLng(f.geometry.location.lat, f.geometry.location.lng),
            markerId: MarkerId(
                "${f.geometry.location.lat}, ${f.geometry.location.lng}"),
          ));
        });
      } else {
        this.errorMessage = result.errorMessage;
      }
    });
  }

  InkWell _placeCategoryItem(
      {String label,
      IconData icon,
      String type,
      String keyword: '',
      bool autoClose: false}) {
    return InkWell(
      onTap: () {
        setState(() {
          this.type = type;
          this.keyword = keyword;
        });
        if (autoClose) {
          Navigator.pop(context);
        }
        refresh();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 30.0),
            SizedBox(width: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyText1,
            )
          ],
        ),
      ),
    );
  }

  InkWell _rangeItem({String label, int range, double zoomLevel: 12}) {
    return InkWell(
      onTap: () {
        setState(() {
          this.range = range;
          this.zoomLevel = zoomLevel;
        });
        Navigator.pop(context);
        refresh();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Row(
          children: <Widget>[
            Text(
              label,
              style: Theme.of(context).textTheme.bodyText1,
            )
          ],
        ),
      ),
    );
  }

  void onError(PlacesAutocompleteResponse response) {
    locationScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  List<Widget> buildPlacesList() {
    final placesWidget = places.map((f) {
      IconData icon;

      if (f.types.first == "hospital") {
        icon = Icons.local_hospital_outlined;
      } else if (f.types.first == "pharmacy") {
        icon = Icons.medical_services_outlined;
      } else {
        icon = Icons.medical_services_outlined;
      }

      return Ink(
        child: InkWell(
          onTap: () {
            showDetailPlace(f.placeId);
          },
          child: ListTile(
            leading: Icon(icon, size: 40),
            title: Text(f.name),
            subtitle: Text(f.vicinity),
            isThreeLine: true,
          ),
        ),
      );
    }).toList();

    return placesWidget;
  }

  Future<Null> showDetailPlace(String placeId) async {
    if (placeId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LocationDetailScreen(placeId)),
      );
    }
  }
}
