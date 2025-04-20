import 'package:winget_core/winget_core.dart';
import 'package:winget_gui/l10n/generated/app_localizations.dart';

class AppLocalizer extends PackageLocalizer {
  final AppLocalizations localizations;

  AppLocalizer(this.localizations);

  @override
  String? infoKey(String info) {
    return checkString(localizations.infoKey(info));
  }

  @override
  String? infoTitle(String info) {
    return checkString(localizations.infoTitle(info));
  }

  String? checkString(String string) {
    if (string == notFoundError) {
      return null;
    }
    return string;
  }

  @override
  String installMode(String key) => localizations.installMode(key);

  @override
  String get machineScope => localizations.machineScope;

  @override
  String returnResponse(String name) => localizations.returnResponse(name);

  @override
  String upgradeBehavior(String key) => localizations.upgradeBehavior(key);

  @override
  String get userScope => localizations.userScope;
}

extension AsAppLocalizer on AppLocalizations {
  AppLocalizer get asLocalizer {
    return AppLocalizer(this);
  }
}
