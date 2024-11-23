import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/asn1/primitives/asn1_integer.dart';
import 'package:pointycastle/asn1/primitives/asn1_sequence.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';

/// [KeyGeneratorService] - сервис для генерации ключей RSA.
class KeyGeneratorService {
  const KeyGeneratorService._();

  /// Приватный ключ в формате PEM.
  static const privateKey = 'privateKey';

  /// Публичный ключ в формате PEM.
  static const publicKey = 'publicKey';

  /// Генерирует пару RSA-ключей в формате PEM
  static Future<Map<String, String>> generateRSAKeyPair() async {
    // Настройка генератора ключей
    final keyGen = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 64),
          SecureRandom('Fortuna')..seed(KeyParameter(_seed())),
        ),
      );

    // Генерация пары ключей
    final pair = keyGen.generateKeyPair();
    final privateKey = pair.privateKey as RSAPrivateKey;
    final publicKey = pair.publicKey as RSAPublicKey;

    log('Размер приватного ключа: ${privateKey.n?.bitLength} бит');
    log('Размер публичного ключа: ${publicKey.n?.bitLength} бит');

    // Приватный ключ в формате PEM
    final privatePem = _encodePrivateKeyToPem(privateKey);

    // Публичный ключ в формате PEM
    final publicPem = _encodePublicKeyToPem(publicKey);

    return {
      'privateKey': privatePem,
      'publicKey': publicPem,
    };
  }

  /// Генерация случайного seed для SecureRandom
  static Uint8List _seed() {
    final random = SecureRandom('Fortuna');
    final seed = List<int>.generate(
      32,
      (_) => DateTime.now().millisecondsSinceEpoch % 256,
    );
    random.seed(KeyParameter(Uint8List.fromList(seed)));
    return Uint8List.fromList(seed);
  }

  /// Кодировка приватного ключа в формат PEM
  static String _encodePrivateKeyToPem(RSAPrivateKey privateKey) {
    final asn1 = ASN1Sequence()
      ..add(ASN1Integer(BigInt.from(0))) // Версия
      ..add(ASN1Integer(privateKey.modulus))
      ..add(ASN1Integer(privateKey.publicExponent))
      ..add(ASN1Integer(privateKey.privateExponent))
      ..add(ASN1Integer(privateKey.p))
      ..add(ASN1Integer(privateKey.q))
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

    final base64 = base64Encode(asn1.encode());
    return '-----BEGIN PRIVATE KEY-----\n${_formatBase64(base64)}\n-----END PRIVATE KEY-----';
  }

  /// Кодировка публичного ключа в формат PEM
  static String _encodePublicKeyToPem(RSAPublicKey publicKey) {
    final asn1 = ASN1Sequence()
      ..add(ASN1Integer(publicKey.modulus))
      ..add(ASN1Integer(publicKey.exponent));

    final base64 = base64Encode(asn1.encode());
    return '-----BEGIN PUBLIC KEY-----\n${_formatBase64(base64)}\n-----END PUBLIC KEY-----';
  }

  /// Форматирование строки BASE64 в блоки по 64 символа
  static String _formatBase64(String input) {
    final buffer = StringBuffer();
    for (var i = 0; i < input.length; i += 64) {
      buffer.writeln(
        input.substring(i, i + 64 > input.length ? input.length : i + 64),
      );
    }
    return buffer.toString().trim();
  }
}
