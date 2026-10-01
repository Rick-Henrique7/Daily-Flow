import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_pessoal/core/utils/json_coders.dart';

void main() {
  int parse(Map<String, dynamic> m) => m['v'] as int;

  test('registro corrompido é ignorado sem derrubar a lista', () {
    final result = JsonCoders.decodeList('[{"v":1},{"v":"x"},{"v":3}]', parse);
    expect(result, [1, 3]);
  });

  test('JSON inválido devolve lista vazia', () {
    expect(JsonCoders.decodeList('{nope', parse), isEmpty);
  });

  test('null ou vazio devolve lista vazia', () {
    expect(JsonCoders.decodeList(null, parse), isEmpty);
    expect(JsonCoders.decodeList('', parse), isEmpty);
  });
}
