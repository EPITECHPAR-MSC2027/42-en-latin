// test/card_model_test.dart

// ignore_for_file: avoid_print

import 'package:fluter/models/card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CardModel', () {
    test('fromJson doit parser correctement les données JSON', () {
      final json = {
        'id': 'abc123',
        'name': 'Test Card',
        'desc': 'Une carte de test',
        'idList': 'list42',
      };

      final card = CardModel.fromJson(json);

      expect(card.id, 'abc123');
      expect(card.name, 'Test Card');
      expect(card.desc, 'Une carte de test');
      expect(card.listId, 'list42');
      print('Test fromJson passé : id, name, desc et listId bien parsés.');
    });

    test('copyWith doit créer une copie avec modifications', () {
      final card = CardModel(
        id: 'abc123',
        name: 'Original Name',
        desc: 'Desc',
        listId: 'list42',
      );

      final updated = card.copyWith(name: 'Updated Name');

      expect(updated.name, 'Updated Name');
      expect(updated.id, card.id); 
      expect(updated.desc, card.desc);
      expect(updated.listId, card.listId);
      print('Test copyWith passé : name mis à jour, id, desc et listId inchangés.');
    });
  });
}
