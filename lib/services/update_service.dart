
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class UpdateService {
  // আপনার server URL এখানে দিবেন যেখানে version.json file থাকবে
  // TODO: version.json file Google Drive এ upload করে তার direct link এখানে দিন
  // Format: https://drive.google.com/uc?export=download&id=YOUR_FILE_ID
  // Google Drive direct download link for version.json
  static const String versionCheckUrl = 'https://drive.google.com/uc?export=download&id=1oxQFchysFeEO2v8NndD9F0pr1wh6dHEv';
  

  final Dio _dio = Dio();

  /// Check করে নতুন update আছে কিনা
  Future<UpdateInfo?> checkForUpdate() async {
    try {
      print('🔎 UpdateService: Starting update check...');
      print('   URL: $versionCheckUrl');

      // বর্তমান app এর version info নেয়া
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuildNumber = int.parse(packageInfo.buildNumber);

      print('📱 Current app version: $currentVersion (build $currentBuildNumber)');

      // Server থেকে latest version info নেয়া
      print('🌐 Fetching version info from server...');
      final response = await _dio.get(
        versionCheckUrl,
        options: Options(
          responseType: ResponseType.json,
          validateStatus: (status) => status! < 500,
        ),
      );
      print('📡 Server response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Response received successfully');
        print('📦 Response type: ${response.data.runtimeType}');

        // Parse JSON if it's a string
        dynamic data = response.data;
        if (data is String) {
          print('⚙️ Parsing JSON string...');
          data = json.decode(data);
        }
        print('📦 Response data: $data');

        final latestVersion = data['version'] as String;
        final latestBuildNumber = data['buildNumber'] as int;
        final apkUrl = data['apkUrl'] as String;
        final releaseNotes = data['releaseNotes'] as String;

        print('🆕 Latest version: $latestVersion (build $latestBuildNumber)');
        print('🔗 APK URL: $apkUrl');

        // Check করা যে নতুন version আছে কিনা
        if (latestBuildNumber > currentBuildNumber) {
          print('🎉 New update available!');
          return UpdateInfo(
            currentVersion: currentVersion,
            latestVersion: latestVersion,
            apkUrl: apkUrl,
            releaseNotes: releaseNotes,
            isUpdateAvailable: true,
          );
        } else {
          print('✅ App is already up to date');
          return UpdateInfo(
            currentVersion: currentVersion,
            latestVersion: latestVersion,
            apkUrl: '',
            releaseNotes: '',
            isUpdateAvailable: false,
          );
        }
      } else {
        print('❌ Bad response status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Update check error: $e');
      print('   Error type: ${e.runtimeType}');
      rethrow;
    }
    return null;
  }

  /// APK download করা
  Future<String> downloadApk(
    String url, {
    Function(int, int)? onProgress,
  }) async {
    try {
      print('📥 UpdateService: Starting APK download...');
      print('   Download URL: $url');

      // Download directory নেয়া
      final dir = await getExternalStorageDirectory();
      final filePath = '${dir!.path}/app-update.apk';

      print('📂 Download directory: ${dir.path}');
      print('📄 File path: $filePath');

      // পুরনো APK delete করা যদি থাকে
      final file = File(filePath);
      if (await file.exists()) {
        print('🗑️ Deleting old APK file...');
        await file.delete();
        print('✅ Old APK deleted');
      }

      // নতুন APK download করা
      print('⬇️ Starting download...');
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received, total);
          }
        },
      );

      print('✅ Download completed successfully!');
      print('   File size: ${await file.length()} bytes');

      return filePath;
    } catch (e) {
      print('❌ Download error: $e');
      print('   Error type: ${e.runtimeType}');
      rethrow;
    }
  }
}

class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String apkUrl;
  final String releaseNotes;
  final bool isUpdateAvailable;

  UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.apkUrl,
    required this.releaseNotes,
    required this.isUpdateAvailable,
  });
}
