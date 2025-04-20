import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:intl/locale.dart' as intl;
import 'package:winget_core/winget_core.dart';
import 'package:winget_gui/global_app_data.dart';
import 'package:winget_gui/helpers/app_localizer.dart';
import 'package:winget_gui/helpers/extensions/app_localizations_extension.dart';
import 'package:winget_gui/helpers/extensions/best_fitting_locale.dart';
import 'package:winget_gui/helpers/localized_name.dart';
import 'package:winget_gui/l10n/generated/app_localizations.dart';

import 'expander_compartment.dart';
import 'installer_selector.dart';

class StatefulInstallerWidget extends StatefulWidget {
  late final _InstallerCompartmentStub _template;
  final Info<List<Installer>> infos;
  final intl.Locale? guiLocale, defaultLocale;

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

    bool multipleInstallers = installers.length > 1;
    Widget content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: template.fullCompartment(
            title: template.compartmentTitle(localization),
            mainColumn: [
              if (multipleInstallers)
                InstallerSelector(
                  installers: installers,
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
              selectedInstaller?.url?.copyWith(
                  customTitle: localization.downloadInstallerManually(
                      selectedInstaller?.uniqueProperties(
                          installers,
                          localization.asLocalizer,
                          LocaleNames.of(context)?.asLocalizedName)))
            ], context),
            context: context));
    return widget._template.buildWithoutContent(context, content);
  }

  List<Info<String>?> shownDetails(BuildContext context) {
    AppLocalizer localizer = AppLocalizations.of(context)!.asLocalizer;
    LocalizedName? localeName = LocaleNames.of(context)?.asLocalizedName;
    intl.Locale? locale = AppLocales.of(context).guiLocale?.asIntlLocale;
    return [
      selectedInstaller?.architecture.toStringInfo(),
      selectedInstaller?.type?.toStringInfo(),
      selectedInstaller?.locale?.toStringInfo(localizer, localeName),
      selectedInstaller?.releaseDate?.toStringInfo(locale),
      selectedInstaller?.scope?.toStringInfo(localizer),
      selectedInstaller?.minimumOSVersion?.toStringInfo(),
      selectedInstaller?.platform?.toStringInfo(),
      selectedInstaller?.nestedInstallerType?.toStringInfo(),
      selectedInstaller?.upgradeBehavior?.toStringInfo(localizer),
      selectedInstaller?.modes?.toStringInfo(localizer),
      selectedInstaller?.storeProductID,
      selectedInstaller?.sha256Hash,
      selectedInstaller?.elevationRequirement,
      selectedInstaller?.productCode,
      selectedInstaller?.dependencies?.toStringInfo(),
      selectedInstaller?.signatureSha256,
      selectedInstaller?.markets,
      selectedInstaller?.packageFamilyName,
      selectedInstaller?.expectedReturnCodes?.toStringInfo(localizer),
      selectedInstaller?.successCodes
          ?.toStringInfoFromList((e) => e.toString()),
    ];
  }

  List<Installer> get installers => widget.infos.value;

  ExpanderCompartment get template => widget._template;

  List<Installer> get fittingInstallers {
    return installers.fittingInstallers(
      installerArchitecture,
      installerType,
      installerLocale,
      installerScope,
      nestedInstallerType,
    );
  }

  Installer? getBestFittingLocaleInstaller() {
    if (widget.guiLocale != null) {
      List<intl.Locale> installerLocales =
          installers.map((e) => e.locale?.value).nonNulls.toList();
      if (installerLocales.length <= 1) {
        return installers.firstOrNull;
      }
      intl.Locale? bestFitting = getBestFittingLocale(installerLocales);
      if (bestFitting != null) {
        return installers
            .firstWhereOrNull((e) => e.locale?.value == bestFitting);
      }
    }
    return installers.firstOrNull;
  }

  intl.Locale? getBestFittingLocale(List<intl.Locale> installerLocales) {
    if (widget.guiLocale != null) {
      intl.Locale? bestFitting =
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
        ...template.displayRest(selectedInstaller?.other, context),
      ];
}

class _InstallerCompartmentStub extends ExpanderCompartment {
  final Info<List<Installer>> infos;

  const _InstallerCompartmentStub({required this.infos});

  @override
  List<Widget> buildCompartment(BuildContext context) {
    throw UnimplementedError();
  }

  @override
  String compartmentTitle(AppLocalizations locale) {
    return PackageAttribute.installer.title(locale.asLocalizer);
  }

  @override
  final IconData titleIcon = FluentIcons.install_to_drive;

  @override
  bool get initiallyExpanded => false;
}
