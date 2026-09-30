import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateService {
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      await remoteConfig.setDefaults({
        'latest_android_version': '1.0.0',
        'minimum_android_version': '1.0.0',
        'android_store_url':
            'https://play.google.com/store/apps/details?id=com.yourcompany.velai',
      });

      await remoteConfig.fetchAndActivate();

      final packageInfo = await PackageInfo.fromPlatform();

      final installedVersion = packageInfo.version;
      final latestVersion =
          remoteConfig.getString('latest_android_version');
      final minimumVersion =
          remoteConfig.getString('minimum_android_version');
      final storeUrl = remoteConfig.getString('android_store_url');

      if (!context.mounted) return;

      if (_compareVersions(installedVersion, minimumVersion) < 0) {
        _showUpdateDialog(
          context: context,
          storeUrl: storeUrl,
          forceUpdate: true,
        );
      } else if (_compareVersions(installedVersion, latestVersion) < 0) {
        _showUpdateDialog(
          context: context,
          storeUrl: storeUrl,
          forceUpdate: false,
        );
      }
    } catch (error) {
      debugPrint('Update check failed: $error');
    }
  }

  static int _compareVersions(String current, String required) {
    final currentParts = current.split('.').map(int.parse).toList();
    final requiredParts = required.split('.').map(int.parse).toList();

    final maxLength = currentParts.length > requiredParts.length
        ? currentParts.length
        : requiredParts.length;

    for (int index = 0; index < maxLength; index++) {
      final currentValue =
          index < currentParts.length ? currentParts[index] : 0;
      final requiredValue =
          index < requiredParts.length ? requiredParts[index] : 0;

      if (currentValue < requiredValue) return -1;
      if (currentValue > requiredValue) return 1;
    }

    return 0;
  }

  static void _showUpdateDialog({
    required BuildContext context,
    required String storeUrl,
    required bool forceUpdate,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (dialogContext) {
        return PopScope(
          canPop: !forceUpdate,
          child: AlertDialog(
            title: const Text('Update Available'),
            content: Text(
              forceUpdate
                  ? 'A newer version is required to continue using VELAI. Please update the app.'
                  : 'A newer version of VELAI is available. Update now for the latest features and improvements.',
            ),
            actions: [
              if (!forceUpdate)
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Later'),
                ),
              FilledButton(
                onPressed: () => _openStore(storeUrl),
                child: const Text('Update Now'),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _openStore(String storeUrl) async {
    final uri = Uri.parse(storeUrl);

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened) {
      throw Exception('Could not open Play Store');
    }
  }
}