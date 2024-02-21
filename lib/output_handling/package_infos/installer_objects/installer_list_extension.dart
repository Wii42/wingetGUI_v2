import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/output_handling/package_infos/installer_objects/identifying_property.dart';

import '../info.dart';
import '../package_attribute.dart';
import 'computer_architecture.dart';
import 'install_scope.dart';
import 'installer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'installer_locale.dart';
import 'installer_type.dart';

typedef Feature = Info? Function(Installer);

extension InstallerList on List<Installer> {
  List<Feature> minimalUniqueIdentifiers() {
    List<Feature> uniqueFeatures = [];
    for (Info? Function(Installer) feature
        in Installer.identifyingProperties.values) {
      if (isFeatureEverywhereTheSame(feature)) continue;
      if (isFeatureUniqueIdentifier(feature)) {
        return [feature];
      }
    }
    return uniqueFeatures;
  }

  bool isFeatureUniqueIdentifier(Info? Function(Installer) feature) {
    List<dynamic> values = map<Info?>(feature).map((e) => e?.value).toList();
    return values.toSet().length == length;
  }

  bool isFeatureEverywhereTheSame(Info? Function(Installer) feature) {
    Iterable<dynamic> values = map<Info?>(feature).map((e) => e?.value);
    return values.toSet().length == 1;
  }

  String uniquePropertyNames(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    Map<PackageAttribute, bool> uniqueProperties =
        areIdentifyingPropertiesUnique()
          ..removeWhere((key, value) => value == false);
    List<String> names =
        uniqueProperties.keys.map((e) => e.title(locale)).toList();

    return names.join(' / ');
  }

  Map<PackageAttribute, bool> areIdentifyingPropertiesUnique() {
    return Installer.identifyingProperties.map((key, value) {
      return MapEntry(key, !isFeatureEverywhereTheSame(value));
    });
  }

  Iterable<List<PackageAttribute>> equivalenceClasses() {
    Map<ComputerArchitecture, List<Installer>> architectureClasses = {};
    for (Installer installer in this) {
      if (architectureClasses.containsKey(installer.architecture.value)) {
        architectureClasses[installer.architecture.value]!.add(installer);
      } else {
        architectureClasses[installer.architecture.value] = [installer];
      }
    }

    Map<InstallerType?, List<Installer>> typeClasses = {};
    for (Installer installer in this) {
      if (typeClasses.containsKey(installer.type?.value)) {
        typeClasses[installer.type?.value]!.add(installer);
      } else {
        typeClasses[installer.type?.value] = [installer];
      }
    }

    Map<InstallerLocale?, List<Installer>> localeClasses = {};
    for (Installer installer in this) {
      if (localeClasses.containsKey(installer.locale?.value)) {
        localeClasses[installer.locale?.value]!.add(installer);
      } else {
        localeClasses[installer.locale?.value] = [installer];
      }
    }

    Map<InstallScope?, List<Installer>> scopeClasses = {};
    for (Installer installer in this) {
      if (scopeClasses.containsKey(installer.scope?.value)) {
        scopeClasses[installer.scope?.value]!.add(installer);
      } else {
        scopeClasses[installer.scope?.value] = [installer];
      }
    }

    Map<PackageAttribute, Map<IdentifyingProperty?, List<Installer>>> classes =
        {
      PackageAttribute.architecture: architectureClasses,
      PackageAttribute.installerType: typeClasses,
      PackageAttribute.installerLocale: localeClasses,
      PackageAttribute.installScope: scopeClasses,
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
