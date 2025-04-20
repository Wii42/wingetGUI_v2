import 'package:intl/intl.dart';
import 'package:intl/locale.dart';
import 'package:winget_core/winget_core.dart';

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

  bool get isEmpty => value.isEmpty;

  bool get isNotEmpty => !isEmpty;
}

extension UriInfo on Info<Uri> {
  Info<String> toStringInfo() =>
      toStringInfoFromObject((object) => object.toString());

  bool get isEmpty => value.toString().isEmpty;

  bool get isNotEmpty => !isEmpty;
}

extension ListInfo<T> on Info<List<T>> {
  Info<String> toStringInfoFromList(String Function(T)? toString,
      {String separator = ', '}) {
    return toStringInfoFromObject((object) {
      List<dynamic> list = object
          .map((e) => toString != null ? toString(e) : e.toString())
          .toList();
      return list.join(separator);
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
  Info<String> toStringInfo(PackageLocalizer localizer) {
    return toStringInfoFromObject((object) => object.title(localizer));
  }
}

extension UpgradeBehaviorInfo on Info<UpgradeBehavior> {
  Info<String> toStringInfo(PackageLocalizer localizer) {
    return toStringInfoFromObject((object) => object.title(localizer));
  }
}

extension DateTimeInfo on Info<DateTime> {
  Info<String> toStringInfo([Locale? locale]) {
    DateFormat formatter = DateFormat.yMMMMd(locale.toString());
    return toStringInfoFromObject(formatter.format);
  }
}

extension InstallModeListModeInfo on Info<List<InstallMode>> {
  Info<String> toStringInfo(PackageLocalizer localizer) =>
      toStringInfoFromList((object) => object.title(localizer));
}

extension WindowsPlatformListModeInfo on Info<List<WindowsPlatform>> {
  Info<String> toStringInfo() => toStringInfoFromList((object) => object.title);
}

extension LocaleInfo on Info<Locale> {
  Info<String> toStringInfo(
      PackageLocalizer? localizer, LocalizationName? localeName) {
    return toStringInfoFromObject((locale) =>
        localeName?.nameOf(locale.toString()) ?? locale.toLanguageTag());
  }
}

extension InstallerLocaleInfo on Info<InstallerLocale> {
  Info<String> toStringInfo(
      PackageLocalizer? localizer, LocalizationName? localeName) {
    return toStringInfoFromObject(
        (locale) => locale.title(localizer, localeName));
  }
}

extension ExpectedReturnCodeModeInfo on Info<List<ExpectedReturnCode>> {
  Info<String> toStringInfo(PackageLocalizer localizer) => toStringInfoFromList(
      (object) =>
          "${object.returnCode}: ${object.response.title(localizer)}${object.returnResponseUrl != null ? ' (${object.returnResponseUrl})' : ''}",
      separator: '\n');
}

extension SourceInfo on Info<PackageSources> {
  Info<String> toStringInfo() {
    return toStringInfoFromObject((source) => source.title);
  }
}

extension VersionOrStringInfo on Info<VersionOrString> {
  Info<String> toStringInfo() {
    return toStringInfoFromObject((source) => source.stringValue);
  }
}

extension PackageIdInfo on Info<PackageId> {
  Info<String> toStringInfo() {
    return toStringInfoFromObject((source) => source.string);
  }
}
