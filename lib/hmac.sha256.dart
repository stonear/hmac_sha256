import 'dart:convert';
import 'package:crypto/crypto.dart';

class HmacSha256 {
  String generate(String message, String secret) {
    if (message == "") {
      return "";
    }

    List<int> messageBytes = utf8.encode(message);
    List<int> key = utf8.encode(secret);
    Hmac hmac = Hmac(sha256, key);
    Digest digest = hmac.convert(messageBytes);

    return base64.encode(digest.bytes);
  }

  bool validate(String message, String secret, String signature) {
    if (message == "") {
      return false;
    }

    String signature2 = generate(message, secret);
    if (signature != signature2) {
      return false;
    }

    return true;
  }
}
