import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/asn1/asn1_object.dart';
import 'package:pointycastle/asn1/primitives/asn1_bit_string.dart';
import 'package:pointycastle/asn1/primitives/asn1_integer.dart';
import 'package:pointycastle/asn1/primitives/asn1_sequence.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';

/// [KeyGeneratorService] - сервис для генерации ключей RSA.
class KeyGeneratorService {
  const KeyGeneratorService._();

  /// Приватный ключ в формате PEM.
  static const privateKey = 'privateKey';

  /// Публичный ключ в формате PEM.
  static const publicKey = 'publicKey';

  /// Метод [generateRSAKeyPair] генерирует пару ключей RSA.
  static Future<Map<String, String>> generateRSAKeyPair() async {
    // Инициализируем генератор случайных чисел
    final secureRandom = _initializeSecureRandom();

    // Создаем генератор ключей RSA
    final keyPairGenerator = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 12),
          secureRandom,
        ),
      );

    // Генерация пары ключей
    final keyPair = keyPairGenerator.generateKeyPair();
    final publicKey = keyPair.publicKey as RSAPublicKey;
    final privateKey = keyPair.privateKey as RSAPrivateKey;

    // Преобразуем ключи в PEM формат
    final privateKeyPem = encodePrivateKeyToPem(privateKey);
    final publicKeyPem = encodePublicKeyToPem(publicKey);

    return {
      'privateKey': privateKeyPem,
      'publicKey': publicKeyPem,
    };
  }

  static SecureRandom _initializeSecureRandom() {
    final secureRandom = FortunaRandom();

    // Источник энтропии (случайные данные для инициализации)
    final random = Random.secure();
    final seeds = Uint8List(32); // Используем 32 байта энтропии
    for (var i = 0; i < seeds.length; i++) {
      seeds[i] = random.nextInt(256);
    }

    secureRandom.seed(KeyParameter(seeds));
    return secureRandom;
  }

  /// Метод [encodePrivateKeyToPem] преобразует приватный ключ в PEM формат.
  static String encodePrivateKeyToPem(RSAPrivateKey privateKey) {
    final asn1 = ASN1Sequence()
      ..add(ASN1Integer(BigInt.zero)) // Версия ключа
      ..add(ASN1Integer(privateKey.n))
      ..add(ASN1Integer(privateKey.exponent))
      ..add(ASN1Integer(privateKey.p))
      ..add(ASN1Integer(privateKey.q))
      ..add(ASN1Integer(privateKey.privateExponent))
      ..add(
        ASN1Integer(
          privateKey.privateExponent! % (privateKey.p! - BigInt.one),
        ),
      )
      ..add(
        ASN1Integer(
          privateKey.privateExponent! % (privateKey.q! - BigInt.one),
        ),
      )
      ..add(ASN1Integer(privateKey.q!.modInverse(privateKey.p!)));

    final bytes = Uint8List.fromList(asn1.encode());
    final base64 = base64Encode(bytes);

    return '''-----BEGIN PRIVATE KEY-----\n${_formatBase64(base64)}\n-----END PRIVATE KEY-----''';
  }

  /// Метод [encodePublicKeyToPem] преобразует публичный ключ в PEM формат.
  static String encodePublicKeyToPem(RSAPublicKey publicKey) {
    final asn1 = ASN1Sequence()
      ..add(ASN1Integer(publicKey.n))
      ..add(ASN1Integer(publicKey.exponent));

    final sequence = ASN1Sequence()
      ..add(
        ASN1Object.fromBytes(
          Uint8List.fromList(
            [
              0x30,
              0x0D,
              0x06,
              0x09,
              0x2A,
              0x86,
              0x48,
              0x86,
              0xF7,
              0x0D,
              0x01,
              0x01,
              0x01,
              0x05,
              0x00,
            ],
          ),
        ),
      )
      ..add(ASN1BitString(stringValues: Uint8List.fromList(asn1.encode())));

    final bytes = Uint8List.fromList(sequence.encode());
    final base64 = base64Encode(bytes);

    return '''-----BEGIN PUBLIC KEY-----\n${_formatBase64(base64)}\n-----END PUBLIC KEY-----''';
  }

// Форматирование Base64 для PEM
  static String _formatBase64(String base64) {
    final buffer = StringBuffer();
    for (var i = 0; i < base64.length; i += 64) {
      buffer.writeln(
        base64.substring(i, i + 64 > base64.length ? base64.length : i + 64),
      );
    }
    return buffer.toString();
  }
}
