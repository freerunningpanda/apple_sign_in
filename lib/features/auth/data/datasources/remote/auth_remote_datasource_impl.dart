import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:apple_id_auth/core/utils/api_keys.dart';
import 'package:apple_id_auth/core/utils/device_info.dart';
import 'package:apple_id_auth/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:apple_id_auth/features/auth/data/services/key_generator_service.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart' hide RSASigner;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:uuid/uuid.dart';

/// [AuthRemoteDatasourceImpl] - реализация [AuthRemoteDatasource].
class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  /// Создает [AuthRemoteDatasourceImpl] с [Dio].
  AuthRemoteDatasourceImpl(
    this._dio,
    this._secureStorage,
  ) {
    KeyGeneratorService.generateRSAKeyPair().then((keys) {
      _secureStorage
        ..write(
          key: KeyGeneratorService.privateKey,
          value: keys[KeyGeneratorService.privateKey],
        )
        ..write(
          key: KeyGeneratorService.publicKey,
          value: keys[KeyGeneratorService.publicKey],
        );
    });
  }

  /// [Dio] для работы с сетью.
  final Dio _dio;

  /// [FlutterSecureStorage] для хранения ключей.
  final FlutterSecureStorage _secureStorage;

  @override
  Future<void> signInWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final email = credential.email ?? '';
    final userId = credential.userIdentifier;
    final udid = await DeviceInfo.getDeviceUUID();
    final rnd = const Uuid().v4();
    final signature = await _generateSignature(udid, rnd, userId ?? '');

    // Отправка публичного ключа.
    await _sendPublicKeyToServer(udid, rnd).then((_) {
      log('Отправлен публичный ключ');
      // Отправка данных авторизации.
      _sendAuthorizationToServer(
        udid: udid,
        email: email,
        login: userId ?? '',
        rnd: rnd,
        signature: signature,
      );
    });
  }

  // Генерация подписи.
  Future<String> _generateSignature(
    String udid,
    String rnd,
    String login,
  ) async {
    // Конкатенация строки.
    final data = utf8.encode('$udid$rnd$login');

    // Хеширование данных с использованием SHA1.
    final sha1Digest = SHA1Digest();
    final hashedData = sha1Digest.process(Uint8List.fromList(data));

    // Восстановление приватного ключа.
    final privateKeyPEM =
        await _secureStorage.read(key: KeyGeneratorService.privateKey);

    if (privateKeyPEM != null) {
      final parser = RSAKeyParser();
      final privateKey = parser.parse(privateKeyPEM) as RSAPrivateKey;

      // Подписание данных с использованием RSA.
      final signer = RSASigner(SHA256Digest(), '0609608648016503040201')
        ..init(
          true,
          PrivateKeyParameter<RSAPrivateKey>(privateKey),
        );

      final signature =
          signer.generateSignature(Uint8List.fromList(hashedData));

      // Преобразование подписи в Base64.
      return base64Encode(signature.bytes);
    }

    throw Exception('Приватный ключ не найден');
  }

  // Отправка публичного ключа на сервер.
  Future<void> _sendPublicKeyToServer(String udid, String rnd) async {
    final publicKey = _secureStorage.read(key: KeyGeneratorService.publicKey);
    final signature = _generateSignature(udid, rnd, '');

    final response = await _dio.post<Map<String, dynamic>>(
      ApiKeys.ios,
      data: {
        'oper': 'init',
        'udid': udid,
        'rnd': rnd,
        'pmk': publicKey,
        'signature': signature,
      },
    );

    final data = response.data;
    if (data?['error_code'] != 1) {
      throw Exception("Ошибка отправки ключа: ${data?['error_status']}");
    }
  }

  Future<void> _sendAuthorizationToServer({
    required String udid,
    required String email,
    required String login,
    required String rnd,
    required String signature,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiKeys.ios,
      queryParameters: {
        'udid': udid,
        'email': email,
        'login': login,
        'oper': 'login_apple_id',
        'rnd': rnd,
        'signature': signature,
      },
    );

    final data = response.data;
    if (data?['error_code'] == 1) {
      log("Успешная авторизация: ${data?['work_status']}");
    } else {
      throw Exception("Ошибка авторизации: ${data?['error_status']}");
    }
  }
}
