class Weather {
  Weather({ 
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    });
  final String cityName;
  final double temperature;
  final String mainCondition;
  factory Weather.fromJson(Map<String, dynamic> json)
  {
    return Weather (cityName: json['name'], temperature: json['main']['temp'].toDouble(), mainCondition: json['weather'][0]['main'],);
  }
}