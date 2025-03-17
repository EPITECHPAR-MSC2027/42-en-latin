import 'package:fluter/providers/favorites_provider.dart';
import 'package:fluter/providers/board_provider.dart';
import 'package:fluter/screens/lists_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoritesCarousel extends StatelessWidget {
  // ignore: public_member_api_docs
  const FavoritesCarousel({super.key});

  Color _getBackgroundColor(String? colorStr) {
    if (colorStr == null) return Colors.blue;
    return Color(int.parse('FF${colorStr.substring(1)}', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final favorites = favoritesProvider.favorites;

        if (favorites.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'Aucun tableau favori trouvé.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        }

        // Diviser les favoris en deux groupes pour les deux lignes
        final int halfLength = (favorites.length / 2).ceil();
        final firstRowItems = favorites.take(halfLength).toList();
        final secondRowItems = favorites.length > halfLength
            ? favorites.skip(halfLength).toList()
            : [];

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Tableaux favoris',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Première ligne de carousel
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: firstRowItems.length,
                  itemBuilder: (context, index) {
                    final favorite = firstRowItems[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: SizedBox(
                        width: 160,
                        child: Card(
                          elevation: 4,
                          color: _getBackgroundColor(favorite.backgroundColor),
                          child: InkWell(
                            onTap: () async {
                              await Provider.of<BoardsProvider>(context, listen: false)
                                  .markBoardAsOpened(favorite.id);
                              
                              // ignore: use_build_context_synchronously
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => ListsScreen(
                                    boardId: favorite.id,
                                    boardName: favorite.name,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.white.withOpacity(0.9),
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    favorite.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Espace entre les deux lignes
              const SizedBox(height: 10),
              // Deuxième ligne de carousel (si des items existent)
              if (secondRowItems.isNotEmpty)
                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: secondRowItems.length,
                    itemBuilder: (context, index) {
                      final favorite = secondRowItems[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: SizedBox(
                          width: 160,
                          child: Card(
                            elevation: 4,
                            color: _getBackgroundColor(favorite.backgroundColor),
                            child: InkWell(
                              onTap: () async {
                                await Provider.of<BoardsProvider>(context, listen: false)
                                    .markBoardAsOpened(favorite.id);
                                
                                // ignore: use_build_context_synchronously
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => ListsScreen(
                                      boardId: favorite.id,
                                      boardName: favorite.name,
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.white.withOpacity(0.9),
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      favorite.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}