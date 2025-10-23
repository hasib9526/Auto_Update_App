import 'dart:io';
import 'package:flutter/services.dart';

class ApkInstaller {
  static const platform = MethodChannel('com.factory.auto_update_app/installer');

  /// APK install করার জন্য Android এর native code call করা
  static Future<void> installApk(String filePath) async {
    try {
      if (Platform.isAndroid) {
        await platform.invokeMethod('installApk', {'filePath': filePath});
      }
    } on PlatformException catch (e) {
      print('Failed to install APK: ${e.message}');
      rethrow;
    }
  }
}
