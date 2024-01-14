import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/package_infos/installer_infos.dart';

import '../../../widget_assets/app_locale.dart';
import '../../package_infos/info.dart';

import '../../package_infos/installer_objects/installer.dart';
import '../../package_infos/package_attribute.dart';
import 'expander_compartment.dart';

class InstallerDetails extends ExpanderCompartment {
  final InstallerInfos infos;

  @override
  final IconData titleIcon = FluentIcons.install_to_drive;

  const InstallerDetails({super.key, required this.infos});

  @override
  List<Widget> buildCompartment(BuildContext context) {
    AppLocalizations localization = AppLocalizations.of(context)!;
    Locale? locale = AppLocale.of(context).guiLocale;
    return fullCompartment(
        title: compartmentTitle(localization),
        mainColumn: [
          ...detailsList([
            tryFromInstallerType(infos.type),
            tryFromLocaleInfo(infos.locale, context),
            tryFromDateTimeInfo(infos.releaseDate, locale),
            tryFromScopeInfo(infos.scope, context),
            infos.minimumOSVersion,
            tryFromListInfo(infos.platform, toString: (e) => e.title),
            tryFromInstallerType(infos.nestedInstallerType),
            tryFromUpgradeBehaviorInfo(infos.upgradeBehavior, context),
            tryFromListModeInfo(infos.installModes, localization),
            infos.storeProductID,
            infos.sha256Hash,
            //infos.installerSwitches,
            infos.elevationRequirement,
            infos.productCode,
            infos.dependencies?.toStringInfoFromObject((dependencies) {
              List<String> stringList = [];
              if (dependencies.windowsFeatures != null) {
                stringList.add(
                    'Windows Features: ${dependencies.windowsFeatures!.join(', ')}');
              }
              if (dependencies.windowsLibraries != null) {
                stringList.add(
                    'Windows Libraries: ${dependencies.windowsLibraries!.join(', ')}');
              }
              if (dependencies.packageDependencies != null) {
                stringList.add(
                    'Package Dependencies: ${dependencies.packageDependencies!.map<String>((e) => '${e.packageID}${e.minimumVersion != null ? ' >=${e.minimumVersion}' : ''}').join(', ')}');
              }
              if (dependencies.externalDependencies != null) {
                stringList.add(
                    'External Dependencies: ${dependencies.externalDependencies!.join(', ')}');
              }
              return stringList.join('\n');
            }),
          ], context),
          ...displayRest(infos.otherInfos, context),
        ],
        buttonRow: infos.url != null
            ? buttonRow([infos.url], context)
            : (infos.installers != null)
                ? displayInstallers(infos.installers!, context)
                : null,
        context: context);
  }

  @override
  bool get initiallyExpanded => false;

  Wrap displayInstallers(
      Info<List<Installer>> installers, BuildContext context) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: [
        for (Installer installer in installers.value)
          installerWidget(installer, installers.value, context),
      ],
    );
  }

  @override
  String compartmentTitle(AppLocalizations locale) {
    return PackageAttribute.installer.title(locale);
  }

  Widget installerWidget(Installer installer, List<Installer> installerList,
      BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Expander(
      header: Text(
        installer.uniqueProperties(installerList, context),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: fullCompartment(
            context: context,
            mainColumn: [
              ...detailsList([
                tryFromArchitectureInfo(installer.architecture),
                tryFromInstallerType(installer.type),
                tryFromLocaleInfo(installer.locale, context),
                tryFromScopeInfo(installer.scope, context),
                installer.minimumOSVersion,
                tryFromListInfo(installer.availableCommands),
                tryFromListInfo(installer.platform, toString: (e) => e.title),
                tryFromInstallerType(installer.nestedInstallerType),
                tryFromUpgradeBehaviorInfo(installer.upgradeBehavior, context),
                tryFromListModeInfo(installer.modes, locale),
                installer.elevationRequirement,
                installer.productCode,
                installer.sha256Hash,
                installer.signatureSha256,
              ], context),
              ...displayRest(installer.other, context)
            ],
            buttonRow: buttonRow([installer.url], context)),
      ),
    );
  }
}
