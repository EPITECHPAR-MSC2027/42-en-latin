// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:fluter/models/board.dart';
import 'package:fluter/providers/board_provider.dart'; // BoardProvider for add, edit, remove
import 'package:fluter/providers/workspace_provider.dart'; // WorkspaceProvider for fetchBoardsByWorkspace
import 'package:fluter/screens/lists_screen.dart';
import 'package:fluter/utils/templates.dart';
import 'package:fluter/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Screen displaying boards of a specific workspace.
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
  final bool _isTableView = true; // Manages display between Table and Board

  @override
  void initState() {
    super.initState();
    _initializeBoards();
  }

  void _initializeBoards() {
    _fetchBoardsFuture = Future.microtask(_fetchBoards);
  }

  /// **Fetches workspace boards via WorkspaceProvider.**
  Future<List<Board>> _fetchBoards() async {
    try {
      final WorkspaceProvider workspaceProvider =
          Provider.of<WorkspaceProvider>(context, listen: false); // Using WorkspaceProvider
      return await workspaceProvider.fetchBoardsByWorkspace(widget.workspaceId);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
      return [];
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// **Method to add a board via BoardProvider**
  Future<void> _addBoardDialog(BuildContext context, BoardsProvider provider) async {
    String name = '';
    String desc = '';
    String? selectedTemplateId;

    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Create Board'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(labelText: 'Board name'),
              onChanged: (val) => name = val,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Description'),
              onChanged: (val) => desc = val,
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedTemplateId,
              hint: const Text('Select a template'),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              // Creating a board using BoardProvider
              await provider.addBoard(widget.workspaceId, name, desc, selectedTemplateId);
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
              setState(_initializeBoards); // Reload boards after adding
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _editBoardDialog(BuildContext context, Board board, BoardsProvider provider) async {
    final TextEditingController nameController = TextEditingController(text: board.name);
    final TextEditingController descController = TextEditingController(text: board.desc);

    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Edit Board'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await provider.editBoard(board.id, nameController.text, descController.text);
              if (mounted) {
                Navigator.pop(context);
                setState(() {
                  _initializeBoards(); // Force refresh
                });
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// **Method to delete a board via BoardProvider**
  Future<void> _deleteBoardDialog(BuildContext context, Board board, BoardsProvider provider) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Board'),
        content: Text('Do you want to delete "${board.name}"?'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await provider.removeBoard(board.id); // Using BoardProvider
              Navigator.pop(context);
              setState(_initializeBoards); // Reload boards after deletion
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEDE3), // Beige pink background
      appBar: AppBar(
        backgroundColor: const Color(0xFF889596), // AppBar background
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
      body: SingleChildScrollView(  // Wrap body with SingleChildScrollView
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
            /// **Display content based on selected mode**
            if (_isLoading) const Center(child: CircularProgressIndicator()) else _errorMessage != null
                    ? Center(child: Text('Error: $_errorMessage'))
                    : FutureBuilder<List<Board>>(
                        future: _fetchBoardsFuture,
                        builder: (BuildContext context, AsyncSnapshot<List<Board>> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text('No boards found for this workspace.'));
                          }

                          return _isTableView
                              ? _buildTableView(snapshot.data!) // Table display
                              : const Center(
                                  child: Text('Board mode not implemented.'),
                                );
                        },
                      ),
          ],
        ),
      ),
      /// **Floating button to create a board**
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 20),
        child: FloatingActionButton(
          onPressed: () async {
            // Show board creation window
            await _addBoardDialog(context, context.read<BoardsProvider>());
            setState(_initializeBoards); // Reload boards after creation
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
        alignment: Alignment.topCenter, // Prevents container from stretching full height
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9, // Limit width if needed
          ),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Adjust height based on content
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
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ];
                        },
                      ),
                      onTap: () async {
                        await Provider.of<BoardsProvider>(context, listen: false).markBoardAsOpened(board.id);
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
                    if (index < boards.length - 1) // Prevents divider after last element
                      const Divider(
                        color: Color(0xFFD97C83),
                        thickness: 1,
                        height: 10, // Vertical spacing
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
