import 'package:fluter/providers/board_provider.dart';
import 'package:fluter/screens/lists_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BoardCarousel extends StatelessWidget {
  const BoardCarousel({
    super.key,
    this.maxBoards = 5,
  });

  final int maxBoards;

  @override
  Widget build(BuildContext context) {
    return Consumer<BoardsProvider>(
      builder: (context, boardsProvider, child) {
        final recentBoards = boardsProvider.getRecentBoards(limit: maxBoards);

        if (recentBoards.isEmpty) {
          return const Center(
            child: Text('No recent boards'),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Latest boards',
                style: GoogleFonts.itim(
                  fontSize: 20,
                  color:  const Color(0xFF314A43),
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 145,
              child: PageView.builder(
                padEnds: false,
                controller: PageController(viewportFraction: 0.85),
                itemCount: recentBoards.length,
                itemBuilder: (context, index) {
                  final board = recentBoards[index];
                  return GestureDetector(
                    onTap: () async {
                      await boardsProvider.markBoardAsOpened(board.id);
                      if (!context.mounted) return;
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListsScreen(
                            boardId: board.id,
                            boardName: board.name,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      color: const Color(0xFFC0CCC9),
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
                              board.name,
                              style: GoogleFonts.itim(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color:  const Color(0xFF314A43),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Last opened : ${_formatDate(board.lastOpened)}',
                              style: GoogleFonts.itim(
                              color:  const Color(0xFF314A43),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 
