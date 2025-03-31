import 'package:fluter/models/list.dart';
import 'package:fluter/providers/list_provider.dart';
import 'package:fluter/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// **Écran de gestion des listes d'un board**
class ManageListsScreen extends StatefulWidget {
  /// **Constructeur de ManageListsScreen**
  const ManageListsScreen({
    required this.boardId,
    required this.boardName,
    super.key,
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.beige,
          appBar: AppBar(
            backgroundColor: themeProvider.vertGris,
            title: Text(
              'Gérer les listes de ${widget.boardName}',
              style: GoogleFonts.itim(
                color: themeProvider.vertText,
              ),
            ),
          ),
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: themeProvider.vertText,
                  ),
                )
              : _errorMessage != null
                  ? Center(
                      child: Text(
                        'Erreur: $_errorMessage',
                        style: TextStyle(color: themeProvider.rouge),
                      ),
                    )
                  : Consumer<ListProvider>(
                      builder: (
                        BuildContext context,
                        ListProvider provider,
                        Widget? child,
                      ) {
                        if (provider.lists.isEmpty) {
                          return Center(
                            child: Text(
                              'Aucune liste trouvée.',
                              style: TextStyle(color: themeProvider.vertText),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.lists.length,
                          itemBuilder: (context, index) {
                            final list = provider.lists[index];
                            return Card(
                              color: themeProvider.bleuClair,
                              child: ListTile(
                                title: Text(
                                  list.name,
                                  style: TextStyle(color: themeProvider.vertText),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: themeProvider.vertText,
                                      ),
                                      onPressed: () => _editListDialog(context, list),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: themeProvider.rouge,
                                      ),
                                      onPressed: () => _deleteList(context, list),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: themeProvider.vertGris,
            onPressed: () => _addListDialog(context),
            child: Icon(Icons.add, color: themeProvider.rouge),
          ),
        );
      },
    );
  }

  /// **Affiche le dialogue pour créer une liste**
  Future<void> _addListDialog(BuildContext context) async {
    String name = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'Créer une Liste',
          style: TextStyle(color: context.watch<ThemeProvider>().vertText),
        ),
        content: TextField(
          decoration: InputDecoration(
            labelText: 'Nom',
            labelStyle: TextStyle(color: context.watch<ThemeProvider>().vertText),
          ),
          style: TextStyle(color: context.watch<ThemeProvider>().vertText),
          onChanged: (String val) => name = val,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(color: context.watch<ThemeProvider>().vertText),
            ),
          ),
          TextButton(
            onPressed: () async {
              final provider = Provider.of<ListProvider>(context, listen: false);
              await provider.addList(widget.boardId, name);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: Text(
              'Créer',
              style: TextStyle(color: context.watch<ThemeProvider>().vertText),
            ),
          ),
        ],
      ),
    );
  }

  /// **Affiche le dialogue pour modifier une liste**
  Future<void> _editListDialog(BuildContext context, ListModel list) async {
    String newName = list.name;

    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'Modifier la Liste',
          style: TextStyle(color: context.watch<ThemeProvider>().vertText),
        ),
        content: TextField(
          controller: TextEditingController(text: newName),
          decoration: InputDecoration(
            labelText: 'Nom de la liste',
            labelStyle: TextStyle(color: context.watch<ThemeProvider>().vertText),
          ),
          style: TextStyle(color: context.watch<ThemeProvider>().vertText),
          onChanged: (String val) => newName = val,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(color: context.watch<ThemeProvider>().vertText),
            ),
          ),
          TextButton(
            onPressed: () async {
              final listProvider = Provider.of<ListProvider>(
                context,
                listen: false,
              );
              await listProvider.editList(list.id, newName);
              await listProvider.fetchListsByBoard(widget.boardId);

              setState(() {});
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: Text(
              'Enregistrer',
              style: TextStyle(color: context.watch<ThemeProvider>().vertText),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteList(BuildContext context, ListModel list) async {
    final listProvider = Provider.of<ListProvider>(context, listen: false);
    await listProvider.removeList(list.id);
    await listProvider.fetchListsByBoard(widget.boardId);

    setState(() {});
  }
}
