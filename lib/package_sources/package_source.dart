import 'package:intl/locale.dart';

import 'package:winget_core/winget_core.dart';
import 'package:winget_gui/helpers/log_stream.dart';
import 'package:winget_gui/package_infos/package_infos_full.dart';

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
