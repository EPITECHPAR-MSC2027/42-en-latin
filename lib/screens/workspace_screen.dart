// ignore_for_file: use_build_context_synchronously

import 'package:fluter/models/board.dart';
import 'package:fluter/providers/theme_provider.dart';
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
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'Create a Workspace',
          style: TextStyle(color: context.watch<ThemeProvider>().vertText),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: context.watch<ThemeProvider>().vertText),
              ),
              style: TextStyle(color: context.watch<ThemeProvider>().vertText),
              onChanged: (String val) => name = val,
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Display name',
                labelStyle: TextStyle(color: context.watch<ThemeProvider>().vertText),
              ),
              style: TextStyle(color: context.watch<ThemeProvider>().vertText),
              onChanged: (String val) => displayName = val,
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: context.watch<ThemeProvider>().vertText),
              ),
              style: TextStyle(color: context.watch<ThemeProvider>().vertText),
              onChanged: (String val) => desc = val,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.watch<ThemeProvider>().vertText),
            ),
          ),
          TextButton(
            onPressed: () async {
              await provider.addWorkspace(name, displayName, desc);
              Navigator.pop(context);
            },
            child: Text(
              'Create',
              style: TextStyle(color: context.watch<ThemeProvider>().vertText),
            ),
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
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'Edit Workspace',
          style: TextStyle(color: context.watch<ThemeProvider>().vertText),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: TextEditingController(text: newDisplayName),
              decoration: InputDecoration(
                labelText: 'Display name',
                labelStyle: TextStyle(color: context.watch<ThemeProvider>().vertText),
              ),
              style: TextStyle(color: context.watch<ThemeProvider>().vertText),
              onChanged: (String val) => newDisplayName = val,
            ),
            TextField(
              controller: TextEditingController(text: newDesc),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: context.watch<ThemeProvider>().vertText),
              ),
              style: TextStyle(color: context.watch<ThemeProvider>().vertText),
              onChanged: (String val) => newDesc = val,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.watch<ThemeProvider>().vertText),
            ),
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
            child: Text(
              'Save',
              style: TextStyle(color: context.watch<ThemeProvider>().vertText),
            ),
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
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'Delete Workspace',
          style: TextStyle(color: context.watch<ThemeProvider>().vertText),
        ),
        content: Text(
          'Are you sure you want to delete the workspace "${workspace.displayName}"?',
          style: TextStyle(color: context.watch<ThemeProvider>().vertText),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.watch<ThemeProvider>().vertText),
            ),
          ),
          TextButton(
            onPressed: () async {
              await provider.removeWorkspace(workspace.id);
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: context.watch<ThemeProvider>().rouge),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.beige,
          body: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  AppBar(
                    backgroundColor: themeProvider.vertGris,
                    centerTitle: true,
                    elevation: 0,
                    toolbarHeight: 80,
                    automaticallyImplyLeading: false,
                    title: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '          Your WorkSpaces',
                            style: GoogleFonts.itim(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.vertText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (_isLoading)
                    Center(
                      child: CircularProgressIndicator(
                        color: themeProvider.vertText,
                      ),
                    )
                  else if (_errorMessage != null)
                    Center(
                      child: Text(
                        'Erreur: $_errorMessage',
                        style: TextStyle(color: themeProvider.rouge),
                      ),
                    )
                  else
                    Expanded(
                      child: Consumer<WorkspaceProvider>(
                        builder: (context, provider, child) {
                          final workspaces = provider.workspaces;
                          if (workspaces.isEmpty) {
                            return Center(
                              child: Text(
                                'No workspaces found.',
                                style: TextStyle(
                                  // ignore: deprecated_member_use
                                  color: themeProvider.vertText.withOpacity(0.5),
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: workspaces.length,
                            itemBuilder: (context, index) {
                              final workspace = workspaces[index];
                              final boards = _workspaceBoards[workspace.id]?.take(3).toList() ?? [];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                                margin: const EdgeInsets.only(bottom: 10),
                                color: themeProvider.bleuClair,
                                child: Column(
                                  children: [
                                    ListTile(
                                      contentPadding: const EdgeInsets.all(16),
                                      title: Text(
                                        workspace.displayName,
                                        style: TextStyle(
                                          color: themeProvider.rouge,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        workspace.desc ?? 'No description',
                                        style: TextStyle(color: themeProvider.vertText),
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
                                            PopupMenuItem<String>(
                                              value: 'edit',
                                              child: Text(
                                                'Edit',
                                                style: TextStyle(color: themeProvider.vertText),
                                              ),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'delete',
                                              child: Text(
                                                'Delete',
                                                style: TextStyle(color: themeProvider.rouge),
                                              ),
                                            ),
                                          ];
                                        },
                                      ),
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BoardsScreen(
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
                                          vertical: 10,
                                          horizontal: 16,
                                        ),
                                        child: Wrap(
                                          spacing: 5,
                                          runSpacing: 5,
                                          children: boards.map((board) {
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 8),
                                              child: Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: themeProvider.vertfavorite,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  board.name,
                                                  style: TextStyle(
                                                    color: themeProvider.blanc,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
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
              Positioned(
                left: -30,
                top: 1,
                child: SafeArea(
                  child: Image.asset(
                    'documentation/pic.png',
                    height: 125,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 20,
                left: 30,
              ),
              child: FloatingActionButton(
                onPressed: () async {
                  await _addWorkspaceDialog(
                    context,
                    Provider.of<WorkspaceProvider>(context, listen: false),
                  );
                  _initializeWorkspaces();
                },
                backgroundColor: themeProvider.vertGris,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.add, color: themeProvider.rouge),
              ),
            ),
          ),
          bottomNavigationBar: const BottomNavBar(),
        );
      },
    );
  }
}
