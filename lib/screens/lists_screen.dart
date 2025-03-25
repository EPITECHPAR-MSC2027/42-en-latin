import 'package:fluter/models/card.dart';
import 'package:fluter/models/list.dart';
import 'package:fluter/providers/card_provider.dart';
import 'package:fluter/providers/list_provider.dart';
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
    Future<void>.microtask(() async => _loadLists());
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
    const double listWidthPercentage = 0.48; // 48% de la largeur de l'écran

    return Scaffold(
      backgroundColor: const Color(0xFFFFEDE3),
      appBar: _buildAppBar(),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text('Erreur: $_errorMessage'))
              : _buildBody(screenWidth, listWidthPercentage),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // ============================================================
  //                         APP BAR
  // ============================================================
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF889596),
      title: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text(
          widget.boardName,
          style: GoogleFonts.itim(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFC0CDA9),
          ),
        ),
      ),
    );
  }

  // ============================================================
  //                          BODY
  // ============================================================
  Widget _buildBody(double screenWidth, double listWidthPercentage) {
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
                  child: _buildColumn(true, screenWidth, listWidthPercentage),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildColumn(false, screenWidth, listWidthPercentage),
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
                    color: Colors.black,
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
  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      backgroundColor: const Color(0xFFC0CDA9),
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
              color: const Color(0xFFD97E8D),
            ),
          ),
          const SizedBox(width: 8), // Espacement entre le texte et l'icône
          const Icon(Icons.add, color: Color(0xFFD97E8D)),
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
              ),
            );
          }).toList(),
    );
  }

  Widget _buildListContainer(ListModel list, {required double width}) {
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
              color: const Color(0xFFD2E3F7),
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
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.black),
                          onPressed: () async {
                            await _addCardDialog(
                              context,
                              list.id,
                              cardProvider,
                            );
                          },
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.black,
                          ),
                          onSelected: (String value) async {
                            if (value == 'Modifier') {
                              await _editListDialog(context, list);
                            } else if (value == 'Supprimer') {
                              await _deleteList(context, list);
                            }
                          },
                          itemBuilder:
                              (BuildContext context) => [
                                const PopupMenuItem(
                                  value: 'Modifier',
                                  child: Text('Modifier'),
                                ),
                                const PopupMenuItem(
                                  value: 'Supprimer',
                                  child: Text('Supprimer'),
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
                            const Text(
                              'Aucune carte',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ]
                          : cards.map(_buildCard).toList(),
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
  Widget _buildCard(CardModel card) {
    return LongPressDraggable<CardModel>(
      data: card,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 200, // largeur fixe pour le feedback
          height:
              60, // hauteur fixe pour le feedback (ajustez selon vos besoins)
          child: _cardContent(card),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _cardContent(card)),
      child: _cardContent(card),
    );
  }

  Widget _cardContent(CardModel card) {
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
            color: Colors.white,
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
                        color: Colors.black,
                      ),
                    ),
                    if (card.desc.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        card.desc,
                        style: GoogleFonts.itim(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
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
            title: const Text('Créer une Carte'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  decoration: const InputDecoration(labelText: 'Nom'),
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
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () async {
                  await provider.addCard(listId, name, desc);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  await provider.fetchCardsByBoard(listId);
                },
                child: const Text('Créer'),
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
            title: const Text('Modifier la Carte'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: TextEditingController(text: newName),
                  decoration: const InputDecoration(labelText: 'Nom'),
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
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () async {
                  await provider.editCard(card.id, newName, newDesc);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  await provider.fetchCardsByBoard(card.listId);
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
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
            title: const Text('Créer une Liste'),
            content: TextField(
              decoration: const InputDecoration(labelText: 'Nom de la liste'),
              onChanged: (String val) => name = val,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () async {
                  if (name.isNotEmpty) {
                    await provider.addList(widget.boardId, name);
                    await provider.fetchListsByBoard(widget.boardId);

                    setState(() {}); // ✅ Rafraîchir immédiatement l'UI
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  }
                },
                child: const Text('Créer'),
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
            title: const Text('Modifier la Liste'),
            content: TextField(
              controller: TextEditingController(text: newName),
              decoration: const InputDecoration(labelText: 'Nom de la liste'),
              onChanged: (String val) => newName = val,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () async {
                  final listProvider = Provider.of<ListProvider>(
                    context,
                    listen: false,
                  );
                  await listProvider.editList(list.id, newName);
                  await listProvider.fetchListsByBoard(widget.boardId);

                  setState(() {}); // ✅ Rafraîchir l'UI immédiatement
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                child: const Text('Enregistrer'),
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
