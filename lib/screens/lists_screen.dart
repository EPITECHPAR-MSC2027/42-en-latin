import 'dart:math';
import 'package:fluter/models/list.dart';
import 'package:fluter/providers/list_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// **Écran affichant les listes d'un board**
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

/// **État de ListsScreen**
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
    final double screenWidth = MediaQuery.of(context).size.width;
    const double listWidthPercentage = 0.48;

    return Scaffold(
      backgroundColor: const Color(0xFFFFEDE3),
      appBar: AppBar(
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Erreur: $_errorMessage'))
              : Consumer<ListProvider>(
                  builder: (BuildContext context, ListProvider provider, Widget? child) {
                    if (provider.lists.isEmpty) {
                      return const Center(child: Text('Aucune liste trouvée.'));
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16), // ✅ Marge sous la navbar
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildColumn(provider.lists, screenWidth, listWidthPercentage, true)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildColumn(provider.lists, screenWidth, listWidthPercentage, false)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  /// **Crée une colonne pour répartir les listes**
  Widget _buildColumn(List<ListModel> lists, double screenWidth, double widthPercentage, bool isLeftColumn) {
    final List<ListModel> filteredLists = [];
    for (int i = isLeftColumn ? 0 : 1; i < lists.length; i += 2) {
      filteredLists.add(lists[i]);
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

  /// **Construit un container dynamique pour chaque liste**
  Widget _buildListContainer(ListModel list, {required double width}) {
    final int numberOfCards = Random().nextInt(4) + 1;

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
            Text(
              list.name,
              style: GoogleFonts.itim(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 3),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                numberOfCards,
                (index) => Padding(
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
                    child: Text(
                      'Placeholder',
                      style: GoogleFonts.itim(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
