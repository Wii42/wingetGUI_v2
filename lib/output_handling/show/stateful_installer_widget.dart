import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:winget_gui/helpers/extensions/app_localizations_extension.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/package_infos/installer_infos.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/package_infos/installer_objects/installer_list_extension.dart';
import 'package:winget_gui/output_handling/package_infos/to_string_info_extensions.dart';
import 'package:winget_gui/output_handling/package_infos/installer_objects/identifying_property.dart';

import '../../widget_assets/app_locale.dart';
import '../package_infos/info.dart';
import '../package_infos/installer_objects/computer_architecture.dart';
import '../package_infos/installer_objects/install_scope.dart';
import '../package_infos/installer_objects/installer.dart';
import '../package_infos/installer_objects/installer_locale.dart';
import '../package_infos/installer_objects/installer_type.dart';
import '../package_infos/package_attribute.dart';
import 'box_select_installer.dart';
import 'compartments/expander_compartment.dart';
import 'installer_differences.dart';
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
              if (multipleInstallers) selectInstallerWidget(context),
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

  Widget selectInstallerWidget(BuildContext context) {
    Iterable<Cluster> equivalenceClasses =
        infos.installers!.value.equivalenceClasses();
    AppLocalizations localizations = AppLocalizations.of(context)!;
    LocaleNames localeNames = LocaleNames.of(context)!;
    InstallerDifferences differences =
        InstallerDifferences.fromList(infos.installers!.value, context);
    bool hasAllPossibleCombinations =
        differences.possibleCombinations == infos.installers?.value.length;
    bool hasAllPossibleClusterCombinations =
        equivalenceClasses.possibleCombinations ==
            infos.installers?.value.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (infos.installers != null && infos.installers!.value.length > 1)
          Text(
            localizations.multipleInstallersFound(
                infos.installers?.value.length ?? '<?>'),
          ),
        if (equivalenceClasses.isNotEmpty)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (Cluster cluster in equivalenceClasses)
                BoxSelectInstaller<MultiProperty>(
                  categoryName: cluster.attributes
                      .map((e) => e.title(localizations))
                      .nonNulls
                      .join(' / '),
                  options: cluster.options,
                  title: (item) => item.title(localizations, localeNames),
                  value: getMultiPropertyValue(cluster),
                  onChanged: (value) {
                    setState(() {
                      for (int i = 0; i < cluster.attributes.length; i++) {
                        setInstallerProperty(cluster.attributes.toList()[i],
                            value?.properties[i]);
                      }
                      selectedInstaller = fittingInstallers.firstOrNull;
                    });
                  },
                  matchAll: !hasAllPossibleClusterCombinations &&
                          equivalenceClasses.length > 1
                      ? getMultiPropertyMatchAll(cluster)
                      : null,
                  greyOutItem: (value) {
                    if (value == null) {
                      return true;
                    }
                    return getFittingInstallersWith(value.asMap).isEmpty;
                  },
                ),
            ],
          ),
        if (infos.installers != null && fittingInstallers.length >= 2)
          BoxSelectInstaller<Installer>(
              categoryName: localizations.multipleFittingInstallersFound(
                  fittingInstallers.length),
              options: fittingInstallers,
              title: (item) =>
                  item.uniqueProperties(fittingInstallers, context),
              value: selectedInstaller,
              onChanged: (value) {
                setState(() => selectedInstaller = value);
              }),
        if (infos.installers != null && fittingInstallers.isEmpty)
          Text(
            localizations.noInstallerFound,
            style: TextStyle(color: Colors.red),
          ),
        if (infos.installers!.value.length == 2)
          BoxSelectInstaller<Installer>(
              categoryName:
                  infos.installers!.value.uniquePropertyNames(context),
              options: infos.installers!.value,
              title: (item) => item.uniqueProperties(
                  infos.installers!.value, context,
                  longNames: true),
              value: selectedInstaller,
              onChanged: (value) {
                setState(() => selectedInstaller = value);
              })
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (MapEntry<PackageAttribute, Property> e
                  in Installer.identifyingProperties.entries)
                if (differences.asMap[e.key]!.length > 1)
                  BoxSelectInstaller<IdentifyingProperty?>(
                    categoryName: e.key.title(localizations),
                    options: differences.asMap[e.key]!,
                    title: (item) =>
                        item?.fullTitle(localizations, localeNames) ?? 'null',
                    value: getInstallerProperty(e.key),
                    onChanged: (value) {
                      setState(
                        () {
                          setInstallerProperty(e.key, value);
                          selectedInstaller = fittingInstallers.firstOrNull;
                        },
                      );
                    },
                    matchAll:
                        !hasAllPossibleCombinations ? getMatchAll(e.key) : null,
                    greyOutItem: (value) {
                      if (value == null) {
                        return true;
                      }
                      return getFittingInstallersWith({e.key: value}).isEmpty;
                    },
                  ),
              if (infos.installers != null && fittingInstallers.length >= 2)
                BoxSelectInstaller<Installer>(
                    categoryName: localizations.multipleFittingInstallersFound(
                        fittingInstallers.length),
                    options: fittingInstallers,
                    title: (item) =>
                        item.uniqueProperties(fittingInstallers, context),
                    value: selectedInstaller,
                    onChanged: (value) {
                      setState(() => selectedInstaller = value);
                    }),
              if (infos.installers != null && fittingInstallers.isEmpty)
                Text(
                  localizations.noInstallerFound,
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
      ].withSpaceBetween(height: 20),
    );
  }

  MultiProperty? getMultiPropertyValue(Cluster<IdentifyingProperty> cluster) {
    return cluster
        .getOptionsWith(getMultiPropertyMatchAll(cluster))
        .firstWhereOrNull((element) {
      if (element.hasArchitecture) {
        if (element.architecture != installerArchitecture) {
          return false;
        }
      }
      if (element.hasType) {
        if (element.type != installerType) {
          return false;
        }
      }
      if (element.hasLocale) {
        if (element.locale != installerLocale) {
          return false;
        }
      }
      if (element.hasScope) {
        if (element.scope != installerScope) {
          return false;
        }
      }
      if (element.hasNestedInstaller) {
        if (element.nestedInstaller != nestedInstallerType) {
          return false;
        }
      }
      return true;
    });
  }

  List<Installer> get fittingInstallers {
    return infos.installers?.value.fittingInstallers(
            installerArchitecture,
            installerType,
            installerLocale,
            installerScope,
            nestedInstallerType) ??
        [];
  }

  List<Installer> getFittingInstallersWith(Map<PackageAttribute, dynamic> map) {
    return infos.installers?.value.fittingInstallers(
            map.containsKey(PackageAttribute.architecture)
                ? map[PackageAttribute.architecture]
                : installerArchitecture,
            map.containsKey(PackageAttribute.installerType)
                ? map[PackageAttribute.installerType]
                : installerType,
            map.containsKey(PackageAttribute.installerLocale)
                ? map[PackageAttribute.installerLocale]
                : installerLocale,
            map.containsKey(PackageAttribute.installScope)
                ? map[PackageAttribute.installScope]
                : installerScope,
            map.containsKey(PackageAttribute.nestedInstallerType)
                ? map[PackageAttribute.nestedInstallerType]
                : nestedInstallerType) ??
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

  void setInstallerProperty(PackageAttribute attribute, dynamic value) {
    switch (attribute) {
      case PackageAttribute.architecture:
        installerArchitecture = value;
        break;
      case PackageAttribute.installerType:
        installerType = value;
        break;
      case PackageAttribute.installerLocale:
        installerLocale = value;
        break;
      case PackageAttribute.installScope:
        installerScope = value;
        break;
      case PackageAttribute.nestedInstallerType:
        nestedInstallerType = value;
        break;
      default:
        throw ArgumentError('Unknown attribute: $attribute');
    }
  }

  IdentifyingProperty? getInstallerProperty(PackageAttribute attribute) {
    switch (attribute) {
      case PackageAttribute.architecture:
        return installerArchitecture;
      case PackageAttribute.installerType:
        return installerType;
      case PackageAttribute.installerLocale:
        return installerLocale;
      case PackageAttribute.installScope:
        return installerScope;
      case PackageAttribute.nestedInstallerType:
        return nestedInstallerType;
      default:
        throw ArgumentError('Unknown attribute: $attribute');
    }
  }

  IdentifyingProperty getMatchAll(PackageAttribute attribute) {
    switch (attribute) {
      case PackageAttribute.architecture:
        return ComputerArchitecture.matchAll;
      case PackageAttribute.installerType:
        return InstallerType.matchAll;
      case PackageAttribute.installerLocale:
        return InstallerLocale.matchAll;
      case PackageAttribute.installScope:
        return InstallScope.matchAll;
      case PackageAttribute.nestedInstallerType:
        return InstallerType.matchAll;
      default:
        throw ArgumentError('Unknown attribute: $attribute');
    }
  }

  MultiProperty getMultiPropertyMatchAll(Cluster cluster) {
    Map<PackageAttribute, IdentifyingProperty?> map = Map.fromEntries(
        cluster.attributes.map((e) => MapEntry(e, getMatchAll(e))));
    return MultiProperty.fromMap(map);
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
