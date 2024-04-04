import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension AppLocalizationExtension on AppLocalizations {
  String downloadInstallerManually(String? description) {
    String installerDescription = installer(description ?? '').trim();
    return downloadManually(installerDescription);
  }
}
