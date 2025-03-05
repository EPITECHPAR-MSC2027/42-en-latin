import 'package:fluter/models/board.dart';
import 'package:fluter/providers/board_provider.dart';
import 'package:fluter/providers/workspace_provider.dart';
import 'package:fluter/utils/templates.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageBoardsScreen extends StatefulWidget {
  const ManageBoardsScreen({
    required this.workspaceId,
    required this.workspaceName,
    super.key,
  });

  final String workspaceId;
  final String workspaceName;

  @override
  ManageBoardsScreenState createState() => ManageBoardsScreenState();
}

class ManageBoardsScreenState extends State<ManageBoardsScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeBoards();
  }

  void _initializeBoards() {
    Future.microtask(() async => _loadBoards());
  }

  /// **Charge les boards du workspace**
  Future<void> _loadBoards() async {
    try {
      await Provider.of<WorkspaceProvider>(context, listen: false)
          .fetchBoardsByWorkspace(widget.workspaceId);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Boards de ${widget.workspaceName}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Erreur: $_errorMessage'))
              : Consumer<WorkspaceProvider>(
                  builder: (BuildContext context, WorkspaceProvider provider, Widget? child) {
                    final boards = provider.workspaceBoards;
                    if (boards.isEmpty) {
                      return const Center(child: Text('Aucun board trouvé pour ce workspace.'));
                    }

                    return ListView.builder(
                      itemCount: boards.length,
                      itemBuilder: (BuildContext context, int index) {
                        final board = boards[index];
                        return ListTile(
                          title: Text(board.name),
                          subtitle: Text(board.desc),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await Provider.of<BoardsProvider>(context, listen: false)
                                  .removeBoard(board.id);
                              await _loadBoards();
                            },
                          ),
                          onTap: () async {
                            await _editBoardDialog(context, board);
                          },
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async => _addBoardDialog(context),
      ),
    );
  }

  Future<void> _addBoardDialog(BuildContext context) async {
    final String name = '';
    final String desc = '';
    String? selectedTemplateId;

    await showDialog(
      context: context,
      builder: (context) {
        return _BoardDialog(
          title: 'Créer un Board',
          onSave: (name, desc, templateId) async {
            final boardsProvider = Provider.of<BoardsProvider>(context, listen: false);
            await boardsProvider.addBoard(widget.workspaceId, name, desc, templateId: templateId);
            await _loadBoards();
          },
          name: name,
          desc: desc,
          selectedTemplateId: selectedTemplateId,
        );
      },
    );
  }

  Future<void> _editBoardDialog(BuildContext context, Board board) async {
    final nameController = TextEditingController(text: board.name);
    final descController = TextEditingController(text: board.desc);

    await showDialog(
      context: context,
      builder: (context) {
        return _BoardDialog(
          title: 'Modifier Board',
          onSave: (name, desc, _) async {
            final boardsProvider = Provider.of<BoardsProvider>(context, listen: false);
            await boardsProvider.editBoard(board.id, name, desc);
            await _loadBoards();
          },
          name: nameController.text,
          desc: descController.text,
        );
      },
    ).then((_) {
      nameController.dispose();
      descController.dispose();
    });
  }
}

class _BoardDialog extends StatefulWidget {
  const _BoardDialog({
    required this.title,
    required this.onSave,
    required this.name,
    required this.desc,
    this.selectedTemplateId,
  });

  final String title;
  final Function(String, String, String?) onSave;
  final String name;
  final String desc;
  final String? selectedTemplateId;

  @override
  _BoardDialogState createState() => _BoardDialogState();
}

class _BoardDialogState extends State<_BoardDialog> {
  late String name;
  late String desc;
  String? selectedTemplateId;

  @override
  void initState() {
    super.initState();
    name = widget.name;
    desc = widget.desc;
    selectedTemplateId = widget.selectedTemplateId;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
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
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            widget.onSave(name, desc, selectedTemplateId);
            Navigator.pop(context);
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
