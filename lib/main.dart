import 'dart:math';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AmapLocation.instance.init(iosKey: '59ef99f3ccb1fc68f86397e28846789b');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

var _location = "";
var times = 0;
AmapController _controller;
var lat = 35.28114860377302;
var lng = 118.53188422187806;

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              flex: 1,
              child: AmapView(
                mapType: MapType.Night,
                showZoomControl: false,
                tilt: 0,
                zoomLevel: 19,
                centerCoordinate: LatLng(lat, lng),
                maskDelay: Duration(milliseconds: 500),
                onMapCreated: (controller) async {
                  _controller = controller;
                },
              ),
            ),
            Text(
              '第$times次获取位置信息：' + _location,
            ),
            RaisedButton(
                child: Text("开始定位"),
                onPressed: () async {
                  //单次定位
                  // if (await requestPermission()) {
                  //   Location location = await AmapLocation.instance
                  //       .fetchLocation();
                  //   print("fuck:" + location.toString());
                  //   lat = location.latLng.latitude;
                  //   lng = location.latLng.longitude;
                  //   setState(() => _location = location.toString());
                  // }

                  // 连续定位
                  if (await requestPermission()) {
                    AmapLocation.instance
                        .listenLocation()
                        .listen((event) =>
                        setState(() {
                          times++;
                          // lat = event.latLng.latitude;
                          // lng = event.latLng.longitude;
                          _location = event.toString();
                        }));
                  }
                }),
            RaisedButton(
              child: Text('停止定位'),
              onPressed: () async {
                if (await requestPermission()) {
                  await AmapLocation.instance.stopLocation();
                  setState(() => null);
                }
              },
            ),
            RaisedButton(
              child: Text('Show my location'),
              onPressed: () async {
                if (await requestPermission()) {
                  _controller.showMyLocation(MyLocationOption(myLocationType: MyLocationType.Show));
                  setState(() => null);
                }
              },
            ),
            RaisedButton(
              child: Text('画线'),
              onPressed: () async {
                if (await requestPermission()) {
                  List<LatLng> _pointList = [];
                  _pointList = [
                    getNextLatLng(),
                    getNextLatLng(),
                    getNextLatLng(),
                    getNextLatLng(),
                  ];
                  var _currentPolyline =
                  await _controller?.addPolyline(PolylineOption(
                    latLngList: _pointList,
                    width: 10,
                    strokeColor: Colors.green,
                  ));
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.ac_unit_rounded),
        onPressed: () {

        },
      ),
    );
  }
}

final random = Random();
LatLng getNextLatLng({LatLng center}) {
  center ??= LatLng(39.90960, 116.397228);
  return LatLng(
    center.latitude + random.nextDouble(),
    center.longitude + random.nextDouble(),
  );
}

Future<bool> requestPermission() async {
  final permissions = await Permission.locationWhenInUse.request();

  if (permissions.isGranted) {
    return true;
  } else {
    // toast('需要定位权限!');
    return false;
  }
}
