import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

part 'validator_provider.g.dart';

@riverpod
class Validator extends _$Validator {
  @override
  bool build() => false;

  void validate(String message, String key, String hash) {
    if (message.isEmpty || key.isEmpty || hash.isEmpty) {
      state = false;
      return;
    }
    final hmacSha256 = Hmac(sha256, utf8.encode(key));
    final calculatedHash = hmacSha256.convert(utf8.encode(message)).toString();
    state = calculatedHash == hash;
  }
}
