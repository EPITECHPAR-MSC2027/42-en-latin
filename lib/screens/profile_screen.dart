import 'package:fluter/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('Page de profil à venir'),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
