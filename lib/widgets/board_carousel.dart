import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/board_provider.dart';
import '../models/board.dart';

class BoardCarousel extends StatelessWidget {
  const BoardCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BoardProvider>(
      builder: (context, boardProvider, child) {
        // Récupérer les boards et les trier par date de dernière modification
        final recentBoards = boardProvider.boards
          ..sort((a, b) => b.lastModified.compareTo(a.lastModified));
        
        // Prendre seulement les 3 derniers
        final latestBoards = recentBoards.take(3).toList();

        if (latestBoards.isEmpty) {
          return const Center(
            child: Text('Aucun board récent'),
          );
        }

        return SizedBox(
          height: 160,
          child: PageView.builder(
            padEnds: false,
            controller: PageController(viewportFraction: 0.85),
            itemCount: latestBoards.length,
            itemBuilder: (context, index) {
              final board = latestBoards[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
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