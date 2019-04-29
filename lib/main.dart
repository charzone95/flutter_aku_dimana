import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kLapanganMerdeka = CameraPosition(
    target: LatLng(3.5913479, 98.6754698),
    zoom: 16.0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: _kLapanganMerdeka,
            mapType: MapType.normal,
            onMapCreated: (controller) {
              _controller.complete(controller);
            },
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
                    child: Text("Sedang melacak posisi kamu.."),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
