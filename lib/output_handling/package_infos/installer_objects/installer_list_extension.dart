import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:winget_gui/output_handling/package_infos/installer_objects/identifying_property.dart';

import '../../../helpers/log_stream.dart';
import '../info.dart';
import '../package_attribute.dart';
import 'computer_architecture.dart';
import 'install_scope.dart';
import 'installer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'installer_locale.dart';
import 'installer_type.dart';

typedef Feature = Info<IdentifyingProperty>? Function(Installer);

extension InstallerList on List<Installer> {
  List<Feature> minimalUniqueIdentifiers() {
    List<Feature> uniqueFeatures = [];
    for (Feature feature in Installer.identifyingProperties.values) {
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

  Iterable<Cluster> equivalenceClasses() {
    List<Partition<IdentifyingProperty>> classes = [];
    for (MapEntry<PackageAttribute, Property> entry
        in Installer.identifyingProperties.entries) {
      Map<IdentifyingProperty?, List<Installer>> classMap = {};
      for (Installer installer in this) {
        Info<IdentifyingProperty>? feature = entry.value(installer);
        if (classMap.containsKey(feature?.value)) {
          classMap[feature?.value]!.add(installer);
        } else {
          classMap[feature?.value] = [installer];
        }
      }
      classes.add(Partition(entry.key, classMap));
    }

    classes.removeWhere((e) => e.classes.length <= 1);

    List<Cluster> clusters =
        List.generate(classes.length, (i) => Cluster([classes[i]]));

    checkClusters(clusters);
    bool finished = false;
    while (!finished) {
      cluster(clusters);
      finished = checkClusters(clusters);
    }
    return clusters;
  }

  static void cluster(List<Cluster> clusters) {
    for (int i = 0; i < clusters.length; i++) {
      for (int j = 0; j < clusters.length; j++) {
        if (i != j && clusters[i].hasSamePartition(clusters[j])) {
          clusters[i].merge(clusters[j]);
          clusters.removeAt(j);
          return;
        }
      }
    }
  }

  static bool checkClusters(List<Cluster> clusters) {
    bool done = true;
    List<List<bool>> matrix2 = List.generate(
        clusters.length,
        (i) => List.generate(
            clusters.length, (j) => clusters[i].hasSamePartition(clusters[j])));
    for (int i = 0; i < clusters.length; i++) {
      for (int j = 0; j < clusters.length; j++) {
        if (i != j && matrix2[i][j] == true) {
          done = false;
        }
      }
    }
    return done;
  }

  List<Installer> fittingInstallers(ComputerArchitecture? installerArchitecture,
      InstallerType? installerType, InstallerLocale? installerLocale,
      InstallScope? installerScope, InstallerType? nestedInstallerType){
    return where((installer) =>
    (installer.architecture.value == installerArchitecture ||
    installerArchitecture == ComputerArchitecture.matchAll) &&
    (installer.type?.value == installerType ||
    installerType == InstallerType.matchAll) &&
    (installer.locale?.value == installerLocale ||
    installerLocale == InstallerLocale.matchAll) &&
    (installer.scope?.value == installerScope ||
    installerScope == InstallScope.matchAll) &&
    (installer.nestedInstallerType?.value == nestedInstallerType ||
    nestedInstallerType == InstallerType.matchAll))
        .toList();
  }
}

class Partition<T extends IdentifyingProperty> {
  late final Logger log;
  final PackageAttribute attribute;

  Map<T?, List<Installer>> classes;

  Partition(this.attribute, this.classes){
    log = Logger(this);
  }

  List<T?> properties() {
    return classes.keys.toList();
  }
}

class Cluster<T extends IdentifyingProperty> {
  late final Logger log;
  final List<Partition<T>> partitions;

  Cluster(this.partitions){
    log = Logger(this);
  }

  merge(Cluster<T> other) {
    partitions.addAll(other.partitions);
  }

  Iterable<List<Installer>> get installerPartition {
    return partitions.first.classes.values;
  }

  bool hasSamePartition(Cluster<T> other) {
    DeepCollectionEquality eq = const DeepCollectionEquality();
    return eq.equals(installerPartition, other.installerPartition);
  }

  Iterable<PackageAttribute> get attributes {
    return partitions.map((e) => e.attribute);
  }

  List<List<T?>> get optionsList {
    List<List<T?>> options = List.generate(
        partitions.first.properties().length,
        (i) => List.generate(
            partitions.length, (j) => partitions[j].properties()[i]));
    log.info("optionsList: $options");
    return options;
  }

  List<Map<PackageAttribute, T?>> get optionsMap {
    return optionsList.map((e) {
      Map<PackageAttribute, T?> map = {};
      for (int i = 0; i < partitions.length; i++) {
        map[partitions[i].attribute] = e[i];
      }
      return map;
    }).toList();
  }

  List<MultiProperty> get options =>
      optionsMap.map((e) => MultiProperty.fromMap(e)).toList();

  List<MultiProperty> getOptionsWith(MultiProperty property) {
    return List.from(options)..add(property);
  }
}

class MultiProperty {
  final ComputerArchitecture? architecture;
  final bool hasArchitecture;
  final InstallerType? type;
  final bool hasType;
  final InstallerLocale? locale;
  final bool hasLocale;
  final InstallScope? scope;
  final bool hasScope;
  final InstallerType? nestedInstaller;
  final bool hasNestedInstaller;
  MultiProperty({
    required this.architecture,
    required this.hasArchitecture,
    required this.type,
    required this.hasType,
    required this.locale,
    required this.hasLocale,
    required this.scope,
    required this.hasScope,
    required this.nestedInstaller,
    required this.hasNestedInstaller,
  });

  factory MultiProperty.fromMap(
      Map<PackageAttribute, IdentifyingProperty?> map) {
    return MultiProperty(
      architecture: map[PackageAttribute.architecture] as ComputerArchitecture?,
      hasArchitecture: map.containsKey(PackageAttribute.architecture),
      type: map[PackageAttribute.installerType] as InstallerType?,
      hasType: map.containsKey(PackageAttribute.installerType),
      locale: map[PackageAttribute.installerLocale] as InstallerLocale?,
      hasLocale: map.containsKey(PackageAttribute.installerLocale),
      scope: map[PackageAttribute.installScope] as InstallScope?,
      hasScope: map.containsKey(PackageAttribute.installScope),
      nestedInstaller:
          map[PackageAttribute.nestedInstallerType] as InstallerType?,
      hasNestedInstaller: map.containsKey(PackageAttribute.nestedInstallerType),
    );
  }

  List<IdentifyingProperty?> get properties {
    List<IdentifyingProperty?> properties = [];
    if (hasArchitecture) properties.add(architecture!);
    if (hasType) properties.add(type);
    if (hasLocale) properties.add(locale);
    if (hasScope) properties.add(scope);
    if (hasNestedInstaller) properties.add(nestedInstaller);
    return properties;
  }

  Map<PackageAttribute, IdentifyingProperty?> get asMap {
    return {
      if (hasArchitecture) PackageAttribute.architecture: architecture,
      if (hasType) PackageAttribute.installerType: type,
      if (hasLocale) PackageAttribute.installerLocale: locale,
      if (hasScope) PackageAttribute.installScope: scope,
      if (hasNestedInstaller) PackageAttribute.nestedInstallerType: nestedInstaller,
    };
  }

  @override
  bool operator ==(Object other) {
    if (other is MultiProperty) {
      return other.architecture == architecture &&
          other.type == type &&
          other.locale == locale &&
          other.scope == scope &&
          other.hasArchitecture == hasArchitecture &&
          other.hasType == hasType &&
          other.hasLocale == hasLocale &&
          other.hasScope == hasScope &&
          other.nestedInstaller == nestedInstaller &&
          other.hasNestedInstaller == hasNestedInstaller;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(
        architecture,
        type,
        locale,
        scope,
        hasArchitecture,
        hasType,
        hasLocale,
        hasScope,
        nestedInstaller,
        hasNestedInstaller,
      );

  String title(AppLocalizations localizations, LocaleNames localeNames) {
        String string = properties
        .map((e) => properties.length > 1
        ? e?.shortTitle(localizations)
        : e?.fullTitle(localizations, localeNames))
        .nonNulls
        .join(' ');
        if(string.isEmpty) return 'null';
        return string;
  }
}
