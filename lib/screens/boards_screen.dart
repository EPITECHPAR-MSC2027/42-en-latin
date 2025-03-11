import 'dart:async';
import 'package:fluter/models/board.dart';
import 'package:fluter/providers/board_provider.dart';
import 'package:fluter/providers/workspace_provider.dart';
import 'package:fluter/screens/lists_screen.dart';
import 'package:fluter/screens/manage_BoardsScreen.dart';
import 'package:fluter/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Écran affichant les boards d'un workspace spécifique.
class BoardsScreen extends StatefulWidget {
  const BoardsScreen({
    required this.workspaceId,
    required this.workspaceName,
    super.key,
  });

  final String workspaceId;
  final String workspaceName;

  @override
  State<BoardsScreen> createState() => _BoardsScreenState();
}

class _BoardsScreenState extends State<BoardsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  late Future<List<Board>> _fetchBoardsFuture;
  final bool _isTableView = true; // Gère l'affichage entre Table et Board

  @override
  void initState() {
    super.initState();
    _initializeBoards();
  }

  void _initializeBoards() {
    _fetchBoardsFuture = Future.microtask(_fetchBoards);
  }

  /// **Récupère les boards du workspace.**
  Future<List<Board>> _fetchBoards() async {
    try {
      final WorkspaceProvider workspaceProvider =
          Provider.of<WorkspaceProvider>(context, listen: false);
      return await workspaceProvider.fetchBoardsByWorkspace(widget.workspaceId);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
      return [];
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEDE3), // Fond beige rosé
      appBar: AppBar(
        backgroundColor: const Color(0xFF889596), // Fond de l'AppBar
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            widget.workspaceName,
            style: GoogleFonts.itim(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFC0CDA9),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          /// **Boutons de navigation entre Table et Board**
          const Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            
                SizedBox(width: 10),
               
              ],
            ),
          ),
          
          /// **Affichage du contenu selon le mode sélectionné**
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text('Erreur: $_errorMessage'))
                    : FutureBuilder<List<Board>>(
                        future: _fetchBoardsFuture,
                        builder: (BuildContext context, AsyncSnapshot<List<Board>> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Erreur: ${snapshot.error}'));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text('Aucun board trouvé pour ce workspace.'));
                          }

                          return _isTableView
                              ? _buildTableView(snapshot.data!) // Affichage Table
                              : const Center(
                                  child: Text('Mode Board non implémenté.'),
                                );
                        },
                      ),
          ),
        ],
      ),

      /// **Bouton flottant pour gérer les boards**
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 20),
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => ManageBoardsScreen(
                  workspaceId: widget.workspaceId,
                  workspaceName: widget.workspaceName,
                ),
              ),
            );
            setState(_initializeBoards);
          },
          backgroundColor: const Color(0xFFC0CDA9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.settings, color: Color(0xFFD97C83)),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  

Widget _buildTableView(List<Board> boards) {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Align(
      alignment: Alignment.topCenter, // Évite d'étirer le conteneur sur toute la hauteur
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9, // Limite la largeur si besoin
        ),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ajuste la hauteur selon le contenu
          children: List.generate(
            boards.length,
            (index) {
              final Board board = boards[index];


              return Column(
                children: [
                  ListTile(
                    title: Text(board.name),
                    subtitle: Text(board.desc),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => ListsScreen(
                            boardId: board.id,
                            boardName: board.name,
                          ),
                        ),

                   
                      );
                    },
                  ),
                  if (index < boards.length - 1) // Empêche un divider après le dernier élément
                    const Divider(
                      color: Color(0xFFD97C83),
                      thickness: 1,
                      height: 10, // Espacement vertical
                    ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}

}
