import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:winget_gui/output_handling/package_infos/info_json_parser.dart';
import 'package:winget_gui/output_handling/package_infos/installer_objects/install_mode.dart';
import 'package:winget_gui/output_handling/package_infos/installer_objects/install_scope.dart';
import 'package:winget_gui/output_handling/package_infos/installer_objects/installer_list_extension.dart';
import 'package:winget_gui/output_handling/package_infos/installer_objects/upgrade_behavior.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../info.dart';
import '../info_yaml_parser.dart';
import '../package_attribute.dart';
import 'computer_architecture.dart';
import 'expected_return_code.dart';
import 'installer_type.dart';
import 'windows_platform.dart';

typedef Property = Info? Function(Installer);

class Installer {
  static final Info<ComputerArchitecture> fallbackArchitecture =
      Info<ComputerArchitecture>.fromAttribute(PackageAttribute.architecture,
          value: ComputerArchitecture.matchAll);

  final Info<ComputerArchitecture> architecture;
  final Info<Uri>? url;
  final Info<String>? sha256Hash;
  final Info<Locale>? locale;
  final Info<List<WindowsPlatform>>? platform;
  final Info<String>? minimumOSVersion;
  final Info<InstallerType>? type;
  final Info<InstallScope>? scope;
  final Info<String>? signatureSha256;
  final Info<String>? elevationRequirement;
  final Info<String>? productCode;
  final Info<String>? appsAndFeaturesEntries;
  final Info<String>? switches;
  final Info<List<InstallMode>>? modes;
  final Info<UpgradeBehavior>? upgradeBehavior;
  final Info<InstallerType>? nestedInstallerType;
  final Info<List<String>>? availableCommands;
  final Info<String>? storeProductID;
  final Info<String>? markets;
  final Info<String>? packageFamilyName;
  final Info<List<ExpectedReturnCode>>? expectedReturnCodes;
  final Info<List<int>>? successCodes;

  final Map<String, String> other;

  Installer({
    required this.architecture,
    required this.url,
    required this.sha256Hash,
    this.locale,
    this.platform,
    this.minimumOSVersion,
    this.type,
    this.scope,
    this.signatureSha256,
    this.elevationRequirement,
    this.productCode,
    this.appsAndFeaturesEntries,
    this.switches,
    this.modes,
    this.nestedInstallerType,
    this.upgradeBehavior,
    this.availableCommands,
    this.storeProductID,
    this.markets,
    this.packageFamilyName,
    this.expectedReturnCodes,
    this.successCodes,
    this.other = const {},
  });

  static final Map<PackageAttribute, Property> identifyingProperties = {
    PackageAttribute.architecture: (e) => e.architecture,
    PackageAttribute.installerType: (e) => e.type,
    PackageAttribute.installerLocale: (e) => e.locale,
    PackageAttribute.installScope: (e) => e.scope
  };

  static Installer fromYaml(Map installerMap) {
    Map<dynamic, dynamic> map =
        installerMap.map((key, value) => MapEntry(key, value));
    InfoYamlParser parser = InfoYamlParser(map: map);
    return Installer(
      architecture:
          parser.maybeArchitectureFromMap(PackageAttribute.architecture) ??
              fallbackArchitecture,
      url: parser.maybeLinkFromMap(PackageAttribute.installerURL),
      sha256Hash: parser.maybeStringFromMap(PackageAttribute.sha256Installer),
      locale: parser.maybeLocaleFromMap(PackageAttribute.installerLocale),
      platform: parser.maybePlatformFromMap(PackageAttribute.platform),
      minimumOSVersion:
          parser.maybeStringFromMap(PackageAttribute.minimumOSVersion),
      type: parser.maybeInstallerTypeFromMap(PackageAttribute.installerType),
      scope: parser.maybeScopeFromMap(PackageAttribute.installScope),
      signatureSha256:
          parser.maybeStringFromMap(PackageAttribute.signatureSha256),
      elevationRequirement:
          parser.maybeStringFromMap(PackageAttribute.elevationRequirement),
      productCode: parser.maybeStringFromMap(PackageAttribute.productCode),
      appsAndFeaturesEntries:
          parser.maybeStringFromMap(PackageAttribute.appsAndFeaturesEntries),
      switches: parser.maybeStringFromMap(PackageAttribute.installerSwitches),
      modes: parser.maybeInstallModesFromMap(PackageAttribute.installModes),
      nestedInstallerType: parser
          .maybeInstallerTypeFromMap(PackageAttribute.nestedInstallerType),
      upgradeBehavior:
          parser.maybeUpgradeBehaviorFromMap(PackageAttribute.upgradeBehavior),
      availableCommands:
          parser.maybeStringListFromMap(PackageAttribute.availableCommands),
      expectedReturnCodes: parser.maybeExpectedReturnCodesFromMap(
          PackageAttribute.expectedReturnCodes),
      successCodes: parser.maybeListFromMap(
          PackageAttribute.installerSuccessCodes,
          parser: (e) => int.parse(e.toString())),
      other: map.map<String, String>(
          (key, value) => MapEntry(key.toString(), value.toString())),
    );
  }

  static Installer fromJson(Map<String, dynamic> installerMap) {
    InfoJsonParser parser = InfoJsonParser(map: installerMap);
    return Installer(
      architecture:
          parser.maybeArchitectureFromMap(PackageAttribute.architecture) ??
              fallbackArchitecture,
      url: parser.maybeLinkFromMap(PackageAttribute.installerURL),
      sha256Hash: parser.maybeStringFromMap(PackageAttribute.sha256Installer),
      locale: parser.maybeLocaleFromMap(PackageAttribute.installerLocale),
      platform: parser.maybePlatformFromMap(PackageAttribute.platform),
      minimumOSVersion:
          parser.maybeStringFromMap(PackageAttribute.minimumOSVersion),
      type: parser.maybeInstallerTypeFromMap(PackageAttribute.installerType),
      scope: parser.maybeScopeFromMap(PackageAttribute.installScope),
      signatureSha256:
          parser.maybeStringFromMap(PackageAttribute.signatureSha256),
      elevationRequirement:
          parser.maybeStringFromMap(PackageAttribute.elevationRequirement),
      productCode: parser.maybeStringFromMap(PackageAttribute.productCode),
      appsAndFeaturesEntries:
          parser.maybeStringFromMap(PackageAttribute.appsAndFeaturesEntries),
      switches: parser.maybeStringFromMap(PackageAttribute.installerSwitches),
      modes: parser.maybeInstallModesFromMap(PackageAttribute.installModes),
      nestedInstallerType: parser
          .maybeInstallerTypeFromMap(PackageAttribute.nestedInstallerType),
      upgradeBehavior:
          parser.maybeUpgradeBehaviorFromMap(PackageAttribute.upgradeBehavior),
      availableCommands:
          parser.maybeStringListFromMap(PackageAttribute.availableCommands),
      storeProductID:
          parser.maybeStringFromMap(PackageAttribute.storeProductID),
      markets: parser.maybeStringFromMap(PackageAttribute.markets),
      packageFamilyName:
          parser.maybeStringFromMap(PackageAttribute.packageFamilyName),
      expectedReturnCodes: parser.maybeExpectedReturnCodesFromMap(
          PackageAttribute.expectedReturnCodes),
      successCodes: parser.maybeListFromMap(
          PackageAttribute.installerSuccessCodes,
          parser: (e) => int.parse(e.toString())),
      other: parser.getOtherInfos() ?? {},
    );
  }

  static Map<PackageAttribute, bool> areIdentifyingPropertiesUnique(
      List<Installer> installerList) {
    return identifyingProperties.map((key, value) {
      return MapEntry(key, !installerList.isFeatureEverywhereTheSame(value));
    });
  }

  String uniqueProperties(List<Installer> installerList, BuildContext context,
      {bool longNames = false}) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    List<String> preview = [];
    if (installerList.length >= 2) {
      Map<PackageAttribute, bool> isUnique =
          areIdentifyingPropertiesUnique(installerList);
      if (isUnique[PackageAttribute.architecture]!) {
        preview.add(architecture.value.title);
      }
      if (isUnique[PackageAttribute.installerType]!) {
        if (type != null) {
          InstallerType value = type!.value;
          preview.add(value.shortTitle);
        }
      }
      if (isUnique[PackageAttribute.installerLocale]!) {
        if (locale != null) {
          Locale value = locale!.value;
          preview.add(longNames
              ? LocaleNames.of(context)!.nameOf(value.toLanguageTag()) ??
                  value.toLanguageTag()
              : value.toLanguageTag());
        }
      }
      if (isUnique[PackageAttribute.installScope]!) {
        if (scope != null) {
          preview.add(scope!.value.title(localizations));
        }
      }
    }
    return preview.join(' ');
  }

  static String uniquePropertyNames(
      List<Installer> installerList, BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    Map<PackageAttribute, bool> uniqueProperties =
        areIdentifyingPropertiesUnique(installerList)
          ..removeWhere((key, value) => value == false);
    List<String> names =
        uniqueProperties.keys.map((e) => e.title(locale)).toList();

    return names.join(' / ');
  }

  static Iterable<List<PackageAttribute>> equivalenceClasses(List<Installer> installerList) {
    Map<ComputerArchitecture, List<Installer>> architectureClasses = {};
    for (Installer installer in installerList) {
      if (architectureClasses.containsKey(installer.architecture.value)) {
        architectureClasses[installer.architecture.value]!.add(installer);
      } else {
        architectureClasses[installer.architecture.value] = [installer];
      }
    }

    Map<InstallerType?, List<Installer>> typeClasses = {};
    for (Installer installer in installerList) {
      if (typeClasses.containsKey(installer.type?.value)) {
        typeClasses[installer.type?.value]!.add(installer);
      } else {
        typeClasses[installer.type?.value] = [installer];
      }
    }

    Map<Locale?, List<Installer>> localeClasses = {};
    for (Installer installer in installerList) {
      if (localeClasses.containsKey(installer.locale?.value)) {
        localeClasses[installer.locale?.value]!.add(installer);
      } else {
        localeClasses[installer.locale?.value] = [installer];
      }
    }

    Map<InstallScope?, List<Installer>> scopeClasses = {};
    for (Installer installer in installerList) {
      if (scopeClasses.containsKey(installer.scope?.value)) {
        scopeClasses[installer.scope?.value]!.add(installer);
      } else {
        scopeClasses[installer.scope?.value] = [installer];
      }
    }

    Map<PackageAttribute, Map> classes = {
      PackageAttribute.architecture: architectureClasses,
      PackageAttribute.installerType: typeClasses,
      PackageAttribute.installerLocale: localeClasses,
      PackageAttribute.installScope: scopeClasses
    };

    classes.removeWhere((key, value) => value.keys.length <= 1);


    List<List<MapEntry<PackageAttribute, Map>>> clusters = List.generate(
        classes.length,
        (i) => List.generate(1, (j) => classes.entries.toList()[i]));

    checkClusters(clusters);
    print('\n${clusters.map((e) => e.length)}');
    bool finished = false;
    while (!finished) {
      print('\n');
      cluster(clusters);
      finished = checkClusters(clusters);
      print('\n${clusters.map((e) => e.map((e) => e.key.name))}');
    }
    return clusters.map((e) => e.map((e) => e.key).toList());
  }

  static void cluster(List<List<MapEntry<PackageAttribute, Map>>> clusters) {
    DeepCollectionEquality eq = const DeepCollectionEquality();
    for (int i = 0; i < clusters.length; i++) {
      for (int j = 0; j < clusters.length; j++) {
        //print(eq.equals(clusters[i].first.values, clusters[j].first.values));
        if (i != j &&
            eq.equals(clusters[i].first.value.values,
                clusters[j].first.value.values)) {
          clusters[i].addAll(clusters[j]);
          clusters.removeAt(j);
          return;
        }
      }
    }
  }

  static bool checkClusters(
      List<List<MapEntry<PackageAttribute, Map>>> clusters) {
    DeepCollectionEquality eq = const DeepCollectionEquality();
    bool done = true;
    List<List<bool>> matrix2 = List.generate(
        clusters.length,
        (i) => List.generate(
            clusters.length,
            (j) => eq.equals(clusters[i].first.value.values,
                clusters[j].first.value.values)));
    for (int i = 0; i < clusters.length; i++) {
      for (int j = 0; j < clusters.length; j++) {
        if (i != j && matrix2[i][j] == true) {
          done = false;
        }
      }
    }
    print('\n${matrix2.join('\n')}');
    print('done: $done');
    return done;
  }
}
