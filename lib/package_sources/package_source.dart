import 'dart:ui';

import 'package:winget_gui/output_handling/package_infos/package_infos_full.dart';

import '../helpers/log_stream.dart';
import '../output_handling/package_infos/package_infos.dart';

abstract class PackageSource {
  late final Logger log;
  final PackageInfos package;

  PackageSource(this.package) {
    log = Logger(this);
  }

  Future<PackageInfosFull> fetchInfos(Locale? guiLocale);

  /// The URL to the manifest file/folder of the package for the user, not API.
  /// If not available, returns null.
  Uri? get manifestUrl;
}

enum PackageSources {
  winget('Winget', 'winget'),
  microsoftStore('Microsoft Store', 'msstore'),
  unknownSource('Unknown Source', '<unknown>'),
  none('<None>', '<none>');

  final String title;
  final String key;
  const PackageSources(this.title, this.key);

  factory PackageSources.fromString(String? source) {
    source = source?.trim();
    if (source == null || source.isEmpty) {
      return PackageSources.none;
    }
    for (PackageSources packageSource in PackageSources.values) {
      if (packageSource.key == source) {
        return packageSource;
      }
    }
    return PackageSources.unknownSource;
  }
}
