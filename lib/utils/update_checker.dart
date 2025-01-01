import 'dart:convert';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/utils/changelog_list.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateChecker {
  final String owner;
  final String repo;
  final String currentVersion;
  final String currentLanguage;

  UpdateChecker({
    required this.owner,
    required this.repo,
    required this.currentVersion,
    required this.currentLanguage,
  });

  Future<bool> checkForUpdates(BuildContext context) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/$owner/$repo/releases/latest'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode == 200) {
        final releaseData = json.decode(response.body);
        final latestVersion = releaseData['tag_name'].toString().replaceAll('v', '');

        if (_isNewerVersion(latestVersion, currentVersion)) {
          final apkAsset = releaseData['assets'].firstWhere(
            (asset) => asset['name'].toString().endsWith('.apk'),
            orElse: () => null,
          );

          if (apkAsset != null) {
            _showUpdateDialog(
                context,
                latestVersion,
                apkAsset['browser_download_url'],
                releaseData['body'] ?? 'Nueva versión disponible');
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  bool _isNewerVersion(String latestVersion, String currentVersion) {
    List<int> latest = latestVersion.split('.').map(int.parse).toList();
    List<int> current = currentVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < latest.length && i < current.length; i++) {
      if (latest[i] > current[i]) return true;
      if (latest[i] < current[i]) return false;
    }
    return latest.length > current.length;
  }

  Column _processChangelog(String changelog) {
    final lines = changelog.split('\r\n');
    final languageSection = currentLanguage == 'en' ? '## English' : '## Español';

    bool isInCorrectSection = false;
    List<Widget> relevantChanges = [];

    for (String line in lines) {
      if (line.trim() == languageSection) {
        isInCorrectSection = true;
        continue;
      }

      else if (line.startsWith('##') || line.startsWith('**Full')) {
        if (isInCorrectSection) break;
        continue;
      }

      if (isInCorrectSection && line.trim().isNotEmpty) {
        String cleanedLine = line.trim().replaceFirst('- ', '');
        relevantChanges.add(ChangelogList(cleanedLine));
      }
    }
    return Column(children: relevantChanges);
  }

  Future<void> _showUpdateDialog(BuildContext context, String newVersion, String downloadUrl, String changelog) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocale.updateMess.getString(context)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(currentLanguage == 'en'
                    ? 'Version $newVersion available for download'
                    : 'Versión $newVersion disponible para descargar'),
                SizedBox(height: 16),
                Text(AppLocale.updateNew.getString(context),
                    style: TextStyle(fontWeight: FontWeight.bold)),
                _processChangelog(changelog),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocale.updateCancel.getString(context)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(AppLocale.updateDown.getString(context)),
              onPressed: () async {
                Navigator.of(context).pop();
                await launchUrl(Uri.parse(downloadUrl));
              },
            ),
          ],
        );
      },
    );
  }
}
