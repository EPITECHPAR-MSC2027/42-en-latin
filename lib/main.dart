import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/secrets.dart'; // Importez le fichier secrets
import 'services/trello_service.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<TrelloService>(
          create: (_) => TrelloService(
            apiKey: Secrets.trelloApiKey,
            token: Secrets.trelloToken,
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trello App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}