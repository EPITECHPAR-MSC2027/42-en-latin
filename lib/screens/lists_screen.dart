// ignore_for_file: use_build_context_synchronously

import 'dart:developer' as developer;
import 'package:fluter/models/card.dart';
import 'package:fluter/models/list.dart';
import 'package:fluter/providers/board_provider.dart';
import 'package:fluter/providers/card_provider.dart';
import 'package:fluter/providers/list_provider.dart';
import 'package:fluter/providers/theme_provider.dart';
import 'package:fluter/services/trello_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// ============================================================
///                        LISTS SCREEN
/// ============================================================
class ListsScreen extends StatefulWidget {
  const ListsScreen({
    required this.boardId,
    required this.boardName,
    super.key,
  });

  final String boardId;
  final String boardName;

  @override
  ListsScreenState createState() => ListsScreenState();
}

/// ============================================================
///                     LISTS SCREEN STATE
/// ============================================================
class ListsScreenState extends State<ListsScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    developer.log('ListsScreen: initState for board ${widget.boardId} (${widget.boardName})');
    Future<void>.microtask(() async {
      // Update last opened date
      developer.log('ListsScreen: Updating last opened date');
      await Provider.of<BoardsProvider>(context, listen: false).markBoardAsOpened(widget.boardId);
      await _loadLists();
    });
  }

  Future<void> _loadLists() async {
    try {
      final listProvider = Provider.of<ListProvider>(context, listen: false);
      final cardProvider = Provider.of<CardProvider>(context, listen: false);
      await listProvider.fetchListsByBoard(widget.boardId);
      await cardProvider.fetchCardsByBoard(widget.boardId);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double listWidthPercentage = 0.48;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.beige,
          appBar: _buildAppBar(themeProvider),
          body: _isLoading
              ? Center(child: CircularProgressIndicator(color: themeProvider.vertText))
              : _errorMessage != null
                  ? Center(child: Text('Error: $_errorMessage', style: TextStyle(color: themeProvider.rouge)))
                  : _buildBody(screenWidth, listWidthPercentage, themeProvider),
          floatingActionButton: _buildFloatingActionButton(themeProvider),
        );
      },
    );
  }

  // ============================================================
  //                         APP BAR
  // ============================================================
  AppBar _buildAppBar(ThemeProvider themeProvider) {
    return AppBar(
      backgroundColor: themeProvider.vertGris,
      title: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text(
          widget.boardName,
          style: GoogleFonts.itim(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: themeProvider.vertText,
          ),
        ),
      ),
    );
  }

  // ============================================================
  //                          BODY
  // ============================================================
  Widget _buildBody(double screenWidth, double listWidthPercentage, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildColumn(true, screenWidth, listWidthPercentage, themeProvider),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildColumn(false, screenWidth, listWidthPercentage, themeProvider),
                ),
              ],
            ),
            const SizedBox(height: 24), // Espacement avant le footer

            Column(
              children: [
                Image.asset(
                  'documentation/pic1.png',
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                ),
                const SizedBox(
                  height: 8,
                ), // Espacement entre l'image et le texte
                Text(
                  'End of the lists',
                  style: GoogleFonts.itim(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.vertText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  //                FLOATING ACTION BUTTON
  // ============================================================
  FloatingActionButton _buildFloatingActionButton(ThemeProvider themeProvider) {
    return FloatingActionButton.extended(
      backgroundColor: themeProvider.vertGris,
      onPressed: () async {
        await _addListDialog(
          context,
          Provider.of<ListProvider>(context, listen: false),
        );
      },
      label: Row(
        children: [
          Text(
            'Add',
            style: GoogleFonts.itim(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.rouge,
            ),
          ),
          const SizedBox(width: 8), // Espacement entre le texte et l'icône
          Icon(Icons.add, color: themeProvider.rouge),
        ],
      ),
    );
  }

  // ============================================================
  //                         LISTS
  // ============================================================
  Widget _buildColumn(
    bool isLeftColumn,
    double screenWidth,
    double widthPercentage,
    ThemeProvider themeProvider,
  ) {
    final provider = Provider.of<ListProvider>(context, listen: false);
    final List<ListModel> filteredLists = [];
    for (int i = isLeftColumn ? 0 : 1; i < provider.lists.length; i += 2) {
      filteredLists.add(provider.lists[i]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          filteredLists.map((list) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildListContainer(
                list,
                width: screenWidth * widthPercentage,
                themeProvider: themeProvider,
              ),
            );
          }).toList(),
    );
  }

  Widget _buildListContainer(ListModel list, {required double width, required ThemeProvider themeProvider}) {
    final cardProvider = Provider.of<CardProvider>(context);
    final List<CardModel> cards = cardProvider.fetchCardsByList(list.id);

    return DragTarget<CardModel>(
      onAcceptWithDetails: (details) async {
        final card = details.data;
        await cardProvider.moveCardToList(card.id, list.id);
        await cardProvider.fetchCardsByBoard(widget.boardId);
        setState(() {}); // Pour forcer la reconstruction
      },

      builder: (context, candidateData, rejectedData) {
        return SizedBox(
          width: width,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: themeProvider.bleuClair,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER (nom de la liste + boutons d'action)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        list.name,
                        style: GoogleFonts.itim(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.vertText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.add, color: themeProvider.vertText),
                          onPressed: () async {
                            await _addCardDialog(
                              context,
                              list.id,
                              cardProvider,
                            );
                          },
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: themeProvider.vertText,
                          ),
                          onSelected: (String value) async {
                            if (value == 'Modifier') {
                              await _editListDialog(context, list);
                            } else if (value == 'Supprimer') {
                              await _deleteList(context, list);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem(
                              value: 'Modifier',
                              child: Text('Edit', style: TextStyle(color: themeProvider.vertText)),
                            ),
                            PopupMenuItem(
                              value: 'Supprimer',
                              child: Text('Delete', style: TextStyle(color: themeProvider.rouge)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                // Liste des cartes
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      cards.isEmpty
                          ? [
                            Text(
                              'No cards',
                              // ignore: deprecated_member_use
                              style: TextStyle(color: themeProvider.vertText.withOpacity(0.5)),
                            ),
                          ]
                          : cards.map((card) => _buildCard(card, themeProvider)).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  //                        CARDS
  // ============================================================
  Widget _buildCard(CardModel card, ThemeProvider themeProvider) {
    return LongPressDraggable<CardModel>(
      data: card,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 200, // largeur fixe pour le feedback
          height:
              60, // hauteur fixe pour le feedback (ajustez selon vos besoins)
          child: _cardContent(card, themeProvider),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _cardContent(card, themeProvider)),
      child: _cardContent(card, themeProvider),
    );
  }

  Widget _cardContent(CardModel card, ThemeProvider themeProvider) {
    return GestureDetector(
      onTap: () async {
        await _editCardDialog(
          context,
          card,
          Provider.of<CardProvider>(context, listen: false),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: themeProvider.blanc,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 3,
                offset: const Offset(1, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.name,
                      style: GoogleFonts.itim(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.vertText,
                      ),
                    ),
                    if (card.desc.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        card.desc,
                        style: GoogleFonts.itim(
                          fontSize: 12,
                          // ignore: deprecated_member_use
                          color: themeProvider.vertText.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Ajouter un collaborateur depuis ce bouton
              IconButton(
                icon: Icon(
                  Icons.person_add,
                  color: themeProvider.vert,
                  size: 16,
                ),
                onPressed: () async {
                  await _updateCollaboratorsDialog(context, card.id, widget.boardId);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: themeProvider.rouge, size: 16),
                onPressed: () async {
                  final cardProvider = Provider.of<CardProvider>(
                    context,
                    listen: false,
                  );
                  await cardProvider.removeCard(card.id);
                  await cardProvider.fetchCardsByBoard(card.listId);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  //                    DIALOGS (CARD EDITION)
  // ============================================================

  Future<void> _addCardDialog(
    BuildContext context,
    String listId,
    CardProvider provider,
  ) async {
    String name = '';
    String desc = '';

    await showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Create a Card'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  onChanged: (String val) => name = val,
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
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await provider.addCard(listId, name, desc);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  await provider.fetchCardsByBoard(listId);
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  Future<void> _editCardDialog(
    BuildContext context,
    CardModel card,
    CardProvider provider,
  ) async {
    String newName = card.name;
    String newDesc = card.desc;

    await showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Edit Card'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: TextEditingController(text: newName),
                  decoration: const InputDecoration(labelText: 'Name'),
                  onChanged: (String val) => newName = val,
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
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await provider.editCard(card.id, newName, newDesc);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  await provider.fetchCardsByBoard(card.listId);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  Future<void> _updateCollaboratorsDialog(
    BuildContext context,
    String cardId,
    String boardId,
  ) async {
    final trelloService = Provider.of<TrelloService>(context, listen: false);
    List<Map<String, dynamic>> boardMembers = [];
    List<Map<String, dynamic>> cardMembers = [];

    try {
      boardMembers = await trelloService.getBoardMembers(boardId);
      cardMembers = await trelloService.getCardMembers(cardId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading collaborators')),
      );
      return;
    }

    // Crée un ensemble des IDs actuellement assignés à la carte.
    final Set<String> currentMemberIds =
        cardMembers.map((m) => m['id'] as String).toSet();
    // Cet ensemble sera modifié dans le dialog.
    final Set<String> selectedMemberIds = Set<String>.from(currentMemberIds);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Collaborators'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      boardMembers.map((member) {
                        final String memberId = member['id'] as String;
                        final String memberName =
                            member['fullName'] ??
                            member['username'] ??
                            'Unknown';
                        final bool isSelected = selectedMemberIds.contains(
                          memberId,
                        );
                        return CheckboxListTile(
                          value: isSelected,
                          title: Text(memberName),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedMemberIds.add(memberId);
                              } else {
                                selectedMemberIds.remove(memberId);
                              }
                            });
                          },
                        );
                      }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    bool allSuccess = true;
                    for (final member in boardMembers) {
                      final String memberId = member['id'] as String;
                      if (selectedMemberIds.contains(memberId) &&
                          !currentMemberIds.contains(memberId)) {
                        final bool success = await trelloService.addMemberToCard(
                          cardId,
                          memberId,
                        );
                        if (!success) allSuccess = false;
                      } else if (!selectedMemberIds.contains(memberId) &&
                          currentMemberIds.contains(memberId)) {
                        final bool success = await trelloService.removeMemberFromCard(
                          cardId,
                          memberId,
                        );
                        if (!success) allSuccess = false;
                      }
                    }
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          allSuccess
                              ? 'Collaborators updated'
                              : 'Error updating some collaborators',
                        ),
                      ),
                    );
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// ============================================================
  ///                    DIALOGS (LIST EDITION)
  /// ============================================================
  Future<void> _addListDialog(
    BuildContext context,
    ListProvider provider,
  ) async {
    String name = '';

    await showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Create a List'),
            content: TextField(
              decoration: const InputDecoration(labelText: 'List name'),
              onChanged: (String val) => name = val,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (name.isNotEmpty) {
                    await provider.addList(widget.boardId, name);
                    await provider.fetchListsByBoard(widget.boardId);

                    setState(() {});
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  Future<void> _editListDialog(BuildContext context, ListModel list) async {
    String newName = list.name;

    await showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Edit List'),
            content: TextField(
              controller: TextEditingController(text: newName),
              decoration: const InputDecoration(labelText: 'List name'),
              onChanged: (String val) => newName = val,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
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
                child: const Text('Save'),
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
