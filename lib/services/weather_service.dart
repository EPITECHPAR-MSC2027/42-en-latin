import 'dart:convert';

import 'package:fluter/models/weather.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
class WeatherService {
  WeatherService(this.apiKey);
  // ignore: public_member_api_docs, constant_identifier_names
  static const String BASE_URL = 'http://api.openweathermap.org/data/2.5/weather';
  final String apiKey;
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

final Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

// ignore: non_constant_identifier_names
final List<Placemark> Placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

final String? ville = Placemarks[0].locality;
return ville ?? '';
  }
}
