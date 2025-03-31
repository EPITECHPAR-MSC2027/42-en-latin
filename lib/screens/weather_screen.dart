import 'dart:math';

import 'package:fluter/services/weather_service.dart';
import 'package:flutter/material.dart';
import 'package:weather/weather.dart';

import 'dart:developer';

class WeatherScreen extends StatefulWidget 
{
  const WeatherScreen({super.key});
 @override
 State<WeatherScreen> createState() => _Weatherpagestate();
  //  Widget build(BuildContext context) {
  //    return const WeatherScreen();
  //  }
}

class _Weatherpagestate extends State<WeatherScreen>{
final _weatherService = WeatherService('78cc81394e10143bc3deb2ad6d01de43');
Weather? _weather;



_fetchWeather() async {
 ////parti geolocalisation

 try
 {
  ///print("1");
  //final weather = await _weatherService.getWeather('London');
  final weather = await _weatherService.getWeather('Le Kremlin-Bicêtre');
   print(weather.temperature);
   print(weather.cityName);
   print(weather.mainCondition);
  setState(() {
    _weather = weather as Weather?;
  });
 }
 catch(e)
 {
  print(e);
 }
}

@override
void initState()
{
  super.initState();

  _fetchWeather();
}


@override
Widget build(BuildContext context)
{
  return Scaffold();
}


}