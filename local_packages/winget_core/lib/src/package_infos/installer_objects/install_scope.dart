

import 'package:winget_core/src/localization_name.dart';
import 'package:winget_core/src/package_localizer.dart';

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
  String shortTitle([PackageLocalizer? locale]) {
    if (locale == null) throw ArgumentError.notNull("locale");
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
  String? longTitle([PackageLocalizer? _, LocalizationName? __]) => null;

  @override
  bool get fullTitleHasShortAlways => true;
}
