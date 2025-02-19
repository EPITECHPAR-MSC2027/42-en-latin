import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/card_provider.dart';
import '../models/card.dart';

class CardsScreen extends StatelessWidget {
  final String listId;
  final String listName;

  const CardsScreen({super.key, required this.listId, required this.listName});

  @override
  Widget build(BuildContext context) {
    final cardProvider = Provider.of<CardProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('Cartes de $listName')),
      body: FutureBuilder(
        future: cardProvider.fetchCardsByList(listId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          return Consumer<CardProvider>(
            builder: (context, provider, child) {
              return ListView.builder(
                itemCount: provider.cards.length,
                itemBuilder: (context, index) {
                  final CardModel card = provider.cards[index];

                  return ListTile(
                    title: Text(card.name),
                    subtitle: Text(card.desc),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => provider.removeCard(card.id),
                    ),
                    onTap: () => _editCardDialog(context, card, provider),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _addCardDialog(context, cardProvider),
      ),
    );
  }

  void _addCardDialog(BuildContext context, CardProvider provider) {
    String name = '', desc = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer une Carte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Nom'), onChanged: (val) => name = val),
            TextField(decoration: const InputDecoration(labelText: 'Description'), onChanged: (val) => desc = val),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              provider.addCard(listId, name, desc);
              Navigator.pop(context);
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _editCardDialog(BuildContext context, CardModel card, CardProvider provider) {
    String newName = card.name;
    String newDesc = card.desc;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier la Carte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: TextEditingController(text: newName), onChanged: (val) => newName = val),
            TextField(controller: TextEditingController(text: newDesc), onChanged: (val) => newDesc = val),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(onPressed: () {
            provider.editCard(card.id, newName, newDesc);
            Navigator.pop(context);
          }, child: const Text('Enregistrer')),
        ],
      ),
    );
  }
}
