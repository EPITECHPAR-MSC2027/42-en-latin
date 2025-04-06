import 'package:fluter/models/list.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ListModel', () {
    test('fromJson doit parser correctement une liste', () {
      final Map<String, dynamic> json = {
        'id': 'list123',
        'name': 'Ma Liste',
      };

      final list = ListModel.fromJson(json);

      expect(list.id, 'list123');
      expect(list.name, 'Ma Liste');
      // ignore: avoid_print
      print('Test fromJson passé : id et name bien parsés.');
    });
  });
}
