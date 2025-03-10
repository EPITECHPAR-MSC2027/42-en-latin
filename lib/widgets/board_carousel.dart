import 'package:fluter/providers/board_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BoardCarousel extends StatelessWidget {
  
  const BoardCarousel({
    super.key,
    this.sortByLastOpened = false,
  });
  final bool sortByLastOpened;

  @override
  Widget build(BuildContext context) {
    return Consumer<BoardsProvider>(
      builder: (context, boardsProvider, child) {
        if (boardsProvider.boards.isEmpty) {
          return const Center(
            child: Text('Aucun board récent'),
          );
        }

        // Trier les boards selon le critère choisi
        final recentBoards = List.from(boardsProvider.boards)
          ..sort((a, b) => sortByLastOpened
              ? b.lastOpened.compareTo(a.lastOpened)
              : b.lastModified.compareTo(a.lastModified),);
        
        // Prendre seulement les 3 derniers
        final latestBoards = recentBoards.take(3).toList();

        return SizedBox(
          height: 160,
          child: PageView.builder(
            padEnds: false,
            controller: PageController(viewportFraction: 0.85),
            itemCount: latestBoards.length,
            itemBuilder: (context, index) {
              final board = latestBoards[index];
              return GestureDetector(
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    '/board',
                    arguments: board.id,
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          board.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dernière modification: ${_formatDate(board.lastModified)}',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 
