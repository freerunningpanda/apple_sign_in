import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:apple_id_auth/core/utils/api_keys.dart';
import 'package:apple_id_auth/core/utils/device_info.dart';
import 'package:apple_id_auth/core/utils/rsa_parser.dart';
import 'package:apple_id_auth/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:apple_id_auth/features/auth/data/services/key_generator_service.dart';
import 'package:dio/dio.dart';
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
    // final signature = await _generateSignature(udid, rnd, userId ?? '');

    // Отправка публичного ключа.
    await _sendPublicKeyToServer(udid, rnd).then((_) {
      // Отправка данных авторизации.
      // _sendAuthorizationToServer(
      //   udid: udid,
      //   email: email,
      //   login: userId ?? '',
      //   rnd: rnd,
      //   signature: signature,
      // );
    });
  }

  Future<String> _generateSignature(
    String udid,
    String rnd,
    String login,
  ) async {
    try {
      // Конкатенация строки.
      final dataString = '$udid$rnd$login';
      final data = utf8.encode(dataString);

      // Хеширование данных с использованием SHA1.
      final sha1Digest = SHA1Digest();
      final hashedData = sha1Digest.process(Uint8List.fromList(data));

      // Восстановление приватного ключа.
      final privateKeyPEM =
          await _secureStorage.read(key: KeyGeneratorService.privateKey);
      log('Приватный ключ из кэша: $privateKeyPEM');

      if (privateKeyPEM != null) {
        final privateKey = RSAParser.parsePrivateKeyFromPem(privateKeyPEM);

        // Инициализация SecureRandom.
        final secureRandom = _initializeSecureRandom();

        // Настраиваем RSA-подписчик.
        final signer = Signer('SHA-256/RSA');
        final privateKeyParam = PrivateKeyParameter<RSAPrivateKey>(privateKey);
        signer.init(
          true,
          ParametersWithRandom(
            privateKeyParam,
            secureRandom,
          ),
        );

        // Подписываем хэш.
        final signature = signer.generateSignature(hashedData) as RSASignature;

        final signatureBase64 = base64Encode(signature.bytes);

        log('Подпись в Base64: $signatureBase64');
        return signatureBase64;
      }
    } catch (e, stackTrace) {
      log('Ошибка генерации подписи: $e\n$stackTrace');
    }

    throw Exception('Приватный ключ не найден');
  }

  SecureRandom _initializeSecureRandom() {
    final secureRandom = FortunaRandom();

    // Инициализация с использованием случайного пула данных.
    final seedSource = Uint8List.fromList(
      List<int>.generate(
        32,
        (_) => DateTime.now().millisecondsSinceEpoch % 256,
      ),
    );
    final keyParam = KeyParameter(seedSource);
    secureRandom.seed(keyParam);

    return secureRandom;
  }

  // Отправка публичного ключа на сервер.
  Future<void> _sendPublicKeyToServer(String udid, String rnd) async {
    final publicKey =
        await _secureStorage.read(key: KeyGeneratorService.publicKey);
    final signature = await _generateSignature(udid, rnd, '');

    log('Публичный ключ из кэша: $publicKey');

    final response = await _dio.post<String>(
      ApiKeys.ios,
      data: {
        'oper': 'init',
        'udid': udid,
        'rnd': rnd,
        'pmk': publicKey,
        'signature': signature,
      },
    );

    log('Отправка данных: ${'\noper: init\nudid: $udid\nrnd: $rnd\npmk: $publicKey\nsignature: $signature'}');

    final data = response.data;
    log('Ответ сервера: $data');
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
