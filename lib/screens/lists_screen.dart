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
      body: _isLoading
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
          '[${widget.boardName}]',
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
          ],
        ),
      ),
    );
  }

  // ============================================================
  //                FLOATING ACTION BUTTON
  // ============================================================
  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: const Color(0xFFC0CDA9),
      onPressed: () async {
        await _addListDialog(context, Provider.of<ListProvider>(context, listen: false));
      },
      child: const Icon(Icons.add, color: Colors.black),
    );
  }

  // ============================================================
  //                         LISTS
  // ============================================================
  Widget _buildColumn(bool isLeftColumn, double screenWidth, double widthPercentage) {
    final provider = Provider.of<ListProvider>(context, listen: false);
    final List<ListModel> filteredLists = [];
    for (int i = isLeftColumn ? 0 : 1; i < provider.lists.length; i += 2) {
      filteredLists.add(provider.lists[i]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filteredLists.map((list) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildListContainer(list, width: screenWidth * widthPercentage),
        );
      }).toList(),
    );
  }

  Widget _buildListContainer(ListModel list, {required double width}) {
    final cardProvider = Provider.of<CardProvider>(context);
    final List<CardModel> cards = cardProvider.fetchCardsByList(list.id);

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
            // ------------------------------
            // HEADER (LIST NAME + Add Card)
            // ------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  list.name,
                  style: GoogleFonts.itim(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.black),
                  onPressed: () async {
                    await _addCardDialog(context, list.id, cardProvider);
                  },
                ),
              ],
            ),
            const SizedBox(height: 3),
            // ------------------------------
            //             CARDS
            // ------------------------------
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: cards.isEmpty
                  ? [const Text('Aucune carte', style: TextStyle(color: Colors.black54))]
                  : cards.map(_buildCard).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  //                        CARDS
  // ============================================================
  Widget _buildCard(CardModel card) {
    return GestureDetector(
      onTap: () async {
        await _editCardDialog(context, card, Provider.of<CardProvider>(context, listen: false));
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
                      style: GoogleFonts.itim(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    if (card.desc.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        card.desc,
                        style: GoogleFonts.itim(fontSize: 12, color: Colors.black87),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final cardProvider = Provider.of<CardProvider>(context, listen: false);
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
  //                    DIALOGS (ADD / EDIT)
  // ============================================================
  Future<void> _addListDialog(BuildContext context, ListProvider provider) async {
    String name = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Créer une Liste'),
        content: TextField(
          decoration: const InputDecoration(labelText: 'Nom de la liste'),
          onChanged: (String val) => name = val,
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              if (name.isNotEmpty) {
                await provider.addList(widget.boardId, name);
                if (!context.mounted) return;
                Navigator.pop(context);
                await provider.fetchListsByBoard(widget.boardId);
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  Future<void> _addCardDialog(BuildContext context, String listId, CardProvider provider) async {
    String name = '';
    String desc = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
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

  Future<void> _editCardDialog(BuildContext context, CardModel card, CardProvider provider) async {
    String newName = card.name;
    String newDesc = card.desc;

    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
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
}
