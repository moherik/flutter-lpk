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
  final double zoomLevel = 13;
  final locationScaffoldKey = GlobalKey<ScaffoldState>();

  Set<Marker> _markers = {};
  GoogleMapController _mapController;
  LatLng _initialCameraPosition = LatLng(-7.126926, 112.333778);
  List<PlacesSearchResult> places = [];
  bool isLoading = false;
  String errorMessage;
  String type;

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
    String typeLabel;
    IconData typeIcon;

    if (type == "hospital") {
      typeLabel = "Rumah Sakit";
      typeIcon = Icons.local_hospital_outlined;
    } else if (type == "pharmacy") {
      typeLabel = "Apotek";
      typeIcon = Icons.medical_services_outlined;
    } else {
      typeLabel = "Pilih Tipe Lokasi!";
      typeIcon = Icons.info_outline;
    }

    return Scaffold(
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
          Positioned(
            left: 10,
            bottom: 180,
            child: RaisedButton.icon(
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
                            )
                          ],
                        ),
                      );
                    });
              },
              icon: Icon(typeIcon),
              label: Text(typeLabel),
              color: Colors.white,
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
                        return Wrap(children: <Widget>[
                          _placeCategoryItem(
                            icon: Icons.local_hospital_outlined,
                            label: "Rumah Sakit",
                            type: "hospital",
                          ),
                          _placeCategoryItem(
                            icon: Icons.medical_services_outlined,
                            label: "Apotek",
                            type: "pharmacy",
                          )
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
      this.isLoading = true;
      this.errorMessage = null;
    });

    final location = Location(center.latitude, center.longitude);
    final result =
        await _places.searchNearbyWithRadius(location, 5000, type: type);

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
      {String label, IconData icon, String type, bool autoClose: false}) {
    return InkWell(
      onTap: () {
        setState(() {
          this.type = type;
        });
        refresh();
        if (autoClose) {
          Navigator.pop(context);
        }
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
