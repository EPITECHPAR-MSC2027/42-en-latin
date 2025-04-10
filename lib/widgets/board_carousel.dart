import 'dart:developer' as developer;
import 'package:fluter/providers/board_provider.dart';
import 'package:fluter/providers/theme_provider.dart';
import 'package:fluter/screens/lists_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BoardCarousel extends StatelessWidget {
  final int maxBoards;

  const BoardCarousel({Key? key, this.maxBoards = 5}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    developer.log('Building BoardCarousel with maxBoards: $maxBoards');
    
    return Consumer2<BoardsProvider, ThemeProvider>(
      builder: (context, boardsProvider, themeProvider, child) {
        developer.log('BoardCarousel rebuild with ${boardsProvider.recentBoards.length} recent boards');
        
        if (boardsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (boardsProvider.error != null) {
          return Center(child: Text('Error: ${boardsProvider.error}'));
        }

        final recentBoards = boardsProvider.recentBoards;
        
        if (recentBoards.isEmpty) {
          developer.log('No recent boards found');
          return Center(
            child: Text(
              'No recent boards',
              style: TextStyle(
                color: themeProvider.vertText.withOpacity(0.5),
              ),
            ),
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
                  color: themeProvider.vertText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  height: 145,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recentBoards.length,
                    itemBuilder: (context, index) {
                      final board = recentBoards[index];
                      return GestureDetector(
                        onTap: () async {
                          await boardsProvider.markBoardAsOpened(board.id);
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
                          color: themeProvider.vertGris,
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
                                    color: themeProvider.vertText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Last opened : ${_formatDate(board.lastOpened)}',
                                  style: GoogleFonts.itim(
                                    color: themeProvider.vertText,
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
                Positioned(
                  top: -83,
                  right: 5,
                  child: Image.asset(
                    'documentation/pic2.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
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
