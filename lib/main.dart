import 'package:flutter/material.dart';
import 'package:flutter_sun_set_rise_api/WeatherWidget.dart';
import 'package:flutter_sun_set_rise_api/open_weather.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Position lastPosition;

  OpenWeather _openWeather;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  void getCurrentLocation() async {
    lastPosition = await Geolocator.getLastKnownPosition();

    setState(() {});

    loadData();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    getCurrentLocation();
  }

  String getDateTime(var value) {
    var dateFormat = DateFormat('dd-MM-yyyy hh:mm a');
    String dateTime =
        dateFormat.format(DateTime.fromMillisecondsSinceEpoch(value * 1000));
    return dateTime.toString();
  }

  void loadData() async {
    await ApiZ.getOpenWeatherResponseData(lastPosition).then((value) {
      setState(() {
        _openWeather = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Weather App'),
      ),
      body: Container(
        child: WeatherWidget(
          size: Size.infinite,
          weather: 'Snowy',
          snowConfig: SnowConfig(snowNum: 100),
        ),
      ),
    );
  }
}

/*
Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Today date : ${_openWeather?.name ?? ''}'
              '\nSun Rise : ${_openWeather?.sys?.sunrise != null ? getDateTime(_openWeather?.sys?.sunrise) : ''}'
              '\nSun Set : ${_openWeather?.sys?.sunset != null ? getDateTime(_openWeather?.sys?.sunset) : ''}',
              style: Theme.of(context).textTheme.headline6,
            ),
          ],
        ),
      )
 */

class ApiZ {
  static Future<OpenWeather> getOpenWeatherResponseData(
      Position lastPosition) async {
    final response = await http.get(
        'http://api.openweathermap.org/data/2.5/weather?lat=${lastPosition.latitude}&lon=${lastPosition.longitude}&appid=8ddca1552d6734002911a584cc9c9f96');
    if (response.statusCode == 200) {
      var body = json.decode(response.body);

      OpenWeather responseData = OpenWeather.fromJson(body);

      return responseData;
    } else {
      throw Exception();
    }
  }
}
