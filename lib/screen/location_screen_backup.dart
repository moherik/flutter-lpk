import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:lpk/model/location.dart';

const _apiKey = "AIzaSyAM3iXSkcBdDnQlxunGkEditNA0p0B2Xpg";
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: _apiKey);

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final double zoomLevel = 13;
  final homeScaffoldKey = GlobalKey<ScaffoldState>();

  Set<Marker> _markers = {};
  GoogleMapController _mapController;
  LatLng _initialCameraPosition = LatLng(-7.126926, 112.333778);
  List<PlacesSearchResult> places = [];
  bool isLoading = false;
  List<String> category = ["apotik", "rs"];
  bool isChooseCategory = true;
  String errorMessage;

  @override
  void initState() {
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Widget build(BuildContext context) {
    Widget expandedChild;

    if (isLoading) {
      expandedChild = Center(
          child: CircularProgressIndicator(
            value: null,
          ));
    } else if (errorMessage != null) {
      expandedChild = Center(
        child: Text(errorMessage),
      );
    } else {
      expandedChild = buildPlacesList();
    }

    return Scaffold(
        appBar: AppBar(
            title: Text("Peta Pelayanan Kesehatan"),
            backgroundColor: Colors.teal,
            actions: <Widget>[
              IconButton(
                  icon: const Icon(Icons.dashboard_outlined),
                  tooltip: 'Pilih Kategori',
                  onPressed: () {
                    showCategoryBottomSheet();
                  }),
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
              bottom: 170,
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
            DraggableScrollableSheet(
                initialChildSize: 0.3,
                minChildSize: 0.3,
                maxChildSize: 0.8,
                builder:
                    (BuildContext build, ScrollController scrollController) {
                  return expandedChild;
                }),
          ],
        ));
  }

  void refresh() async {
    final center = await getUserLocation();

    _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(
                target: center == null ? LatLng(0, 0) : center,
                zoom: 15.0
            )
        )
    );

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
    final result = await _places.searchNearbyWithRadius(location, 2500);

    setState(() {
      this.isLoading = false;
      if (result.status == "OK") {
        this.places = result.results;
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

  void showCategoryBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext build) {
          return Container(
            child: Column(
              children: <Widget>[
                _placeCategoryItem(
                    icon: Icons.local_hospital_outlined,
                    label: "Rumah Sakit",
                    onTap: () {}
                ),
                _placeCategoryItem(
                    icon: Icons.medical_services_outlined,
                    label: "Apotik",
                    onTap: () {}
                ),
              ],
            ),
          );
        });
  }

  InkWell _placeCategoryItem({String label, IconData icon, onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 30.0),
            SizedBox(width: 10),
            Text(label,
              style: Theme.of(context).textTheme.bodyText1,
            )
          ],
        ),
      ),
    );
  }

  ListView buildPlacesList() {
    final placesWidget = places.map((f) {
      List<Widget> list = [
        Padding(
          padding: EdgeInsets.only(bottom: 4.0),
          child: Text(
            f.name,
            style: Theme
                .of(context)
                .textTheme
                .subtitle1,
          ),
        )
      ];
      if (f.formattedAddress != null) {
        list.add(Padding(
          padding: EdgeInsets.only(bottom: 2.0),
          child: Text(
            f.formattedAddress,
            style: Theme
                .of(context)
                .textTheme
                .subtitle1,
          ),
        ));
      }

      if (f.vicinity != null) {
        list.add(Padding(
          padding: EdgeInsets.only(bottom: 2.0),
          child: Text(
            f.vicinity,
            style: Theme
                .of(context)
                .textTheme
                .bodyText1,
          ),
        ));
      }

      if (f.types?.first != null) {
        list.add(Padding(
          padding: EdgeInsets.only(bottom: 2.0),
          child: Text(
            f.types.first,
            style: Theme
                .of(context)
                .textTheme
                .caption,
          ),
        ));
      }

      return Padding(
        padding: EdgeInsets.only(top: 4.0, bottom: 4.0, left: 8.0, right: 8.0),
        child: Card(
          child: InkWell(
            onTap: () {
              // showDetailPlace(f.placeId);
            },
            highlightColor: Colors.lightBlueAccent,
            splashColor: Colors.red,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: list,
              ),
            ),
          ),
        ),
      );
    }).toList();

    return ListView(shrinkWrap: true, children: placesWidget);
  }

  // Future<List<LocationModel>> _fetchLocations() async {
  //   final locationsListAPIUrl =
  //       'http://lokasi-pelayanan-kesehatan.herokuapp.com/api/locations';
  //   final response = await http.get(locationsListAPIUrl);
  //
  //   if (response.statusCode == 200) {
  //     List jsonResponse = jsonDecode(response.body);
  //     return jsonResponse
  //         .map((location) => new LocationModel.fromJson(location))
  //         .toList();
  //   } else {
  //     throw Exception('Failed to load jobs from API');
  //   }
  // }
  //
  // FutureBuilder<List<LocationModel>> _locationsBuilder() =>
  //     FutureBuilder<List<LocationModel>>(
  //         future: _fetchLocations(),
  //         builder: (context, snapshot) {
  //           if (snapshot.hasData) {
  //             List<LocationModel> data = snapshot.data;
  //             return _locationsListView(data);
  //           } else if (snapshot.hasError) {
  //             return Text("${snapshot.error}");
  //           }
  //
  //           return Center(child: CircularProgressIndicator());
  //         });
  //
  // ListView _locationsListView(data) =>
  //     ListView.builder(
  //         itemCount: data.length,
  //         itemBuilder: (context, index) {
  //           return _locationListTile(
  //               data[index].title, data[index].address,
  //               Icons.location_on_outlined);
  //         });
  //
  // Widget _locationListTile(String title, String address, IconData icon) {
  //   return Column(
  //     children: <Widget>[
  //       SizedBox(
  //         height: 10,
  //       ),
  //       ListTile(
  //         title: Text(title,
  //             style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20)),
  //         subtitle: Padding(
  //           padding: EdgeInsets.only(top: 10),
  //           child: Text(address),
  //         ),
  //         leading: Icon(
  //           icon,
  //           color: Colors.blue[500],
  //           size: 40,
  //         ),
  //       ),
  //       SizedBox(
  //         height: 10,
  //       )
  //     ],
  //   );
  // }
}
