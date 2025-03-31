import 'package:fluter/config/secrets.dart';
import 'package:fluter/providers/activity_provider.dart';
import 'package:fluter/providers/board_provider.dart';
import 'package:fluter/providers/card_provider.dart';
import 'package:fluter/providers/favorites_provider.dart';
import 'package:fluter/providers/list_provider.dart';
import 'package:fluter/providers/notification_provider.dart';
import 'package:fluter/providers/theme_provider.dart';
import 'package:fluter/providers/user_provider.dart';
import 'package:fluter/providers/workspace_provider.dart';
import 'package:fluter/screens/home_screen.dart';
import 'package:fluter/screens/profile_screen.dart';
import 'package:fluter/screens/workspace_screen.dart';
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
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(trelloService: trelloService),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(trelloService: trelloService),
        ),
        ChangeNotifierProvider<FavoritesProvider>(
          create: (context) => FavoritesProvider(trelloService: trelloService),
        ),
        ChangeNotifierProvider(
          create: (context) => ActivityProvider(
            trelloService: trelloService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// The main application widget.
class MyApp extends StatelessWidget {
  /// The main application widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Trello App',
          theme: ThemeData(
            primaryColor: themeProvider.vertGris,
            scaffoldBackgroundColor: themeProvider.beige,
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: themeProvider.vertText),
              bodyMedium: TextStyle(color: themeProvider.vertText),
              titleLarge: TextStyle(color: themeProvider.vertText),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: themeProvider.vertGris,
              titleTextStyle: TextStyle(
                color: themeProvider.vertText,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: themeProvider.vertGris,
              selectedItemColor: themeProvider.vertText,
              unselectedItemColor: themeProvider.vertText.withOpacity(0.5),
            ),
            cardTheme: CardTheme(
              color: themeProvider.blanc,
              elevation: 2,
            ),
            listTileTheme: ListTileThemeData(
              textColor: themeProvider.vertText,
              iconColor: themeProvider.vertText,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.vertGris,
                foregroundColor: themeProvider.vertText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          routes: {
            '/': (context) => const HomeScreen(),
            '/workspace': (context) => const WorkspaceScreen(),
            '/profile': (context) => const ProfileScreen(),
          },
        );
      },
    );
  }
}
