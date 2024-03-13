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
  winget('Winget'),
  microsoftStore('Microsoft Store'),
  unknownSource('Unknown Source'),
  none('<None>');

  final String title;
  const PackageSources(this.title);

  factory PackageSources.fromString(String? source) {
    source = source?.trim();
    if (source == null || source.isEmpty) {
      return PackageSources.none;
    }
    switch (source) {
      case 'winget':
        return PackageSources.winget;
      case 'msstore':
        return PackageSources.microsoftStore;
      default:
        return PackageSources.unknownSource;
    }
  }
}
