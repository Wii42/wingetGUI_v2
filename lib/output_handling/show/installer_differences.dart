import 'package:fluent_ui/fluent_ui.dart';

import '../package_infos/installer_objects/computer_architecture.dart';
import '../package_infos/installer_objects/install_scope.dart';
import '../package_infos/installer_objects/installer.dart';
import '../package_infos/installer_objects/installer_type.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InstallerDifferences {
  List<ComputerArchitecture> architectures;
  List<InstallerType?> types;
  List<Locale?> locales;
  List<InstallScope?> scopes;

  String architectureTitle, typeTitle, localeTitle, scopeTitle;

  InstallerDifferences({
    required this.architectures,
    required this.types,
    required this.locales,
    required this.scopes,
    required this.architectureTitle,
    required this.typeTitle,
    required this.localeTitle,
    required this.scopeTitle,
  });

  factory InstallerDifferences.fromList(
      List<Installer> installers, BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    List<ComputerArchitecture> architectures = [];
    List<InstallerType?> types = [];
    List<Locale?> locales = [];
    List<InstallScope?> scopes = [];

    String? architectureTitle, typeTitle, localeTitle, scopeTitle;
    for (Installer installer in installers) {
      if (!architectures.contains(installer.architecture.value)) {
        architectures.add(installer.architecture.value);
      }
      if (!types.contains(installer.type?.value)) {
        types.add(installer.type?.value);
      }
      if (!locales.contains(installer.locale?.value)) {
        locales.add(installer.locale?.value);
      }
      if (!scopes.contains(installer.scope?.value)) {
        scopes.add(installer.scope?.value);
      }

      architectureTitle ??= installer.architecture.title(locale);
      if (installer.type != null) {
        typeTitle ??= installer.type!.title(locale);
      }
      if (installer.locale != null) {
        localeTitle ??= installer.locale!.title(locale);
      }
      if (installer.scope != null) {
        scopeTitle ??= installer.scope!.title(locale);
      }
    }
    return InstallerDifferences(
        architectures: architectures,
        types: types,
        locales: locales,
        scopes: scopes,
        architectureTitle: architectureTitle!,
        typeTitle: typeTitle ?? 'Type',
        localeTitle: localeTitle ?? 'Locale',
        scopeTitle: scopeTitle ?? 'Scope');
  }

  @override
  String toString() {
    return 'InstallerDifferences{architectures: $architectures, types: $types, locales: $locales, scopes: $scopes}';
  }
}
