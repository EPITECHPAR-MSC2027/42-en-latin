import 'package:fluter/models/card.dart';
import 'package:fluter/providers/card_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// **Classe permettant de gérer les cartes**
class CardsScreen extends StatefulWidget {
  /// **Constructeur de Card**
  const CardsScreen({required this.listId, required this.listName, super.key});

  /// **ID de la liste**
  final String listId;
  /// **Nom de la liste**
  final String listName;

  @override
  CardsScreenState createState() => CardsScreenState();
}

/// **État de la classe CardsScreen**
class CardsScreenState extends State<CardsScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async => _loadCards());
  }

  Future<void> _loadCards() async {
    try {
      await Provider.of<CardProvider>(context, listen: false).fetchCardsByList(widget.listId);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cartes de ${widget.listName}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Erreur: $_errorMessage'))
              : Consumer<CardProvider>(
                  builder: (BuildContext context, CardProvider provider, Widget? child) {
                    return ListView.builder(
                      itemCount: provider.cards.length,
                      itemBuilder: (BuildContext context, int index) {
                        final CardModel card = provider.cards[index];

                        return ListTile(
                          title: Text(card.name),
                          subtitle: Text(card.desc),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async => provider.removeCard(card.id),
                          ),
                          onTap: () async => _editCardDialog(context, card, provider),
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async => _addCardDialog(context, Provider.of<CardProvider>(context, listen: false)),
      ),
    );
  }

  Future<void> _addCardDialog(BuildContext context, CardProvider provider) async{
    String name = '';
    String desc = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Créer une Carte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(decoration: const InputDecoration(labelText: 'Nom'), onChanged: (String val) => name = val),
            TextField(decoration: const InputDecoration(labelText: 'Description'), onChanged: (String val) => desc = val),
          ],
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              await provider.addCard(widget.listId, name, desc);
              if (!context.mounted) return;
              Navigator.pop(context);
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
            TextField(controller: TextEditingController(text: newName), onChanged: (String val) => newName = val),
            TextField(controller: TextEditingController(text: newDesc), onChanged: (String val) => newDesc = val),
          ],
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              await provider.editCard(card.id, newName, newDesc);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
