import 'dart:async';

import 'package:fluter/models/board.dart';
import 'package:fluter/providers/board_provider.dart'; // BoardProvider pour add, edit, remove
import 'package:fluter/providers/workspace_provider.dart'; // WorkspaceProvider pour fetchBoardsByWorkspace
import 'package:fluter/screens/lists_screen.dart';
import 'package:fluter/utils/templates.dart';
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

  /// **Récupère les boards du workspace via WorkspaceProvider.**
  Future<List<Board>> _fetchBoards() async {
    try {
      final WorkspaceProvider workspaceProvider =
          Provider.of<WorkspaceProvider>(context, listen: false); // Utilisation de WorkspaceProvider
      return await workspaceProvider.fetchBoardsByWorkspace(widget.workspaceId);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
      return [];
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// **Méthode pour ajouter un board via BoardProvider**
  Future<void> _addBoardDialog(BuildContext context, BoardsProvider provider) async {
    String name = '';
    String desc = '';
    String? selectedTemplateId;

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
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedTemplateId,
              hint: const Text('Sélectionner un template'),
              isExpanded: true,
              items: templateCards.keys.map((templateId) {
                return DropdownMenuItem<String>(
                  value: templateId,
                  child: Text(templateId),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedTemplateId = newValue;
                });
              },
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              // Création d'un board en utilisant BoardProvider
              await provider.addBoard(widget.workspaceId, name, desc, selectedTemplateId);
              Navigator.pop(context);
              setState(_initializeBoards); // Recharge les boards après ajout
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  /// **Méthode pour modifier un board via BoardProvider**
  Future<void> _editBoardDialog(BuildContext context, Board board, BoardsProvider provider) async {
    String newName = board.name;
    String newDesc = board.desc;

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
              await provider.editBoard(board.id, newName, newDesc); // Utilisation de BoardProvider
              Navigator.pop(context);
              setState(_initializeBoards); // Recharge les boards après modification
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  /// **Méthode pour supprimer un board via BoardProvider**
  Future<void> _deleteBoardDialog(BuildContext context, Board board, BoardsProvider provider) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Supprimer Board'),
        content: Text('Voulez-vous supprimer "${board.name}" ?'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              await provider.removeBoard(board.id); // Utilisation de BoardProvider
              Navigator.pop(context);
              setState(_initializeBoards); // Recharge les boards après suppression
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
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFC0CDA9),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(  // Enroulez le body avec un SingleChildScrollView
        child: Column(
          children: [
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
            _isLoading
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
          ],
        ),
      ),
      /// **Bouton flottant pour créer un board**
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 20),
        child: FloatingActionButton(
          onPressed: () async {
            // Affiche la fenêtre de création de board
            await _addBoardDialog(context, context.read<BoardsProvider>());
            setState(_initializeBoards); // Recharge les boards après création
          },
          backgroundColor: const Color(0xFFC0CDA9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.add, color: Color(0xFFD97C83)),
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
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            await _editBoardDialog(context, board, context.read<BoardsProvider>());
                          } else if (value == 'delete') {
                            await _deleteBoardDialog(context, board, context.read<BoardsProvider>());
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Modifier'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Supprimer'),
                            ),
                          ];
                        },
                      ),
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
