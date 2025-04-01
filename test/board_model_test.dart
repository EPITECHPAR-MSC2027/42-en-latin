// ignore_for_file: avoid_print

import 'package:fluter/models/board.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Board', () {
    test('fromJson avec date', () {
      final json = {
        'id': 'board1',
        'name': 'Projet Flutter',
        'desc': 'Un super board',
        'lastOpened': '2024-03-25T12:00:00.000Z',
      };

      final board = Board.fromJson(json);
      expect(board.id, 'board1');
      expect(board.name, 'Projet Flutter');
      expect(board.desc, 'Un super board');
      expect(board.lastOpened, DateTime.parse('2024-03-25T12:00:00.000Z'));
      print('Board.fromJson avec date : succès');
    });

    test('fromJson sans date', () {
      final json = {
        'id': 'board2',
        'name': 'Sans Date',
        'desc': null,
      };

      final board = Board.fromJson(json);
      expect(board.desc, 'Pas de description');
      print('Board.fromJson sans date : desc par défaut OK');
    });
  });
}
