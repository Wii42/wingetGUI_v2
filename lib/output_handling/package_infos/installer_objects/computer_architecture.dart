import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

import 'identifying_property.dart';

enum ComputerArchitecture implements IdentifyingProperty {
  x86(key: 'x86', title: 'x86'),
  x64(key: 'x64', title: 'x64'),
  arm(key: 'arm', title: 'ARM'),
  arm64(key: 'arm64', title: 'ARM64'),
  neutal(key: 'neutral', title: 'Architecture neutral'),
  matchAll(key: '_', title: '<match all>');

  final String key, _title;
  const ComputerArchitecture({required this.key, required String title})
      : _title = title;

  static ComputerArchitecture parse(String string) {
    return maybeParse(string)!;
  }

  static ComputerArchitecture? maybeParse(String? architecture) {
    if (architecture == null) {
      return null;
    }
    for (ComputerArchitecture arch in ComputerArchitecture.values) {
      if (arch.key == architecture) {
        return arch;
      }
    }
    throw ArgumentError('Unknown architecture: $architecture');
  }

  @override
  String shortTitle([AppLocalizations? _]) => _title;
  @override
  String? longTitle([AppLocalizations? _, LocaleNames? __]) => null;
  @override
  bool get fullTitleHasShortAlways => true;
}
