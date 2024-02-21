import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

import 'identifying_property.dart';

enum InstallScope implements IdentifyingProperty {
  user(key: 'user'),
  machine(key: 'machine'),
  matchAll(key: '_');

  final String key;
  const InstallScope({required this.key});

  factory InstallScope.fromYaml(dynamic string) {
    return maybeParse(string)!;
  }

  factory InstallScope.parse(String string) {
    return maybeParse(string)!;
  }

  static InstallScope? maybeParse(String? scope) {
    if (scope == null) {
      return null;
    }
    for (InstallScope s in InstallScope.values) {
      if (s.key == scope) {
        return s;
      }
    }
    throw ArgumentError('Unknown scope: $scope');
  }

  @override
  String shortTitle([AppLocalizations? locale]) {
    if(locale == null) throw ArgumentError.notNull("locale");
    switch (this) {
      case InstallScope.user:
        return locale.userScope;
      case InstallScope.machine:
        return locale.machineScope;
      case InstallScope.matchAll:
        return "<match all>";
    }
  }

  @override
  String? longTitle([AppLocalizations? _, LocaleNames? __]) => null;

  @override
  bool get fullTitleHasShortAlways => true;
}
