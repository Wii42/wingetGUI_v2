import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:intl/intl.dart';
import 'package:winget_gui/output_handling/package_infos/installer_objects/computer_architecture.dart';
import 'package:winget_gui/output_handling/package_infos/installer_objects/identifying_property.dart';
import 'package:winget_gui/output_handling/package_infos/installer_objects/installer_type.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/package_infos/installer_objects/windows_platform.dart';
import 'info.dart';
import 'installer_objects/dependencies.dart';
import 'installer_objects/expected_return_code.dart';
import 'installer_objects/install_mode.dart';
import 'installer_objects/install_scope.dart';
import 'installer_objects/installer_locale.dart';
import 'installer_objects/upgrade_behavior.dart';

extension StringInfo on Info<String> {
  Info<Uri>? tryToUriInfo() {
    Uri? url = Uri.tryParse(value);
    if (url == null) return null;
    return Info<Uri>(
        title: title,
        value: url,
        copyable: copyable,
        couldBeLink: true,
        customTitle: customTitle);
  }

  Info<T> copyAs<T extends Object>({required T Function(String) parser}) {
    return Info<T>(
        title: title,
        value: parser(value),
        copyable: copyable,
        couldBeLink: couldBeLink,
        customTitle: customTitle);
  }

  Info<String> onlyFirstLine() {
    String firstLine = value.split('\n').first;
    if (firstLine.contains('. ')) {
      firstLine = '${firstLine.split('. ').first}.';
    }
    return copyWith(value: firstLine);
  }
}

extension ListToStringInfo<T> on Info<List<T>> {
  Info<String> toStringInfoFromList(String Function(T)? toString) {
    return toStringInfoFromObject((object) {
      List<dynamic> list = object
          .map((e) => toString != null ? toString(e) : e.toString())
          .toList();
      return list.join(', ');
    });
  }
}

extension StringListModeInfo on Info<List<String>> {
  Info<String> toStringInfo() => toStringInfoFromList((object) => object);
}

extension DependenciesInfo on Info<Dependencies> {
  Info<String> toStringInfo() {
    return toStringInfoFromObject((dependencies) {
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
        String packageDependencies = dependencies.packageDependencies!
            .map<String>((e) =>
                '${e.packageID}${e.minimumVersion != null ? ' >=${e.minimumVersion}' : ''}')
            .join(', ');
        stringList.add('Package Dependencies: $packageDependencies');
      }
      if (dependencies.externalDependencies != null) {
        stringList.add(
            'External Dependencies: ${dependencies.externalDependencies!.join(', ')}');
      }
      return stringList.join('\n');
    });
  }
}

extension InstallerTypeInfo on Info<InstallerType> {
  Info<String> toStringInfo() =>
      toStringInfoFromObject((object) => object.fullTitle());
}

extension ComputerArchitectureInfo on Info<ComputerArchitecture> {
  Info<String> toStringInfo() =>
      toStringInfoFromObject((object) => object.title());
}

extension InstallScopeInfo on Info<InstallScope> {
  Info<String> toStringInfo(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return toStringInfoFromObject((object) => object.title(locale));
  }
}

extension UpgradeBehaviorInfo on Info<UpgradeBehavior> {
  Info<String> toStringInfo(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return toStringInfoFromObject((object) => object.title(locale));
  }
}

extension DateTimeInfo on Info<DateTime> {
  Info<String> toStringInfo([Locale? locale]) {
    DateFormat formatter = DateFormat.yMMMMd(locale.toString());
    return toStringInfoFromObject(formatter.format);
  }
}

extension InstallModeListModeInfo on Info<List<InstallMode>> {
  Info<String> toStringInfo(AppLocalizations locale) =>
      toStringInfoFromList((object) => object.title(locale));
}

extension WindowsPlatformListModeInfo on Info<List<WindowsPlatform>> {
  Info<String> toStringInfo() => toStringInfoFromList((object) => object.title);
}

extension LocaleInfo on Info<Locale> {
  Info<String> toStringInfo(BuildContext context) {
    LocaleNames? localeNames = LocaleNames.of(context);
    return toStringInfoFromObject((locale) =>
        localeNames?.nameOf(locale.toString()) ?? locale.toLanguageTag());
  }
}

extension InstallerLocaleInfo on Info<InstallerLocale> {
  Info<String> toStringInfo(BuildContext context) {
    LocaleNames? localeNames = LocaleNames.of(context);
    return toStringInfoFromObject(
        (locale) => locale.title(AppLocalizations.of(context), localeNames));
  }
}

extension ExpectedReturnCodeModeInfo on Info<List<ExpectedReturnCode>> {
  Info<String> toStringInfo(AppLocalizations locale) =>
      toStringInfoFromList((object) =>
          "${object.returnCode}: ${object.response.title(locale)}${object.returnResponseUrl != null ? ' (${object.returnResponseUrl})' : ''}");
}
