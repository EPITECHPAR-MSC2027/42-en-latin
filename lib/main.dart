import 'package:fluter/config/secrets.dart';
import 'package:fluter/providers/board_provider.dart';
import 'package:fluter/providers/card_provider.dart';
import 'package:fluter/providers/list_provider.dart';
import 'package:fluter/providers/workspace_provider.dart';
import 'package:fluter/screens/home_screen.dart';
import 'package:fluter/screens/workspace_screen.dart';
import 'package:fluter/screens/profile_screen.dart';
import 'package:fluter/services/trello_service.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

void main() {
  final TrelloService trelloService = TrelloService(
    apiKey: Secrets.trelloApiKey,
    token: Secrets.trelloToken,
  );

  runApp(
    MultiProvider(
      providers: <SingleChildWidget>[
        Provider<TrelloService>.value(value: trelloService),
        ChangeNotifierProvider<WorkspaceProvider>(
          create: (_) => WorkspaceProvider(trelloService: trelloService),
        ),
        ChangeNotifierProvider<BoardsProvider>(
          create: (_) => BoardsProvider(trelloService: trelloService),
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
      routes: {
        '/': (context) => const HomeScreen(),
        '/workspace': (context) => const WorkspaceScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}