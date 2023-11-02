import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_full.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_peek.dart';
import 'package:winget_gui/output_handling/show/package_long_info.dart';
import 'package:winget_gui/widget_assets/pane_item_body.dart';
import 'package:winget_gui/widget_assets/scroll_list_widget.dart';
import 'package:yaml/yaml.dart';

import '../github_api/github_api.dart';
import '../github_api/github_api_file_info.dart';
import '../github_api/winget_packages/winget_package_version_manifest.dart';
import '../helpers/locale_parser.dart';
import '../winget_commands.dart';
import 'app_locale.dart';

class PackageDetailsFromWeb extends StatelessWidget {
  final PackageInfosPeek package;
  final String? titleInput;
  const PackageDetailsFromWeb(
      {super.key, required this.package, this.titleInput});

  @override
  Widget build(BuildContext context) {
    AppLocalizations localization = AppLocalizations.of(context)!;
    return PaneItemBody(
      title: titleInput != null
          ? Winget.show.titleWithInput(titleInput!, localization: localization)
          : Winget.show.title(localization),
      child: body(context),
    );
  }

  Widget body(BuildContext context) {
    Widget putInfo(String text) => Center(
            child: InfoBar(
          title: Text(text),
          severity: InfoBarSeverity.error,
        ));
    if (package.manifestApi == null) {
      return putInfo('versionManifestPath is null');
    }
    if (!package.isWinget()) {
      return putInfo('package is not from Winget');
    }
    //if (!package.hasSpecificVersion() && !package.hasAvailableVersion()) {
    // return putInfo('package has no specific version');
    //}
    return _buildFromWeb(context);
  }

  Widget putInfo(String title, {String? content, bool isLong = false}) =>
      Center(
        child: InfoBar(
            title: Text(title),
            content: content != null ? Text(content) : null,
            severity: InfoBarSeverity.error,
            isLong: isLong),
      );

  Widget _buildFromWeb(BuildContext context) {
    Locale? locale = AppLocale.of(context).guiLocale;
    AppLocalizations localization = AppLocalizations.of(context)!;
    return FutureBuilder<PackageInfosFull>(
      future: extractOnlineFullInfos(locale),
      builder:
          (BuildContext context, AsyncSnapshot<PackageInfosFull> snapshot) {
        if (snapshot.hasData) {
          return ScrollListWidget(
            listElements: [PackageLongInfo(snapshot.data!)],
          );
        }
        if (snapshot.hasError) {
          Object? error = snapshot.error;
          if (error.toString().startsWith('Failed host lookup: ')) {
            return Center(
              child: putInfo(localization.cantLoadDetails,
                  content: '${localization.reason}: ${localization.noInternetConnection}', isLong: true),
            );
          }

          return Text('${error.runtimeType}: $error\n${snapshot.stackTrace}');
        }
        return const Center(
            child: ProgressRing(
          backgroundColor: Colors.transparent,
        ));
      },
    );
  }

  Future<PackageInfosFull> extractOnlineFullInfos(Locale? guiLocale) async {
    bool hasAnyVersion =
        package.hasSpecificVersion() || package.hasSpecificAvailableVersion();
    List<GithubApiFileInfo> files;
    if (hasAnyVersion) {
      GithubApi manifestApi = GithubApi.wingetVersionManifest(
          packageID: package.id!.value,
          version: (package.hasSpecificAvailableVersion()
                  ? package.availableVersion?.value
                  : null) ??
              (package.hasSpecificVersion()
                  ? package.version?.value
                  : throw Exception('package has no specific version'))!);

      files = await manifestApi.getFiles(
          onError: () => GithubApi.wingetManifest(packageID: package.id!.value)
              .getFiles());
    } else {
      GithubApi manifestApi =
          GithubApi.wingetManifest(packageID: package.id!.value);

      files = await manifestApi.getFiles();
    }

    if (files.isEmpty) {
      throw Exception('No files found');
    }
    if (!WingetPackageVersionManifest.isVersionManifest(files,
        packageId: package.id!.value)) {
      files = await tryGetNewestVersionManifest(files);
      //throw Exception('Files are not a version manifest');
    }

    WingetPackageVersionManifest manifest =
        WingetPackageVersionManifest.fromList(files,
            packageId: package.id!.value);

    GithubApiFileInfo details;
    if (manifest.localizedFiles.length == 1) {
      details = manifest.localizedFiles.first;
    }
    Locale locale = await chooseLocale(guiLocale, manifest);
    details = manifest.localizedFiles
        .firstWhere((element) => getLocaleFromName(element) == locale);
    YamlMap? detailsYaml = await getYaml(details.downloadUrl!);

    Map<dynamic, dynamic>? detailsMap = detailsYaml
        ?.map<dynamic, dynamic>((key, value) => MapEntry(key, value));
    detailsMap?.remove('ManifestVersion');
    detailsMap?.remove('ManifestType');

    YamlMap? installerYaml = await getYaml(manifest.installer.downloadUrl!);
    Map<dynamic, dynamic>? installerMap = installerYaml
        ?.map<dynamic, dynamic>((key, value) => MapEntry(key, value));
    installerMap?.remove('ManifestVersion');
    installerMap?.remove('ManifestType');
    installerMap?.remove('PackageIdentifier');
    installerMap?.remove('PackageVersion');

    return PackageInfosFull.fromYamlMap(
        details: detailsMap, installerDetails: installerMap);
  }

  Future<Locale> chooseLocale(
      Locale? guiLocale, WingetPackageVersionManifest manifest) async {
    List<GithubApiFileInfo> localizedFiles = manifest.localizedFiles;

    List<Locale> availableLocales =
        localizedFiles.map<Locale>(getLocaleFromName).toList();

    if (availableLocales.length == 1) {
      return availableLocales.single;
    }

    if (guiLocale != null) {
      List<Locale> matchingLocales = availableLocales
          .where((element) => element.languageCode == guiLocale.languageCode)
          .toList();
      if (matchingLocales.isNotEmpty) {
        if (matchingLocales.length == 1) {
          return matchingLocales.single;
        }
        return matchingLocales.first;
        //TODO: check for country code
      }
    }
    Locale? defaultLocale = await getDefaultLocale(manifest);
    return defaultLocale ?? availableLocales.first;
  }

  Locale getLocaleFromName(GithubApiFileInfo e) {
    String localeString = e.name
        .replaceFirst("${package.id!.value}.locale.", '')
        .split('.')
        .first;
    return LocaleParser.parse(localeString);
  }

  Future<Locale?> getDefaultLocale(
      WingetPackageVersionManifest manifest) async {
    Map? map = await getYaml(manifest.manifest.downloadUrl!);
    if (map != null) {
      return LocaleParser.tryParse(map['DefaultLocale']);
    }
    return null;
  }

  Future<YamlMap?> getYaml(Uri url) async {
    Response response = await get(url);
    if (response.statusCode == 200) {
      return loadYaml(response.body) as YamlMap;
    }
    if (kDebugMode) {
      print(
          'Failed to load file from Github API: ${response.statusCode}\n${response.reasonPhrase}\n${response.body}');
    }
    return null;
  }

  Future<List<GithubApiFileInfo>> tryGetNewestVersionManifest(
      List<GithubApiFileInfo> files) {
    List<GithubApiFileInfo> versionManifests =
        files.where((element) => isBuiltInVersion(element.name)).toList();
    if (versionManifests.isNotEmpty) {
      List<Version> versions =
          versionManifests.map<Version>((e) => Version.parse(e.name)).toList();
      Version newestVersion = Version.primary(versions);
      GithubApiFileInfo newestVersionManifest = versionManifests.firstWhere(
          (element) => Version.parse(element.name) == newestVersion);

      return GithubApi.wingetRepo(newestVersionManifest.path).getFiles();
    } else {
      versionManifests =
          files.where((element) => isFourPartVersion(element.name)).toList();
      if (versionManifests.isNotEmpty) {
        return GithubApi.wingetRepo(versionManifests.last.path).getFiles();
      }
    }
    throw Exception('No version manifest found');
  }

  bool isBuiltInVersion(String string) {
    try {
      Version.parse(string);
      return true;
    } catch (e) {
      return false;
    }
  }

  bool isFourPartVersion(String string) {
    RegExp versionRegex = RegExp(r'^\d+\.\d+\.\d+\.\d+$');
    return versionRegex.hasMatch(string);
  }
}
