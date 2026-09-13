import 'dart:convert';

/// Wrapper seguro sobre `jsonEncode`/`jsonDecode` para listas de modelos.
class JsonCoders {
  JsonCoders._();

  static String encodeList<T>(List<T> items, Map<String, dynamic> Function(T) to) {
    return jsonEncode(items.map(to).toList());
  }

  static List<T> decodeList<T>(
    String? source,
    T Function(Map<String, dynamic>) from,
  ) {
    if (source == null || source.isEmpty) return <T>[];
    final raw = jsonDecode(source);
    if (raw is! List) return <T>[];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(from)
        .toList();
  }
}
