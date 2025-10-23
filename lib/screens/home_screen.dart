import 'package:flutter/material.dart';
import 'package:auto_update_app/services/update_service.dart';
import 'package:auto_update_app/utils/apk_installer.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UpdateService _updateService = UpdateService();
  bool _isChecking = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _currentVersion = '';
  String _statusMessage = 'আপনার অ্যাপ আপডেট চেক করুন';

  @override
  void initState() {
    super.initState();
    _loadCurrentVersion();
  }

  Future<void> _loadCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _currentVersion = packageInfo.version;
    });
  }

  Future<void> _requestPermissions() async {
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
    if (await Permission.requestInstallPackages.isDenied) {
      await Permission.requestInstallPackages.request();
    }
  }

  Future<void> _checkForUpdate() async {
    print('🔍 Check for update button clicked');
    setState(() {
      _isChecking = true;
      _statusMessage = 'আপডেট চেক করা হচ্ছে...';
    });

    try {
      print('📱 Requesting permissions...');
      await _requestPermissions();
      print('✅ Permissions granted');

      print('🌐 Checking for updates from server...');
      final updateInfo = await _updateService.checkForUpdate();
      print('📦 Update info received: $updateInfo');

      if (updateInfo == null) {
        print('❌ Update info is null');
        setState(() {
          _statusMessage = 'আপডেট চেক করতে সমস্যা হয়েছে';
          _isChecking = false;
        });
        return;
      }

      if (updateInfo.isUpdateAvailable) {
        print('🎉 New update available!');
        print('   Current: ${updateInfo.currentVersion}');
        print('   Latest: ${updateInfo.latestVersion}');
        print('   APK URL: ${updateInfo.apkUrl}');
        setState(() {
          _statusMessage =
              'নতুন আপডেট পাওয়া গেছে! (${updateInfo.latestVersion})';
          _isChecking = false;
        });

        // Update dialog দেখানো
        _showUpdateDialog(updateInfo);
      } else {
        print('✅ App is up to date');
        print('   Current version: ${updateInfo.currentVersion}');
        setState(() {
          _statusMessage = 'আপনার অ্যাপ সর্বশেষ ভার্সনে আছে';
          _isChecking = false;
        });

        _showNoUpdateDialog();
      }
    } catch (e) {
      print('❌ ERROR: ${e.toString()}');
      print('   Stack trace: ${StackTrace.current}');
      setState(() {
        _statusMessage = 'Error: ${e.toString()}';
        _isChecking = false;
      });

      _showErrorDialog(e.toString());
    }
  }

  void _showUpdateDialog(UpdateInfo updateInfo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('নতুন আপডেট পাওয়া গেছে'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('বর্তমান ভার্সন: ${updateInfo.currentVersion}'),
            Text('নতুন ভার্সন: ${updateInfo.latestVersion}'),
            const SizedBox(height: 10),
            Text('বিবরণ: ${updateInfo.releaseNotes}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('পরে'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadAndInstall(updateInfo.apkUrl);
            },
            child: const Text('আপডেট করুন'),
          ),
        ],
      ),
    );
  }

  void _showNoUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('কোন আপডেট নেই'),
        content: const Text('আপনার অ্যাপ সর্বশেষ ভার্সনে আছে।'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ঠিক আছে'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(
          'আপডেট চেক করতে সমস্যা হয়েছে।\n\nনিশ্চিত করুন যে:\n1. ইন্টারনেট সংযোগ আছে\n2. Server URL সঠিক আছে\n\nError: $error',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ঠিক আছে'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadAndInstall(String apkUrl) async {
    print('⬇️ Starting download and install process');
    print('   APK URL: $apkUrl');
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _statusMessage = 'ডাউনলোড হচ্ছে...';
    });

    try {
      print('📥 Downloading APK...');
      final filePath = await _updateService.downloadApk(
        apkUrl,
        onProgress: (received, total) {
          final progress = (received / total * 100).toStringAsFixed(0);
          print('📊 Download progress: $progress% ($received/$total bytes)');
          setState(() {
            _downloadProgress = received / total;
            _statusMessage =
                'ডাউনলোড হচ্ছে... ${(_downloadProgress * 100).toStringAsFixed(0)}%';
          });
        },
      );

      print('✅ Download completed!');
      print('   File path: $filePath');

      setState(() {
        _statusMessage = 'ইনস্টল করা হচ্ছে...';
      });

      // APK install করা
      print('📲 Installing APK...');
      await ApkInstaller.installApk(filePath);
      print('✅ Installation started (waiting for user confirmation)');

      setState(() {
        _isDownloading = false;
        _statusMessage = 'আপডেট সম্পন্ন হয়েছে';
      });
    } catch (e) {
      print('❌ Download/Install ERROR: ${e.toString()}');
      print('   Stack trace: ${StackTrace.current}');
      setState(() {
        _isDownloading = false;
        _statusMessage = 'ডাউনলোড ব্যর্থ হয়েছে: ${e.toString()}';
      });

      _showErrorDialog('ডাউনলোড/ইনস্টল করতে সমস্যা হয়েছে: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Factory App V3 versionnnnnnnn'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.android,
                size: 80,
                color: Colors.blue.shade700,
              ),
            ),

            const SizedBox(height: 30),

            // Current Version
            Text(
              'বর্তমান ভার্সন: $_currentVersion',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 20),

            // Status Message
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 30),

            // Download Progress
            if (_isDownloading)
              Column(
                children: [
                  LinearProgressIndicator(
                    value: _downloadProgress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 30),

            // Check for Update Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _isChecking || _isDownloading ? null : _checkForUpdate,
                icon: _isChecking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.system_update),
                label: Text(
                  _isChecking ? 'চেক করা হচ্ছে...' : 'আপডেট চেক করুন',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Info Card
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'আপডেট বাটনে ক্লিক করলে নতুন ভার্সন চেক হবে এবং থাকলে ডাউনলোড হবে।',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
