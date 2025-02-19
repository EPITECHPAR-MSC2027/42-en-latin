import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/secrets.dart';
import 'services/trello_service.dart';
import 'providers/workspace_provider.dart';
import 'screens/home_screen.dart';

void main() {
  final trelloService = TrelloService(
    apiKey: Secrets.trelloApiKey,
    token: Secrets.trelloToken,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<TrelloService>.value(value: trelloService),
        ChangeNotifierProvider<WorkspaceProvider>(
          create: (_) => WorkspaceProvider(trelloService: trelloService),
        ),
        ChangeNotifierProvider<ListProvider>(
          create: (_) => ListProvider(trelloService: trelloService),
        ),
        ChangeNotifierProvider<CardProvider>( 
          create: (_) => CardProvider(trelloService: trelloService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trello App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
