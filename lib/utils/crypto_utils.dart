import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class CryptoUtils {
  static String generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  static String generateBase32Secret({int length = 32}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  static bool isValidBase32(String input) {
    final cleanInput = input.toUpperCase().replaceAll(RegExp(r'[^A-Z2-7]'), '');
    return cleanInput.length >= 16 && RegExp(r'^[A-Z2-7]+$').hasMatch(cleanInput);
  }

  static String normalizeBase32(String input) {
    return input.toUpperCase().replaceAll(RegExp(r'[^A-Z2-7]'), '');
  }

  static Uint8List base32Decode(String input) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final cleanInput = normalizeBase32(input);
    
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

  static String base32Encode(Uint8List bytes) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    String result = '';
    
    for (int i = 0; i < bytes.length; i += 5) {
      int group = 0;
      int groupSize = 0;
      
      for (int j = 0; j < 5 && i + j < bytes.length; j++) {
        group = (group << 8) | bytes[i + j];
        groupSize += 8;
      }
      
      while (groupSize > 0) {
        int index;
        if (groupSize >= 5) {
          index = (group >> (groupSize - 5)) & 0x1F;
          groupSize -= 5;
        } else {
          index = (group << (5 - groupSize)) & 0x1F;
          groupSize = 0;
        }
        result += alphabet[index];
      }
    }
    
    return result;
  }

  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static String generateSalt() {
    return generateRandomString(32);
  }

  static bool verifyPassword(String password, String hash, String salt) {
    return hashPassword(password, salt) == hash;
  }

  static Uint8List deriveKey(String password, String salt, {int iterations = 10000}) {
    final passwordBytes = utf8.encode(password);
    final saltBytes = utf8.encode(salt);
    
    Uint8List result = Uint8List.fromList([...passwordBytes, ...saltBytes]);
    
    for (int i = 0; i < iterations; i++) {
      result = Uint8List.fromList(sha256.convert(result).bytes);
    }
    
    return result;
  }
}