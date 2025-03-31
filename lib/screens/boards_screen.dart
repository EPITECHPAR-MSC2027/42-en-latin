import 'package:fluter/providers/board_provider.dart';
import 'package:fluter/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({required this.workspaceId, required this.workspaceName, super.key}
    );
  
  final String workspaceId;
  final String workspaceName;

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeBoards();
  }

  void _initializeBoards() {
    Future.microtask(() async {
      await _loadBoards();
    });
  }

  Future<void> _loadBoards() async {
    try {
      await Provider.of<BoardsProvider>(context, listen: false).fetchBoards();
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addBoardDialog(BuildContext context, BoardsProvider provider) async {
    String name = '';
    String desc = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Créer un Board'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(labelText: 'Nom du board'),
              onChanged: (val) => name = val,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Description'),
              onChanged: (val) => desc = val,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              await provider.addBoard('workspaceId', name, desc);
              Navigator.pop(context);
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  Future<void> _editBoardDialog(BuildContext context, board, BoardsProvider provider) async {
    String newName = board.name;
    String newDesc = board.desc ?? '';

    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Modifier Board'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: TextEditingController(text: newName),
              decoration: const InputDecoration(labelText: 'Nom'),
              onChanged: (val) => newName = val,
            ),
            TextField(
              controller: TextEditingController(text: newDesc),
              decoration: const InputDecoration(labelText: 'Description'),
              onChanged: (val) => newDesc = val,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              await provider.editBoard(board.id, newName, newDesc);
              Navigator.pop(context);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBoardDialog(BuildContext context, board, BoardsProvider provider) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Supprimer Board'),
        content: Text('Voulez-vous supprimer "${board.name}" ?'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              await provider.removeBoard(board.id);
              Navigator.pop(context);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEDE3),
      body: Column(
        children: [
          AppBar(
            backgroundColor: const Color(0xFFC0CDA9),
            centerTitle: true,
            title: Text('Vos Boards',
                style: GoogleFonts.itim(
                    fontSize: 30, fontWeight: FontWeight.bold, color: const Color(0xFF889596))),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text('Erreur: $_errorMessage'))
                    : Consumer<BoardsProvider>(
                        builder: (context, provider, child) {
                          final boards = provider.boards;
                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: boards.length,
                            itemBuilder: (context, index) {
                              final board = boards[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                                margin: const EdgeInsets.only(bottom: 16),
                                child: ListTile(
                                  title: Text(board.name,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  subtitle: Text(board.desc ?? 'Aucune description'),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (String value) async {
                                      if (value == 'edit') {
                                        await _editBoardDialog(context, board, provider);
                                      } else if (value == 'delete') {
                                        await _deleteBoardDialog(context, board, provider);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                                      const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _addBoardDialog(context, Provider.of<BoardsProvider>(context, listen: false));
          _initializeBoards(); // Recharge les boards après ajout
        },
        backgroundColor: const Color(0xFFC0CDA9),
        child: const Icon(Icons.add, color: Color(0xFFD97C83)),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
