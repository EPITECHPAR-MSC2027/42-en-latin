import 'dart:async';

import 'package:fluter/models/board.dart';
import 'package:fluter/providers/board_provider.dart';
import 'package:fluter/providers/workspace_provider.dart';
import 'package:fluter/screens/lists_screen.dart';
import 'package:fluter/screens/manage_BoardsScreen.dart';
import 'package:fluter/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Écran affichant les boards d'un workspace spécifique.
///
/// Cet écran récupère les boards d'un workspace en utilisant `WorkspaceProvider`.
/// L'utilisateur peut voir la liste des boards et en sélectionner un pour afficher ses listes.
///
/// [workspaceId] : Identifiant unique du workspace.
/// [workspaceName] : Nom du workspace affiché dans l'interface.
class BoardsScreen extends StatefulWidget {
  /// Constructeur du `BoardsScreen`
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
    appBar: AppBar(
      title: Text(widget.workspaceName),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Gérer les Boards',
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
            // Correction ici :
            setState(_initializeBoards);
          },
        ),
      ],
    ),
    body: _isLoading
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

                  final List<Board> boards = snapshot.data!;

                  return ListView.builder(
                    itemCount: boards.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Board board = boards[index];

                      return ListTile(
                        title: Text(board.name),
                        subtitle: Text(board.desc),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () async {
                          await Provider.of<BoardsProvider>(context, listen: false)
                              .markBoardAsOpened(board.id);
                          
                          await Navigator.push(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => ListsScreen(
                                boardId: board.id,
                                boardName: board.name,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
    bottomNavigationBar: const BottomNavBar(),
  );
}
}
