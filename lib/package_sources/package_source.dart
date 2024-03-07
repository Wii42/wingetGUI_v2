import 'dart:ui';

import 'package:winget_gui/output_handling/package_infos/package_infos_full.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_peek.dart';

import '../helpers/log_stream.dart';

abstract class PackageSource {
  late final Logger log;
  final PackageInfosPeek package;

  PackageSource(this.package) {
    log = Logger(this);
  }

  Future<PackageInfosFull> fetchInfos(Locale? guiLocale);
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
