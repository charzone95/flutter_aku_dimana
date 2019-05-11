import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share/share.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aku Dimana?',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GoogleMapController _controller;
  Geolocator _geolocator;
  LatLng _currentPosition;
  double _currentZoom;
  String _textToDisplay;
  StreamSubscription<Position> _positionStream;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  bool _shouldRecenterMap = true;
  Timer _mapDragTimer;

  @override
  void initState() {
    super.initState();

    _textToDisplay = "Sedang melacak posisi kamu..";
    _currentPosition = LatLng(3.5913479, 98.6754698);
    _currentZoom = 17.5;

    _initLocationService();
  }

  Future<void> _initLocationService() async {
    _geolocator = Geolocator();

    var locationOptions = LocationOptions(accuracy: LocationAccuracy.best);

    try {
      _positionStream =
          _geolocator.getPositionStream(locationOptions).listen((position) {
        if (position != null) {
          _updateCurrentPosition(position);
        }
      });
    } on PlatformException catch (_) {
      print("Permission denied");
    }
  }

  @override
  void dispose() {
    _positionStream.cancel();
    super.dispose();
  }

  void _updateCurrentPosition(Position position) {
    _currentPosition = LatLng(position.latitude, position.longitude);

    _moveMarker(position);
    _refreshCameraPosition();
    _geocodeCurrentPosition();
  }

  void _moveMarker(Position position) {
    var markerId = MarkerId("currentPos");
    setState(() {
      markers[markerId] =
          Marker(markerId: markerId, position: _currentPosition);
    });
  }

  void _refreshCameraPosition() {
    if (_controller != null && _shouldRecenterMap) {
      _controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPosition, zoom: _currentZoom),
      ));
    }
  }

  void _geocodeCurrentPosition() async {
    var resultList = await _geolocator.placemarkFromCoordinates(
        _currentPosition.latitude, _currentPosition.longitude,
        localeIdentifier: "id-ID");

    if (resultList.length > 0) {
      Placemark firstResult = resultList[0];

      String textResult = firstResult.thoroughfare +
          " " +
          firstResult.subThoroughfare +
          ", " +
          firstResult.locality;

      setState(() {
        _textToDisplay = textResult;
      });
    }
  }

  void _shareCurrentLocation() {
    String stringToShare = '';

    stringToShare += 'Saya sedang berada di "' + _textToDisplay + '"';

    stringToShare += "\n\n";

    stringToShare += "http://www.google.com/maps/place/" + _currentPosition.latitude.toString() + "," + _currentPosition.longitude.toString();

    Share.share(stringToShare);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: _currentPosition, zoom: _currentZoom),
            mapType: MapType.normal,
            onMapCreated: (controller) {
              _controller = controller;
            },
            onCameraMove: (cameraPosition) {
              _currentZoom = cameraPosition.zoom;

              //disable recenter, reenable after 3 second
              _shouldRecenterMap = false;
              if (_mapDragTimer != null && _mapDragTimer.isActive) {
                _mapDragTimer.cancel();
              }
              _mapDragTimer = Timer(Duration(seconds: 3), () {
                _shouldRecenterMap = true;
              });
            },
            markers: Set<Marker>.of(markers.values),
          ),
          SafeArea(
            child: Container(
              padding: EdgeInsets.all(8.0),
              width: double.infinity,
              child: Card(
                child: Container(
                  height: 60.0,
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(_textToDisplay),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.share),
        onPressed: () {
          _shareCurrentLocation();
        },
      ),
    );
  }
}
