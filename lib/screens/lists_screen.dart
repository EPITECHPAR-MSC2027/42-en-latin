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
                      padding: const EdgeInsets.all(16),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 2 colonnes
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2, // Ajuste la hauteur des rectangles
                        ),
                        itemCount: provider.lists.length,
                        itemBuilder: (BuildContext context, int index) {
                          final ListModel list = provider.lists[index];

                          return GestureDetector(
                            onTap: () {
                              // Ouvre l'écran des cartes
                            },
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
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Card',
                                          style: GoogleFonts.itim(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          'Card',
                                          style: GoogleFonts.itim(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          'Card',
                                          style: GoogleFonts.itim(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
