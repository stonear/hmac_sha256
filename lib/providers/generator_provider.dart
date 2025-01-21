import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

part 'generator_provider.g.dart';

@riverpod
class Generator extends _$Generator {
  @override
  String build() => '';

  void generate(String message, String key) {
    if (message.isEmpty || key.isEmpty) {
      state = '';
      return;
    }
    final hmacSha256 = Hmac(sha256, utf8.encode(key));
    final digest = hmacSha256.convert(utf8.encode(message));
    state = digest.toString();
  }
}
