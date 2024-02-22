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
  final InstallerLocale matchAllLocale = InstallerLocale('<match all>');

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
    Locale? locale = AppLocale.of(context).guiLocale;

    Installer? installer = selectedInstaller;

    List<Info<String>?> details = [
      installer?.architecture.toStringInfo(),
      (installer?.type ?? infos.type)?.toStringInfo(),
      (installer?.locale ?? infos.locale)?.toStringInfo(context),
      infos.releaseDate?.toStringInfo(locale),
      (installer?.scope ?? infos.scope)?.toStringInfo(context),
      installer?.minimumOSVersion ?? infos.minimumOSVersion,
      (installer?.platform ?? infos.platform)?.toStringInfo(),
      selectedInstaller?.availableCommands?.toStringInfo(),
      (installer?.nestedInstallerType ?? infos.nestedInstallerType)
          ?.toStringInfo(),
      (installer?.upgradeBehavior ?? infos.upgradeBehavior)
          ?.toStringInfo(context),
      (installer?.modes ?? infos.installModes)?.toStringInfo(localization),
      installer?.storeProductID ?? infos.storeProductID,
      installer?.sha256Hash ?? infos.sha256Hash,
      installer?.elevationRequirement ?? infos.elevationRequirement,
      installer?.productCode ?? infos.productCode,
      infos.dependencies?.toStringInfo(),
      installer?.signatureSha256,
      installer?.markets,
      installer?.packageFamilyName,
      (installer?.expectedReturnCodes ?? infos.expectedReturnCodes)
          ?.toStringInfo(localization),
      (installer?.successCodes ?? infos.successCodes)
          ?.toStringInfoFromList((e) => e.toString()),
    ];

    Widget content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: template.fullCompartment(
            title: template.compartmentTitle(localization),
            mainColumn: [
              if (infos.installers != null) selectInstallerWidget(context),
              if (infos.installers != null &&
                  infos.installers!.value.length > 1)
                template.divider(),
              ...template.detailsList(details, context),
              ...template.displayRest(infos.otherInfos, context),
              ...template.displayRest(selectedInstaller?.other, context)
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

  InstallerInfos get infos => widget.infos;
  ExpanderCompartment get template => widget._template;

  Widget selectInstallerWidget(BuildContext context) {
    Iterable<Cluster> equivalenceClasses =
        infos.installers!.value.equivalenceClasses();
    print(equivalenceClasses);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    LocaleNames localeNames = LocaleNames.of(context)!;
    InstallerDifferences differences =
        InstallerDifferences.fromList(infos.installers!.value, context);
    bool hasAllPossibleCombinations =
        differences.possibleCombinations == infos.installers?.value.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (infos.installers != null && infos.installers!.value.length > 1)
          Text(
            localizations.multipleInstallersFound(
                infos.installers?.value.length ?? '<?>'),
          ),
        if (equivalenceClasses.isNotEmpty)
          Wrap(spacing: 10, runSpacing: 10, children: [
            for (Cluster cluster in equivalenceClasses)
              boxSelectInstaller<MultiProperty>(
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
                      setInstallerProperty(
                          cluster.attributes.toList()[i], value?.properties[i]);
                    }
                    selectedInstaller = fittingInstallers.firstOrNull;
                  });
                },
                matchAll: !hasAllPossibleCombinations
                    ? getMultiPropertyMatchAll(cluster)
                    : null,
              )
          ]),
        if (infos.installers!.value.length == 2)
          boxSelectInstaller<Installer>(
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
                  boxSelectInstaller<IdentifyingProperty?>(
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
                  ),
              if (infos.installers != null && fittingInstallers.length >= 2)
                boxSelectInstaller<Installer>(
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

  Widget boxSelectInstaller<T>(
      {required String categoryName,
      required List<T> options,
      required String Function(T) title,
      T? value,
      void Function(T?)? onChanged,
      T? matchAll}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (categoryName.isNotEmpty)
          Text(categoryName, style: FluentTheme.of(context).typography.caption),
        ComboBox<T>(
          items: [
            for (T item in options)
              ComboBoxItem(
                  value: item,
                  child: Text(title(item), overflow: TextOverflow.ellipsis)),
            if (matchAll != null)
              ComboBoxItem(
                  value: matchAll,
                  child:
                      Text(title(matchAll), overflow: TextOverflow.ellipsis)),
          ],
          value: value,
          onChanged: onChanged,
          placeholder: const Text('null'),
        ),
      ],
    );
  }

  List<Installer> get fittingInstallers {
    return infos.installers?.value
            .where((installer) =>
                (installer.architecture.value == installerArchitecture ||
                    installerArchitecture == ComputerArchitecture.matchAll) &&
                (installer.type?.value == installerType ||
                    installerType == InstallerType.matchAll) &&
                (installer.locale?.value == installerLocale ||
                    installerLocale == matchAllLocale) &&
                (installer.scope?.value == installerScope ||
                    installerScope == InstallScope.matchAll) &&
                (installer.nestedInstallerType?.value == nestedInstallerType ||
                    nestedInstallerType == InstallerType.matchAll))
            .toList() ??
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
        return matchAllLocale;
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
