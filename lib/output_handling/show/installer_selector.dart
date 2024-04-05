import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';

import 'package:winget_gui/package_infos/installer_objects/computer_architecture.dart';
import 'package:winget_gui/package_infos/installer_objects/identifying_property.dart';
import 'package:winget_gui/package_infos/installer_objects/install_scope.dart';
import 'package:winget_gui/package_infos/installer_objects/installer.dart';
import 'package:winget_gui/package_infos/installer_objects/installer_list_extension.dart';
import 'package:winget_gui/package_infos/installer_objects/installer_locale.dart';
import 'package:winget_gui/package_infos/installer_objects/installer_type.dart';
import 'package:winget_gui/package_infos/package_attribute.dart';
import 'box_select_installer.dart';

class InstallerSelector extends StatelessWidget {
  final Iterable<Installer> installers;
  final ComputerArchitecture? installerArchitecture;
  final InstallerType? installerType;
  final InstallerLocale? installerLocale;
  final InstallScope? installerScope;
  final InstallerType? nestedInstallerType;
  final void Function(Installer?) setSelectedInstaller;
  final void Function(
      {required PackageAttribute attribute,
      required IdentifyingProperty? value}) setInstallerProperty;

  final Installer? selectedInstaller;
  const InstallerSelector({
    super.key,
    required this.installers,
    required this.installerArchitecture,
    required this.installerType,
    required this.installerLocale,
    required this.installerScope,
    required this.nestedInstallerType,
    required this.setSelectedInstaller,
    required this.setInstallerProperty,
    required this.selectedInstaller,
  });

  @override
  Widget build(BuildContext context) {
    Iterable<Cluster> equivalenceClasses = installers.equivalenceClasses();
    AppLocalizations localizations = AppLocalizations.of(context)!;
    LocaleNames localeNames = LocaleNames.of(context)!;
    bool hasAllPossibleClusterCombinations =
        equivalenceClasses.possibleCombinations == installers.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (installers.length > 1)
          Text(
            localizations.multipleInstallersFound(installers.length),
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
                    for (int i = 0; i < cluster.attributes.length; i++) {
                      setInstallerProperty(
                          attribute: cluster.attributes.toList()[i],
                          value: value?.properties[i]);
                    }
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
        if (fittingInstallers.length > 1)
          BoxSelectInstaller<Installer>(
            categoryName: localizations
                .multipleFittingInstallersFound(fittingInstallers.length),
            options: fittingInstallers,
            title: (item) => item.uniqueProperties(fittingInstallers, context),
            value: selectedInstaller,
            onChanged: setSelectedInstaller,
          ),
        if (fittingInstallers.isEmpty)
          Text(
            localizations.noInstallerFound,
            style: TextStyle(color: Colors.red),
          ),
      ].withSpaceBetween(height: 20),
    );
  }

  MultiProperty? getMultiPropertyValue(Cluster<IdentifyingProperty> cluster) {
    List<MultiProperty> options = cluster.getOptionsWith(
      getMultiPropertyMatchAll(cluster),
    );
    return options.firstWhereOrNull((element) {
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

  List<Installer> getFittingInstallersWith(Map<PackageAttribute, dynamic> map) {
    return installers.fittingInstallers(
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
          : nestedInstallerType,
    );
  }

  List<Installer> get fittingInstallers {
    return installers.fittingInstallers(
      installerArchitecture,
      installerType,
      installerLocale,
      installerScope,
      nestedInstallerType,
    );
  }
}
