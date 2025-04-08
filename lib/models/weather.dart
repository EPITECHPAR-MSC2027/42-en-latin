class Weather {
  factory Weather.fromJson(Map<String, dynamic> json)
  {
    return Weather (cityName: json['name'], temperature: json['main']['temp'].toDouble(), mainCondition: json['weather'][0]['main'],);
  }
  // ignore: sort_unnamed_constructors_first
  Weather({ 
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    });
  final String cityName;
  final double temperature;
  final String mainCondition;
}
