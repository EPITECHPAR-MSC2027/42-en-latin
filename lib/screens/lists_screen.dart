import 'package:fluter/models/list.dart';
import 'package:fluter/providers/list_provider.dart';
import 'package:fluter/screens/cards_screen.dart';
import 'package:fluter/screens/manage_lists_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// **Écran affichant les listes d'un board**
class ListsScreen extends StatefulWidget {
  /// **Constructeur de ListsScreen**
  const ListsScreen({
    required this.boardId, required this.boardName, super.key,
  });

  /// **ID du board**
  final String boardId;

  /// **Nom du board**
  final String boardName;

  @override
  ListsScreenState createState() => ListsScreenState();
}

/// **État de ListsScreen**
class ListsScreenState extends State<ListsScreen> {
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
      appBar: AppBar(
        title: Text('Listes de ${widget.boardName}'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Gérer les Listes',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder:
                      (BuildContext context) => ManageListsScreen(
                        boardId: widget.boardId,
                        boardName: widget.boardName,
                      ),
                ),
              );
            },
          ),
        ],
      ),
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
                    return const Center(
                      child: Text('Aucune liste trouvée pour ce board.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: provider.lists.length,
                    itemBuilder: (BuildContext context, int index) {
                      final ListModel list = provider.lists[index];

                      return ListTile(
                        title: Text(list.name),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder:
                                  (BuildContext context) => CardsScreen(
                                    listId: list.id,
                                    listName: list.name,
                                  ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
    );
  }
}
