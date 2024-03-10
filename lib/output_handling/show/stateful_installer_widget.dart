import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/app_localizations_extension.dart';
import 'package:winget_gui/output_handling/package_infos/installer_infos.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/package_infos/installer_objects/identifying_property.dart';
import 'package:winget_gui/output_handling/package_infos/installer_objects/installer_list_extension.dart';
import 'package:winget_gui/output_handling/package_infos/to_string_info_extensions.dart';
import 'package:winget_gui/output_handling/show/installer_selector.dart';

import '../../widget_assets/app_locale.dart';
import '../package_infos/info.dart';
import '../package_infos/installer_objects/computer_architecture.dart';
import '../package_infos/installer_objects/install_scope.dart';
import '../package_infos/installer_objects/installer.dart';
import '../package_infos/installer_objects/installer_locale.dart';
import '../package_infos/installer_objects/installer_type.dart';
import '../package_infos/package_attribute.dart';
import 'compartments/expander_compartment.dart';
import 'package:winget_gui/helpers/extensions/best_fitting_locale.dart';

class StatefulInstallerWidget extends StatefulWidget {
  late final _InstallerCompartmentStub _template;
  final InstallerInfos infos;
  final Locale? guiLocale, defaultLocale;
  StatefulInstallerWidget(
      {required this.infos, super.key, this.guiLocale, this.defaultLocale})
      : _template = _InstallerCompartmentStub(infos: infos);

  @override
  State<StatefulWidget> createState() => _StatefulInstallerWidgetState();
}

class _StatefulInstallerWidgetState extends State<StatefulInstallerWidget> {
  ComputerArchitecture? installerArchitecture;
  InstallerType? installerType;
  InstallerLocale? installerLocale;
  InstallScope? installerScope;
  InstallerType? nestedInstallerType;

  Installer? selectedInstaller;

  @override
  void initState() {
    super.initState();
    selectedInstaller = getBestFittingLocaleInstaller();
    installerArchitecture = selectedInstaller?.architecture.value;
    installerType = selectedInstaller?.type?.value;
    installerLocale = selectedInstaller?.locale?.value;
    installerScope = selectedInstaller?.scope?.value;
    nestedInstallerType = selectedInstaller?.nestedInstallerType?.value;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations localization = AppLocalizations.of(context)!;

    bool multipleInstallers =
        infos.installers != null && infos.installers!.value.length > 1;
    Widget content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: template.fullCompartment(
            title: template.compartmentTitle(localization),
            mainColumn: [
              if (multipleInstallers)
                InstallerSelector(
                  installers: infos.installers!.value,
                  installerArchitecture: installerArchitecture,
                  installerType: installerType,
                  installerLocale: installerLocale,
                  installerScope: installerScope,
                  nestedInstallerType: nestedInstallerType,
                  setSelectedInstaller: setSelectedInstaller,
                  setInstallerProperty: setInstallerProperty,
                  selectedInstaller: selectedInstaller,
                ),
              if (multipleInstallers) template.divider(),
              ...template.detailsList(shownDetails(context), context),
              ...displayRest(context),
            ],
            buttonRow: template.buttonRow([
              infos.url,
              selectedInstaller?.url?.copyWith(
                  customTitle: localization.downloadInstallerManually(
                      selectedInstaller?.uniqueProperties(
                          infos.installers!.value, context)))
            ], context),
            context: context));
    return widget._template.buildWithoutContent(context, content);
  }

  List<Info<String>?> shownDetails(BuildContext context) {
    AppLocalizations localization = AppLocalizations.of(context)!;
    Locale? locale = AppLocale.of(context).guiLocale;
    return [
      selectedInstaller?.architecture.toStringInfo(),
      (selectedInstaller?.type ?? infos.type)?.toStringInfo(),
      (selectedInstaller?.locale ?? infos.locale)?.toStringInfo(context),
      infos.releaseDate?.toStringInfo(locale),
      (selectedInstaller?.scope ?? infos.scope)?.toStringInfo(context),
      selectedInstaller?.minimumOSVersion ?? infos.minimumOSVersion,
      (selectedInstaller?.platform ?? infos.platform)?.toStringInfo(),
      selectedInstaller?.availableCommands?.toStringInfo(),
      (selectedInstaller?.nestedInstallerType ?? infos.nestedInstallerType)
          ?.toStringInfo(),
      (selectedInstaller?.upgradeBehavior ?? infos.upgradeBehavior)
          ?.toStringInfo(context),
      (selectedInstaller?.modes ?? infos.installModes)
          ?.toStringInfo(localization),
      selectedInstaller?.storeProductID ?? infos.storeProductID,
      selectedInstaller?.sha256Hash ?? infos.sha256Hash,
      selectedInstaller?.elevationRequirement ?? infos.elevationRequirement,
      selectedInstaller?.productCode ?? infos.productCode,
      infos.dependencies?.toStringInfo(),
      selectedInstaller?.signatureSha256,
      selectedInstaller?.markets,
      selectedInstaller?.packageFamilyName,
      (selectedInstaller?.expectedReturnCodes ?? infos.expectedReturnCodes)
          ?.toStringInfo(localization),
      (selectedInstaller?.successCodes ?? infos.successCodes)
          ?.toStringInfoFromList((e) => e.toString()),
    ];
  }

  InstallerInfos get infos => widget.infos;
  ExpanderCompartment get template => widget._template;

  List<Installer> get fittingInstallers {
    return infos.installers?.value.fittingInstallers(
          installerArchitecture,
          installerType,
          installerLocale,
          installerScope,
          nestedInstallerType,
        ) ??
        [];
  }

  Installer? getBestFittingLocaleInstaller() {
    if (widget.guiLocale != null) {
      List<Locale> installerLocales = infos.installers?.value
              .map((e) => e.locale?.value)
              .nonNulls
              .toList() ??
          [];
      if (installerLocales.length <= 1) {
        return infos.installers?.value.firstOrNull;
      }
      Locale? bestFitting = getBestFittingLocale(installerLocales);
      if (bestFitting != null) {
        return infos.installers?.value
            .firstWhereOrNull((e) => e.locale?.value == bestFitting);
      }
    }
    return widget.infos.installers?.value.firstOrNull;
  }

  Locale? getBestFittingLocale(List<Locale> installerLocales) {
    if (widget.guiLocale != null) {
      Locale? bestFitting =
          widget.guiLocale?.bestFittingLocale(installerLocales);
      if (bestFitting != null) {
        return bestFitting;
      }
    }
    if (widget.defaultLocale != null) {
      return widget.defaultLocale?.bestFittingLocale(installerLocales);
    }
    return null;
  }

  void setInstallerProperty(
      {required PackageAttribute attribute,
      required IdentifyingProperty? value}) {
    setState(() {
      switch (attribute) {
        case PackageAttribute.architecture:
          installerArchitecture = value as ComputerArchitecture;
          break;
        case PackageAttribute.installerType:
          installerType = value as InstallerType?;
          break;
        case PackageAttribute.installerLocale:
          installerLocale = value as InstallerLocale?;
          break;
        case PackageAttribute.installScope:
          installerScope = value as InstallScope?;
          break;
        case PackageAttribute.nestedInstallerType:
          nestedInstallerType = value as InstallerType?;
          break;
        default:
          throw ArgumentError('Unknown attribute: $attribute');
      }
      selectedInstaller = fittingInstallers.firstOrNull;
    });
  }

  void setSelectedInstaller(Installer? installer) {
    setState(() {
      selectedInstaller = installer;
    });
  }

  List<Widget> displayRest(BuildContext context) => [
        ...template.displayRest(infos.otherInfos, context),
        ...template.displayRest(selectedInstaller?.other, context),
      ];
}

class _InstallerCompartmentStub extends ExpanderCompartment {
  final InstallerInfos infos;

  const _InstallerCompartmentStub({required this.infos});

  @override
  List<Widget> buildCompartment(BuildContext context) {
    throw UnimplementedError();
  }

  @override
  String compartmentTitle(AppLocalizations locale) {
    return PackageAttribute.installer.title(locale);
  }

  @override
  final IconData titleIcon = FluentIcons.install_to_drive;

  @override
  bool get initiallyExpanded => false;
}
