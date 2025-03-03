import 'package:fluter/models/list.dart';
import 'package:fluter/providers/list_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// **Écran de gestion des listes d'un board**
class ManageListsScreen extends StatefulWidget {
  /// **Constructeur de ManageListsScreen**
  const ManageListsScreen({
    required this.boardId, required this.boardName, super.key,
  });

  /// **ID du board**
  final String boardId;

  /// **Nom du board**
  final String boardName;

  @override
  ManageListsScreenState createState() => ManageListsScreenState();
}

/// **État de ManageListsScreen**
class ManageListsScreenState extends State<ManageListsScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async => _loadLists());
  }

  /// **Charge les listes du board**
  Future<void> _loadLists() async {
    try {
      await Provider.of<ListProvider>(
        context,
        listen: false,
      ).fetchListsByBoard(widget.boardId);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gérer les listes de ${widget.boardName}')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text('Erreur: $_errorMessage'))
              : Consumer<ListProvider>(
                builder: (
                  BuildContext context,
                  ListProvider provider,
                  Widget? child,
                ) {
                  if (provider.lists.isEmpty) {
                    return const Center(child: Text('Aucune liste trouvée.'));
                  }

                  return ListView.builder(
                    itemCount: provider.lists.length,
                    itemBuilder: (BuildContext context, int index) {
                      final ListModel list = provider.lists[index];

                      return ListTile(
                        title: Text(list.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed:
                                  () async =>
                                      _editListDialog(context, list, provider),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await provider.removeList(list.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed:
            () async => _addListDialog(
              context,
              Provider.of<ListProvider>(context, listen: false),
            ),
      ),
    );
  }

  /// **Affiche le dialogue pour créer une liste**
  Future<void> _addListDialog(
    BuildContext context,
    ListProvider provider,
  ) async {
    String name = '';

    await showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Créer une Liste'),
            content: TextField(
              decoration: const InputDecoration(labelText: 'Nom'),
              onChanged: (String val) => name = val,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () async {
                  await provider.addList(widget.boardId, name);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                child: const Text('Créer'),
              ),
            ],
          ),
    );
  }

  /// **Affiche le dialogue pour modifier une liste**
  Future<void> _editListDialog(
    BuildContext context,
    ListModel list,
    ListProvider provider,
  ) async {
    String newName = list.name;

    await showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Modifier la Liste'),
            content: TextField(
              controller: TextEditingController(text: newName),
              decoration: const InputDecoration(labelText: 'Nom'),
              onChanged: (String val) => newName = val,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () async {
                  await provider.editList(list.id, newName);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
    );
  }
}
