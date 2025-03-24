import 'package:winget_gui/l10n/generated/app_localizations.dart';

extension AppLocalizationExtension on AppLocalizations {
  String downloadInstallerManually(String? description) {
    String installerDescription = installer(description ?? '').trim();
    return downloadManually(installerDescription);
  }
}
