import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lpk/screen/image_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:http/http.dart' as http;
import 'dart:convert';

const _apiKey = "AIzaSyAM3iXSkcBdDnQlxunGkEditNA0p0B2Xpg";
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: _apiKey);

class LocationDetailScreen extends StatefulWidget {
  String placeId;

  LocationDetailScreen(String placeId) {
    this.placeId = placeId;
  }

  @override
  _LocationDetailScreenState createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen> {
  GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};
  Set<Polyline> get polyLines => _polyLines;

  PlacesDetailsResponse place;
  bool isLoading = false;
  bool isNavigate = false;
  String errorLoading;

  LatLng destinationLatLng;
  LatLng currentLatLng;

  @override
  void initState() {
    fetchPlaceDetail();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyChild;
    String title;

    if (isLoading) {
      title = "Loading";
      bodyChild = Center(
        child: CircularProgressIndicator(
          value: null,
        ),
      );
    } else if (errorLoading != null) {
      title = "";
      bodyChild = Center(
        child: Text(errorLoading),
      );
    } else if (isNavigate == true) {
      final location = place.result.geometry.location;
      final center = LatLng(location.lat, location.lng);

      title = place.result.name;
      bodyChild = Stack(children: <Widget>[
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(target: center, zoom: 15.0),
          markers: _markers,
          polylines: polyLines,
        ),
        Positioned(
          bottom: 30,
          left: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      this.isNavigate = false;
                    });
                  },
                  icon: Icon(Icons.info_outline),
                  label: Text("Detail Lokasi")),
              SizedBox(width: 10.0),
              ElevatedButton.icon(
                  onPressed: () async {
                    String googleUrl =
                        'https://www.google.com/maps/search/?api=1&query=${destinationLatLng.latitude},${destinationLatLng.longitude}';
                    if (await canLaunch(googleUrl)) {
                      await launch(googleUrl);
                    } else {
                      throw 'Could not open the map.';
                    }
                  },
                  icon: Icon(Icons.map_outlined),
                  label: Text("Buka di Maps")),
            ],
          ),
        )
      ]);
    } else {
      final location = place.result.geometry.location;
      final center = LatLng(location.lat, location.lng);

      title = place.result.name;
      bodyChild = Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
              child: SizedBox(
            height: 200.0,
            child: GoogleMap(
              rotateGesturesEnabled: false,
              scrollGesturesEnabled: false,
              tiltGesturesEnabled: false,
              zoomGesturesEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(target: center, zoom: 15.0),
              markers: _markers,
            ),
          )),
          Expanded(
            child: Material(
                elevation: 16.0,
                child: Container(child: buildPlaceDetailList(place.result))),
          )
        ],
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: bodyChild);
  }

  void fetchPlaceDetail() async {
    setState(() {
      this.isLoading = true;
      this.errorLoading = null;
    });

    PlacesDetailsResponse place =
        await _places.getDetailsByPlaceId(widget.placeId);

    if (mounted) {
      setState(() {
        this.isLoading = false;
        if (place.status == "OK") {
          this.place = place;
          this.destinationLatLng = LatLng(place.result.geometry.location.lat,
              place.result.geometry.location.lng);
        } else {
          this.errorLoading = place.errorMessage;
        }
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    getCurrentLocation();

    _mapController = controller;
    final placeDetail = place.result;
    final location = placeDetail.geometry.location;
    final _destinationLatLng = LatLng(location.lat, location.lng);

    setState(() {
      _markers.add(Marker(
        position: _destinationLatLng,
        markerId: MarkerId("destination"),
      ));

      this.destinationLatLng = _destinationLatLng;
    });

    _mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _destinationLatLng, zoom: 15.0)));
  }

  String buildPhotoURL(String photoReference) {
    return "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${photoReference}&key=${_apiKey}";
  }

  Widget imageItem(String url) {
    return SizedBox(
      height: 100,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                transitionDuration: Duration(milliseconds: 1000),
                pageBuilder: (BuildContext context, Animation<double> animation,
                    Animation<double> secondaryAnimation) {
                  return ImageDetailScreen(buildPhotoURL(url));
                },
                transitionsBuilder: (BuildContext context,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                    Widget child) {
                  return Align(
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
              ),
            );
          },
          child: Hero(
            tag: 'imageHero${buildPhotoURL(url)}',
            child: Image.network(buildPhotoURL(url), fit: BoxFit.fill,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent progress) {
              if (progress == null) return child;

              return Center(
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes
                      : null,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  ListView buildPlaceDetailList(PlaceDetails placeDetail) {
    List<Widget> list = [];
    final double horizontalPadding = 20;

    if (placeDetail.photos != null) {
      final photos = placeDetail.photos;
      list.add(Padding(
        padding: EdgeInsets.only(top: 20, left: 0, right: 0, bottom: 0),
        child: SizedBox(
            height: 100.0,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  return Padding(
                      padding: EdgeInsets.only(
                          right: index >= photos.length - 1
                              ? horizontalPadding
                              : 0.0,
                          left: 20.0),
                      child: imageItem(photos[index].photoReference));
                })),
      ));
    }

    list.add(
      Padding(
          padding: EdgeInsets.only(
              top: 20,
              left: horizontalPadding,
              right: horizontalPadding,
              bottom: 0),
          child: Text(
            placeDetail.name,
            style: Theme.of(context).textTheme.headline6,
          )),
    );

    if (placeDetail.formattedAddress != null) {
      list.add(
        Padding(
            padding: EdgeInsets.only(
                top: 10,
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: 0),
            child: Text(
              placeDetail.formattedAddress,
              style: Theme.of(context).textTheme.bodyText1,
            )),
      );
    }

    if (placeDetail.types?.first != null) {
      list.add(
        Padding(
            padding: EdgeInsets.only(
                top: 4.0,
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: 0.0),
            child: Text(
              placeDetail.types.first.toUpperCase(),
              style: Theme.of(context).textTheme.caption,
            )),
      );
    }

    if (placeDetail.formattedPhoneNumber != null) {
      list.add(
        Padding(
            padding: EdgeInsets.only(
                top: 4.0,
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: 4.0),
            child: InkWell(
              onTap: () => launch("tel://${placeDetail.formattedPhoneNumber}"),
              child: Text(
                placeDetail.formattedPhoneNumber,
                style: Theme.of(context).textTheme.button,
              ),
            )),
      );
    }

    if (placeDetail.name.toLowerCase().contains("soegiri") ||
        placeDetail.name.toLowerCase().contains("petro") ||
        placeDetail.name.toLowerCase().contains("semen gresik")) {
      list.add(
        Padding(
            padding: EdgeInsets.only(
                top: 10.0,
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: 4.0),
            child: Row(
              children: [
                Icon(Icons.local_hospital_outlined, color: Colors.red),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "UGD",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ],
            )),
      );
    }

    if (placeDetail.openingHours != null) {
      final openingHour = placeDetail.openingHours;
      var text = '';
      if (openingHour.openNow) {
        text = 'Buka';
      } else {
        text = 'Tutup';
      }
      list.add(
        Padding(
            padding: EdgeInsets.only(
                top: 0.0,
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: 4.0),
            child: Text(
              text,
              style: Theme.of(context).textTheme.caption,
            )),
      );
    }

    if (placeDetail.website != null) {
      list.add(
        Padding(
            padding: EdgeInsets.only(
                top: 0.0,
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: 4.0),
            child: InkWell(
              child: Text(
                placeDetail.website,
                style: Theme.of(context).textTheme.caption,
              ),
              onTap: () => launch("${placeDetail.website}"),
            )),
      );
    }

    if (currentLatLng != null && destinationLatLng != null) {
      list.add(Padding(
        padding: EdgeInsets.only(
            top: 20,
            left: horizontalPadding,
            right: horizontalPadding,
            bottom: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton.icon(
              onPressed: () => navigate(),
              icon: Icon(Icons.navigation_outlined),
              label: Text("Petunjuk Arah"),
            ),
          ],
        ),
      ));
    }

    return ListView(
      shrinkWrap: true,
      children: list,
    );
  }

  void getCurrentLocation() async {
    final location = LocationManager.Location();
    var currentLocation = await location.getLocation();

    final lat = currentLocation.latitude;
    final lng = currentLocation.longitude;
    final _currentLatLng = LatLng(lat, lng);

    setState(() {
      this.currentLatLng = _currentLatLng;
    });
  }

  void createRoute(String encondedPoly) {
    setState(() {
      this.isNavigate = true;

      _polyLines.add(Polyline(
          polylineId: PolylineId(destinationLatLng.toString()),
          width: 4,
          points: _convertToLatLng(_decodePoly(encondedPoly)),
          color: Colors.red));
    });
  }

  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
    do {
      var shift = 0;
      int result = 0;

      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }

  Future<String> getRouteCoordinates(LatLng l1, LatLng l2) async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=$_apiKey";
    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);
    return values["routes"][0]["overview_polyline"]["points"];
  }

  void navigate() async {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId("current"),
        position: currentLatLng,
      ));
    });

    String route = await getRouteCoordinates(currentLatLng, destinationLatLng);
    createRoute(route);
  }
}
