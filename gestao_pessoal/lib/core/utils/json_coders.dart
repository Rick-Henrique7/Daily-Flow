import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Wrapper seguro sobre `jsonEncode`/`jsonDecode` para listas de modelos.
class JsonCoders {
  JsonCoders._();

  static String encodeList<T>(
    List<T> items,
    Map<String, dynamic> Function(T) to,
  ) {
    return jsonEncode(items.map(to).toList());
  }

  /// Decodifica uma lista tolerando registros corrompidos: um item que
  /// falha no `fromJson` é descartado (e logado em debug) em vez de
  /// derrubar o app inteiro na abertura.
  static List<T> decodeList<T>(
    String? source,
    T Function(Map<String, dynamic>) from,
  ) {
    if (source == null || source.isEmpty) return <T>[];
    final Object? raw;
    try {
      raw = jsonDecode(source);
    } on FormatException catch (e) {
      debugPrint('JsonCoders: JSON inválido descartado ($e)');
      return <T>[];
    }
    if (raw is! List) return <T>[];
    final result = <T>[];
    for (final item in raw.whereType<Map<String, dynamic>>()) {
      try {
        result.add(from(item));
      } catch (e) {
        debugPrint('JsonCoders: registro inválido ignorado ($e)');
      }
    }
    return result;
  }
}
