// ignore_for_file: avoid_print

import 'package:fluter/models/list.dart';
import 'package:fluter/providers/list_provider.dart';
import 'package:fluter/services/trello_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Faux TrelloService implémentant uniquement ce qu'on teste
class FakeTrelloService implements TrelloService {
  final Map<String, List<ListModel>> _fakeBoardLists = {};

  @override
  final String apiKey = 'fake';
  @override
  final String token = 'fake';

  @override
  Future<List<Map<String, dynamic>>> getListsByBoard(String boardId) async {
    return _fakeBoardLists[boardId]
            ?.map((list) => {'id': list.id, 'name': list.name})
            .toList() ??
        [];
  }

  @override
  Future<ListModel?> createList(String boardId, String name) async {
    final newList = ListModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );
    _fakeBoardLists.putIfAbsent(boardId, () => []).add(newList);
    return newList;
  }

  @override
  Future<bool> updateList(String listId, String newName) async {
    for (final boardLists in _fakeBoardLists.values) {
      for (int i = 0; i < boardLists.length; i++) {
        if (boardLists[i].id == listId) {
          boardLists[i] = ListModel(id: listId, name: newName);
          return true;
        }
      }
    }
    return false;
  }

  @override
  Future<bool> deleteList(String listId) async {
    for (final boardLists in _fakeBoardLists.values) {
      boardLists.removeWhere((list) => list.id == listId);
    }
    return true;
  }

  // Tous les autres membres obligatoires → on les ignore (non utilisés ici)
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('Séquence complète : création -> modification -> suppression de liste', () async {
    final fakeService = FakeTrelloService();
    final listProvider = ListProvider(trelloService: fakeService);

    // Création
    await listProvider.addList('board1', 'Ma Liste');
    expect(listProvider.lists.length, 1);
    print('Liste créée');

    final String listId = listProvider.lists.first.id;

    // Modification
    await listProvider.editList(listId, 'Liste Modifiée');
    expect(listProvider.lists.first.name, 'Liste Modifiée');
    print('Liste modifiée');

    // Suppression
    await listProvider.removeList(listId);
    expect(listProvider.lists.isEmpty, true);
    print('Liste supprimée');
  });
}
