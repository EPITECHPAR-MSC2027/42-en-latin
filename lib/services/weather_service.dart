import 'dart:convert';

import 'package:fluter/models/weather.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
class WeatherService {
  static const BASE_URL = 'http://api.openweathermap.org/data/2.5/weather';
  final String apiKey;
  WeatherService(this.apiKey);
  Future<Weather> getWeather(String cityName) async {
    final response = await http.get(Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric'));
    
    if (response.statusCode == 200)
    {
      return Weather.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    else
    {
      throw Exception('Meteo bug');
    }
  }


Future<String> getCurrentCity() async {

LocationPermission permissionUtil = await Geolocator.checkPermission();
if (permissionUtil == LocationPermission.denied){
  permissionUtil = await Geolocator.requestPermission();
}

Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

List<Placemark> Placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

String? ville = Placemarks[0].locality;
return ville ?? '';
  }
}