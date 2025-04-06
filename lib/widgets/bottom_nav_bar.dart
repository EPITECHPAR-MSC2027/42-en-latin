import 'package:flutter/material.dart';
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _getCurrentIndex(context),
      onTap: (index) async => _onItemTapped(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.work),
          label: 'Workspace',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        
      ],
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
    switch (currentRoute) {
      case '/':
        return 0;
      case '/workspace':
        return 1;
      case '/profile':
        return 2;
      default:
        return 0;
    }
  }

  Future<void> _onItemTapped(BuildContext context, int index) async {
    String route;
    switch (index) {
      case 0:
        route = '/';
        break;
      case 1:
        route = '/workspace';
        break;
      case 2:
        route = '/profile';
        break;
      default:
        route = '/';
    }
    await Navigator.pushReplacementNamed(context, route);
  }
} 
