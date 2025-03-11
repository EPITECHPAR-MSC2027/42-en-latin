import 'package:fluter/providers/favorites_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoritesCarousel extends StatelessWidget {
  // ignore: public_member_api_docs
  const FavoritesCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final favorites = favoritesProvider.favorites;

        if (favorites.isEmpty) {
          return const Center(child: Text('Aucun favoris trouvé.'));
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final favorite = favorites[index];
            return Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(favorite.name),
                  const SizedBox(height: 10),
                  // Vous pouvez ajouter une image ou un lien ici
                  Text(favorite.url),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
