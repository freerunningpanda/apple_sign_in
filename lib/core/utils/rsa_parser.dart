import 'dart:convert';
import 'dart:developer';
import 'package:asn1lib/asn1lib.dart';
import 'package:pointycastle/asymmetric/api.dart';

/// [RSAParser] - парсер для RSA-ключей.
class RSAParser {
  const RSAParser._();

  /// Метод [parsePublicKeyFromPem] парсит публичный ключ из PEM-строки.
  static RSAPublicKey parsePublicKeyFromPem(String pem) {
    try {
      // Удаляем служебные строки (BEGIN/END PUBLIC KEY) и декодируем Base64
      final keyString = pem
          .replaceAll('-----BEGIN PUBLIC KEY-----', '')
          .replaceAll('-----END PUBLIC KEY-----', '')
          .replaceAll('\n', '')
          .trim();
      final keyBytes = base64Decode(keyString);

      // Парсим DER-кодированные данные
      final asn1Parser = ASN1Parser(keyBytes);
      final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;

      // Проверяем, что это структура SubjectPublicKeyInfo или RSAPublicKey
      if (topLevelSeq.elements.length == 2 &&
          topLevelSeq.elements[1] is ASN1BitString) {
        // SubjectPublicKeyInfo
        final publicKeyBitString = topLevelSeq.elements[1] as ASN1BitString;
        final publicKeyAsn1Parser =
            ASN1Parser(publicKeyBitString.contentBytes());
        final publicKeySeq = publicKeyAsn1Parser.nextObject() as ASN1Sequence;

        final modulus =
            (publicKeySeq.elements[0] as ASN1Integer).valueAsBigInteger;
        final publicExponent =
            (publicKeySeq.elements[1] as ASN1Integer).valueAsBigInteger;

        return RSAPublicKey(modulus, publicExponent);
      } else if (topLevelSeq.elements.length == 2 &&
          topLevelSeq.elements[0] is ASN1Integer &&
          topLevelSeq.elements[1] is ASN1Integer) {
        // PKCS#1
        final modulus =
            (topLevelSeq.elements[0] as ASN1Integer).valueAsBigInteger;
        final publicExponent =
            (topLevelSeq.elements[1] as ASN1Integer).valueAsBigInteger;

        return RSAPublicKey(modulus, publicExponent);
      } else {
        throw const FormatException('Некорректная структура публичного ключа.');
      }
    } catch (e) {
      log('Ошибка парсинга публичного ключа: $e');
      rethrow;
    }
  }

  /// Метод [parsePrivateKeyFromPem] парсит приватный ключ из PEM-строки.
  static RSAPrivateKey parsePrivateKeyFromPem(String pem) {
    try {
      // Удаляем служебные строки (BEGIN/END RSA PRIVATE KEY) и декодируем Base64
      final keyString = pem
          .replaceAll('-----BEGIN PRIVATE KEY-----', '')
          .replaceAll('-----END PRIVATE KEY-----', '')
          .replaceAll('-----BEGIN RSA PRIVATE KEY-----', '')
          .replaceAll('-----END RSA PRIVATE KEY-----', '')
          .replaceAll('\n', '')
          .trim();
      final keyBytes = base64Decode(keyString);

      // Парсим DER-кодированные данные
      final asn1Parser = ASN1Parser(keyBytes);
      final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;

      // Проверяем, что это правильная структура PKCS#1
      if (topLevelSeq.elements.length < 9) {
        throw const FormatException('Некорректная структура PKCS#1.');
      }

      // Извлекаем параметры ключа
      final modulus =
          (topLevelSeq.elements[1] as ASN1Integer).valueAsBigInteger;
      final privateExponent =
          (topLevelSeq.elements[3] as ASN1Integer).valueAsBigInteger;
      final p = (topLevelSeq.elements[4] as ASN1Integer).valueAsBigInteger;
      final q = (topLevelSeq.elements[5] as ASN1Integer).valueAsBigInteger;

      // Возвращаем приватный ключ
      return RSAPrivateKey(modulus, privateExponent, p, q);
    } catch (e) {
      log('Ошибка парсинга приватного ключа: $e');
      rethrow;
    }
  }
}
