import 'package:intl/locale.dart';
import 'package:winget_core/src/localization_name.dart';

import '../../package_localizer.dart';
import '../../version_or_string.dart';
import '../info.dart';
import '../package_attribute.dart';
import 'computer_architecture.dart';
import 'dependencies.dart';
import 'expected_return_code.dart';
import 'identifying_property.dart';
import 'install_mode.dart';
import 'install_scope.dart';
import 'installer_list_extension.dart';
import 'installer_locale.dart';
import 'installer_type.dart';
import 'upgrade_behavior.dart';
import 'windows_platform.dart';

typedef Property = Info<IdentifyingProperty>? Function(Installer);

class Installer {
  static final Info<ComputerArchitecture> fallbackArchitecture =
      Info<ComputerArchitecture>.fromAttribute(PackageAttribute.architecture,
          value: ComputerArchitecture.matchAll);

  final Info<ComputerArchitecture> architecture;
  final Info<Uri>? url;
  final Info<String>? sha256Hash;
  final Info<InstallerLocale>? locale;
  final Info<DateTime>? releaseDate;
  final Info<List<WindowsPlatform>>? platform;
  final Info<VersionOrString>? minimumOSVersion;
  final Info<InstallerType>? type;
  final Info<InstallScope>? scope;
  final Info<String>? signatureSha256;
  final Info<String>? elevationRequirement;
  final Info<String>? productCode;
  final Info<String>? appsAndFeaturesEntries;
  final Info<String>? switches;
  final Info<List<InstallMode>>? modes;
  final Info<UpgradeBehavior>? upgradeBehavior;
  final Info<List<String>>? fileExtensions;
  final Info<InstallerType>? nestedInstallerType;
  final Info<List<String>>? availableCommands;
  final Info<String>? storeProductID;
  final Info<String>? markets;
  final Info<String>? packageFamilyName;
  final Info<List<String>>? protocols;
  final Info<List<ExpectedReturnCode>>? expectedReturnCodes;
  final Info<Dependencies>? dependencies;
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
    this.releaseDate,
    this.fileExtensions,
    this.protocols,
    this.dependencies,
    this.successCodes,
    this.other = const {},
  });

  static final Map<PackageAttribute, Property> identifyingProperties = {
    PackageAttribute.architecture: (e) => e.architecture,
    PackageAttribute.installerType: (e) => e.type,
    PackageAttribute.installerLocale: (e) => e.locale,
    PackageAttribute.installScope: (e) => e.scope,
    PackageAttribute.nestedInstallerType: (e) => e.nestedInstallerType,
  };

  String uniqueProperties(List<Installer> installerList,
      PackageLocalizer localizer, LocalizationName? localeName,
      {bool longNames = false}) {
    List<String> preview = [];
    if (installerList.length >= 2) {
      Map<PackageAttribute, bool> isUnique =
          installerList.areIdentifyingPropertiesUnique();
      if (isUnique[PackageAttribute.architecture]!) {
        preview.add(architecture.value.title());
      }
      if (isUnique[PackageAttribute.installerType]!) {
        if (type != null) {
          InstallerType value = type!.value;
          preview.add(value.shortTitle());
        }
      }
      if (isUnique[PackageAttribute.installerLocale]!) {
        if (locale != null) {
          Locale value = locale!.value;
          preview.add(longNames
              ? localeName?.nameOf(value.toLanguageTag()) ??
                  value.toLanguageTag()
              : value.toLanguageTag());
        }
      }
      if (isUnique[PackageAttribute.installScope]!) {
        if (scope != null) {
          preview.add(scope!.value.title(localizer));
        }
      }
    }
    return preview.join(' ');
  }
}
