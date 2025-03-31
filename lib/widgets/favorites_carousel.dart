import 'package:fluter/providers/board_provider.dart';
import 'package:fluter/providers/favorites_provider.dart';
import 'package:fluter/screens/lists_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fluter/providers/theme_provider.dart';

class FavoritesCarousel extends StatelessWidget {
  // ignore: public_member_api_docs
  const FavoritesCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<FavoritesProvider, ThemeProvider>(
      builder: (context, favoritesProvider, themeProvider, child) {
        final favorites = favoritesProvider.favorites;

        if (favorites.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                'Aucun tableau favori trouvé.',
                style: TextStyle(
                  fontSize: 16,
                  color: themeProvider.vertText.withOpacity(0.5),
                ),
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
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Favorite Boards',
                  style: GoogleFonts.itim(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.vertText,
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
                          color: themeProvider.vertfavorite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              color: themeProvider.grisClair,
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () async {
                              await Provider.of<BoardsProvider>(context, listen: false)
                                  .markBoardAsOpened(favorite.id);
                              
                              // ignore: use_build_context_synchronously
                              await Navigator.push(
                                // ignore: use_build_context_synchronously
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
                                  const Icon(
                                    Icons.star,
                                    color: Color(0xffffffff),
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    favorite.name,
                                    style: const TextStyle(
                                      color: Color(0xffffffff),
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
                            color: themeProvider.vertfavorite,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(
                                color: themeProvider.grisClair,
                                width: 1,
                              ),
                            ),
                            child: InkWell(
                              onTap: () async {
                                await Provider.of<BoardsProvider>(context, listen: false)
                                    .markBoardAsOpened(favorite.id);
                                
                                // ignore: use_build_context_synchronously
                                await Navigator.push(
                                  // ignore: use_build_context_synchronously
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
                                    const Icon(
                                      Icons.star,
                                      color: Color(0xffffffff),
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      favorite.name,
                                      style: const TextStyle(
                                        color: Color(0xffffffff),
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


