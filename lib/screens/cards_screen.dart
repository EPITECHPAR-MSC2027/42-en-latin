import 'package:fluter/models/card.dart';
import 'package:fluter/providers/card_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CardsScreen extends StatelessWidget {

  const CardsScreen({super.key, required this.listId, required this.listName});
  final String listId;
  final String listName;

  @override
  Widget build(BuildContext context) {
    final CardProvider cardProvider = Provider.of<CardProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('Cartes de $listName')),
      body: FutureBuilder(
        future: cardProvider.fetchCardsByList(listId),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          return Consumer<CardProvider>(
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
    String name = '';
    String desc = '';

    showDialog(
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
          TextButton(onPressed: () {
            provider.editCard(card.id, newName, newDesc);
            Navigator.pop(context);
          }, child: const Text('Enregistrer'),),
        ],
      ),
    );
  }
}
