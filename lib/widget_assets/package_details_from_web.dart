import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_full.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_peek.dart';
import 'package:winget_gui/output_handling/show/package_long_info.dart';
import 'package:winget_gui/widget_assets/pane_item_body.dart';
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
    if (!package.hasSpecificVersion() && package.availableVersion == null) {
      return putInfo('package has no specific version');
    }
    Locale? locale = AppLocale.of(context).guiLocale;
    return _buildFromWeb(locale);
  }

  Widget _buildFromWeb(Locale? locale) {
    return FutureBuilder<PackageInfosFull>(
      future: extractOnlineFullInfos(locale),
      builder:
          (BuildContext context, AsyncSnapshot<PackageInfosFull> snapshot) {
        if (snapshot.hasData) {
          return ListView(
            physics: const BouncingScrollPhysics(),
            children: [PackageLongInfo(snapshot.data!)],
          );
        }
        if (snapshot.hasError) {
          return Text(
              snapshot.error.toString() + snapshot.stackTrace.toString());
        }
        return const Center(child: ProgressRing());
      },
    );
  }

  Future<PackageInfosFull> extractOnlineFullInfos(Locale? guiLocale) async {
    GithubApi manifestApi = GithubApi.wingetManifest(
        packageID: package.id!.value,
        version: package.availableVersion?.value ??
            (package.hasSpecificVersion()
                ? package.version?.value
                : throw Exception('package has no specific version'))!);

    List<GithubApiFileInfo> files = await manifestApi.getFiles();

    if (files.isEmpty) {
      throw Exception('no files found');
    }
    if (!WingetPackageVersionManifest.isVersionManifest(files,
        packageId: package.id!.value)) {
      throw Exception('files are not a version manifest');
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
    Map<dynamic,dynamic>? installerMap = installerYaml?.map<dynamic, dynamic>((key, value) => MapEntry(key, value));
    installerMap?.remove('ManifestVersion');
    installerMap?.remove('ManifestType');
    installerMap?.remove('PackageIdentifier');
    installerMap?.remove('PackageVersion');

    return PackageInfosFull.fromYamlMap(
        details: detailsMap,
        installerDetails: installerMap);
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
        if (kDebugMode) {
          print('locale(s) found: $matchingLocales');
        }
        if (matchingLocales.length == 1) {
          return matchingLocales.single;
        }
        return matchingLocales.first;
        //TODO: check for country code
      } else {
        if (kDebugMode) {
          print('locale not found');
        }
      }
    }
    Locale? defaultLocale = await getDefaultLocale(manifest);
    if (kDebugMode) {
      print('default locale: $defaultLocale');
    }
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
      if (kDebugMode) {
        print(map);
      }
      return LocaleParser.tryParse(map['DefaultLocale']);
    }
    return null;
  }

  Future<YamlMap?> getYaml(Uri url) async {
    Response response = await get(url);
    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('file downloaded');
      }
      return loadYaml(response.body) as YamlMap;
    }
    if (kDebugMode) {
      print(
          'Failed to load file from Github API: ${response.statusCode} ${response.reasonPhrase} ${response.body}');
    }
    return null;
  }
}
