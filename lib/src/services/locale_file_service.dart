import 'dart:convert';
import 'package:flutter/services.dart';

class LocaleFileService {
  static Future<Map<String, String>> getLocaleFiles(List<String> locales, String basePath) async {
    List<String> localizedFiles = await _getAllLocaleFiles(basePath);
    return {for (final language in locales.toSet()) language: _findLocaleFile(language, localizedFiles, basePath)};
  }

  static Future<String?> getLocaleContent(String file) async {
    ByteData data = await rootBundle.load(file);
    return utf8.decode(data.buffer.asUint8List());
  }

  static Future<List<String>> _getAllLocaleFiles(String basePath) async {
    // final manifest = await rootBundle.loadString(Constants.assetManifestFilename);
    // Map<String, dynamic> map = jsonDecode(manifest);
    // var separator = basePath.endsWith('/') ? '' : '/';
    // return map.keys.where((x) => x.startsWith('$basePath$separator')).toList();

    AssetManifest assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    List<String> assets = assetManifest.listAssets();
    String separator = basePath.endsWith('/') ? '' : '/';
    return assets.where((x) => x.startsWith('$basePath$separator')).toList();
  }

  static String _findLocaleFile(String languageCode, List<String> localizedFiles, String basePath) {
    String? file = _getFilepath(languageCode, basePath);

    if (!localizedFiles.contains(file)) {
      if (languageCode.contains('_')) {
        file = _getFilepath(languageCode.split('_').first, basePath);
      }
    }

    if (file == null) {
      throw new Exception('The asset file for the language "$languageCode" was not found.');
    }

    return file;
  }

  static String? _getFilepath(String languageCode, String basePath) {
    String separator = basePath.endsWith('/') ? '' : '/';
    return '$basePath$separator$languageCode.json';
  }
}
