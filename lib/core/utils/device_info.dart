import 'package:device_info_plus/device_info_plus.dart';

/// [DeviceInfo] - класс для получения информации об устройстве.
class DeviceInfo {
  DeviceInfo._();

  static final _deviceInfo = DeviceInfoPlugin();

  /// Получение UUID устройства.
  static Future<String> getDeviceUUID() async {
    final uuid = await _deviceInfo.iosInfo
        .then((value) => value.identifierForVendor ?? '');

    return uuid;
  }
}
