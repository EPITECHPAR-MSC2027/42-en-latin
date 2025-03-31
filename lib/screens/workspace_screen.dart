// ignore_for_file: use_build_context_synchronously

import 'package:fluter/models/board.dart';
import 'package:fluter/providers/workspace_provider.dart';
import 'package:fluter/screens/boards_screen.dart';
import 'package:fluter/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  final Map<String, List<Board>> _workspaceBoards = {};

  @override
  void initState() {
    super.initState();
    _initializeWorkspaces();
  }

  void _initializeWorkspaces() {
    Future.microtask(() async {
      await _loadWorkspaces();
    });
  }

  Future<void> _fetchBoardsForWorkspaces() async {
    try {
      final workspaceProvider = Provider.of<WorkspaceProvider>(
        context,
        listen: false,
      );
      for (final workspace in workspaceProvider.workspaces) {
        final List<Board> boards = await workspaceProvider
            .fetchBoardsByWorkspace(workspace.id);
        setState(() {
          _workspaceBoards[workspace.id] = boards;
        });
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  Future<void> _loadWorkspaces() async {
    try {
      await Provider.of<WorkspaceProvider>(
        context,
        listen: false,
      ).fetchWorkspaces();
      await _fetchBoardsForWorkspaces();
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addWorkspaceDialog(
    BuildContext context,
    WorkspaceProvider provider,
  ) async {
    String name = '';
    String displayName = '';
    String desc = '';

    await showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Créer un Workspace'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  decoration: const InputDecoration(labelText: 'Nom'),
                  onChanged: (String val) => name = val,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Nom affiché'),
                  onChanged: (String val) => displayName = val,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  onChanged: (String val) => desc = val,
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () async {
                  await provider.addWorkspace(name, displayName, desc);
                  Navigator.pop(context);
                },
                child: const Text('Créer'),
              ),
            ],
          ),
    );
  }

  Future<void> _editWorkspaceDialog(
    BuildContext context,
    workspace,
    WorkspaceProvider provider,
  ) async {
    String newDisplayName = workspace.displayName;
    String newDesc = workspace.desc ?? '';

    await showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Modifier Workspace'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: TextEditingController(text: newDisplayName),
                  decoration: const InputDecoration(labelText: 'Nom affiché'),
                  onChanged: (String val) => newDisplayName = val,
                ),
                TextField(
                  controller: TextEditingController(text: newDesc),
                  decoration: const InputDecoration(labelText: 'Description'),
                  onChanged: (String val) => newDesc = val,
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () async {
                  await provider.editWorkspace(
                    workspace.id,
                    newDisplayName,
                    newDesc,
                  );
                  Navigator.pop(context);
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteWorkspaceDialog(
    BuildContext context,
    workspace,
    WorkspaceProvider provider,
  ) async {
    await showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Supprimer Workspace'),
            content: Text(
              'Êtes-vous sûr de vouloir supprimer le workspace "${workspace.displayName}" ?',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () async {
                  await provider.removeWorkspace(workspace.id);
                  // ignore: duplicate_ignore
                  // ignore: use_build_context_synchronously
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
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Utilisation d'un Column avec Expanded pour prendre tout l'espace
          Column(
            children: [
              AppBar(
                backgroundColor: const Color(0xFFC0CDA9),
                centerTitle: true,
                elevation: 0,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Vos WorkSpaces',
                      style: GoogleFonts.itim(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF889596),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                _errorMessage != null
                    ? Center(child: Text('Erreur: $_errorMessage'))
                    : Expanded(
                      child: Consumer<WorkspaceProvider>(
                        builder: (context, provider, child) {
                          final workspaces = provider.workspaces;
                          if (workspaces.isEmpty) {
                            return const Center(
                              child: Text('Aucun workspace trouvé.'),
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: workspaces.length,
                            itemBuilder: (context, index) {
                              final workspace = workspaces[index];
                              final boards =
                                  _workspaceBoards[workspace.id]
                                      ?.take(3)
                                      .toList() ??
                                  [];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                                margin: const EdgeInsets.only(bottom: 10),
                                color: const Color(0XFFC9D2E3),
                                child: Column(
                                  children: [
                                    ListTile(
                                      contentPadding: const EdgeInsets.all(16),
                                      title: Text(
                                        workspace.displayName,
                                        style: const TextStyle(
                                          color: Color(
                                                          0xFFC27C88,
                                                        ), 
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        workspace.desc ?? 'Aucune description',
                                      ),
                                      trailing: PopupMenuButton<String>(
                                        onSelected: (String value) async {
                                          if (value == 'edit') {
                                            await _editWorkspaceDialog(
                                              context,
                                              workspace,
                                              provider,
                                            );
                                          } else if (value == 'delete') {
                                            await _deleteWorkspaceDialog(
                                              context,
                                              workspace,
                                              provider,
                                            );
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

                                            builder: (context) =>BoardScreen(
                                              workspaceId: workspace.id,
                                              workspaceName: workspace.displayName,
                                            ),

                                          ),
                                        );
                                        _initializeWorkspaces();
                                      },
                                    ),
                                    if (boards.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 16,
                                        ),
                                        child: Row(
                                          children:
                                              boards.map((board) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 5,
                                                      ),
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      // Logique pour naviguer vers un board spécifique si nécessaire
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      minimumSize: const Size(
                                                        100,
                                                        40,
                                                      ),
                                                      backgroundColor:
                                                          const Color(
                                                            0xFF889596,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      board.name,
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFFD4F0CC,
                                                        ), 
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
            ],
          ),
          // Positionner l'image de façon fixe à gauche
          Positioned(
            left: 0,
            top: -20,
            child: SafeArea(
              child: Image.asset(
                'documentation/pic.png',
                height: 130,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            bottom: 80,
            left: 20,
          ), // Augmenter l'espacement en bas
          child: FloatingActionButton(
            onPressed: () async {
              await _addWorkspaceDialog(
                context,
                Provider.of<WorkspaceProvider>(context, listen: false),
              );
              _initializeWorkspaces();
            },
            backgroundColor: const Color(0xFFC0CDA9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add, color: Color(0xFFD97C83)),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
