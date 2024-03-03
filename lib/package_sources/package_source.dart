import 'dart:ui';

import 'package:winget_gui/output_handling/package_infos/package_infos_full.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_peek.dart';

import '../helpers/log_stream.dart';

abstract class PackageSource {
  late final Logger log;
  final PackageInfosPeek package;

  PackageSource(this.package){ log = Logger(this);}

  Future<PackageInfosFull> fetchInfos(Locale? guiLocale);
}
