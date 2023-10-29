import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum UpgradeBehavior {
  install(key: 'install'),
  uninstallPrevious(key: 'uninstallPrevious'),
  ;

  final String key;
  const UpgradeBehavior({required this.key});

  factory UpgradeBehavior.parse(String behavior) {
    for(UpgradeBehavior b in UpgradeBehavior.values) {
      if(b.key == behavior) {
        return b;
      }
    }
    throw ArgumentError('Unknown upgrade behavior: $behavior');
  }

  String title(AppLocalizations locale) {
    return locale.upgradeBehavior(key);
  }
}
