

import 'package:winget_core/src/package_localizer.dart';

enum UpgradeBehavior {
  install(key: 'install'),
  uninstallPrevious(key: 'uninstallPrevious'),
  deny(key: 'deny'),
  custom(key: '_');

  final String key;

  const UpgradeBehavior({required this.key});

  factory UpgradeBehavior.parse(String behavior) {
    for (UpgradeBehavior b in UpgradeBehavior.values) {
      if (b.key == behavior) {
        return b;
      }
    }
    return custom;
  }

  String title(PackageLocalizer locale) {
    return locale.upgradeBehavior(key);
  }
}
