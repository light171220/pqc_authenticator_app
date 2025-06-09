import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import '../models/account.dart';
import '../models/totp_code.dart';

class TotpService {
  static String generateTotpCode(Account account, {DateTime? time}) {
    final currentTime = time ?? DateTime.now();
    final timeStep = currentTime.millisecondsSinceEpoch ~/ 1000 ~/ account.period;
    
    final key = _base32Decode(account.secret);
    final timeBytes = _intToBytes(timeStep);
    
    final hmac = _computeHmac(key, timeBytes, account.algorithm);
    final offset = hmac[hmac.length - 1] & 0x0f;
    
    final code = ((hmac[offset] & 0x7f) << 24) |
                 ((hmac[offset + 1] & 0xff) << 16) |
                 ((hmac[offset + 2] & 0xff) << 8) |
                 (hmac[offset + 3] & 0xff);
    
    final truncatedCode = code % pow(10, account.digits).toInt();
    return truncatedCode.toString().padLeft(account.digits, '0');
  }

  static TotpCode generateTotpCodeWithTimer(Account account) {
    final now = DateTime.now();
    final code = generateTotpCode(account, time: now);
    final secondsInPeriod = (now.millisecondsSinceEpoch ~/ 1000) % account.period;
    final remainingSeconds = account.period - secondsInPeriod;
    
    return TotpCode(
      accountId: account.id,
      code: code,
      remainingSeconds: remainingSeconds,
      generatedAt: now,
    );
  }

  static Uint8List _base32Decode(String input) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final cleanInput = input.toUpperCase().replaceAll(RegExp(r'[^A-Z2-7]'), '');
    
    final bits = <bool>[];
    for (final char in cleanInput.split('')) {
      final index = alphabet.indexOf(char);
      if (index == -1) continue;
      
      for (int i = 4; i >= 0; i--) {
        bits.add((index >> i) & 1 == 1);
      }
    }
    
    final bytes = <int>[];
    for (int i = 0; i < bits.length; i += 8) {
      if (i + 7 >= bits.length) break;
      
      int byte = 0;
      for (int j = 0; j < 8; j++) {
        if (bits[i + j]) {
          byte |= 1 << (7 - j);
        }
      }
      bytes.add(byte);
    }
    
    return Uint8List.fromList(bytes);
  }

  static Uint8List _intToBytes(int value) {
    final bytes = Uint8List(8);
    for (int i = 7; i >= 0; i--) {
      bytes[i] = value & 0xff;
      value >>= 8;
    }
    return bytes;
  }

  static Uint8List _computeHmac(Uint8List key, Uint8List data, String algorithm) {
    late Hmac hmac;
    switch (algorithm.toUpperCase()) {
      case 'SHA256':
        hmac = Hmac(sha256, key);
        break;
      case 'SHA512':
        hmac = Hmac(sha512, key);
        break;
      default:
        hmac = Hmac(sha1, key);
    }
    
    return Uint8List.fromList(hmac.convert(data).bytes);
  }
}