import 'dart:ui';
import 'package:http/http.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:winget_gui/helpers/extensions/best_fitting_locale.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_full.dart';
import 'package:yaml/yaml.dart';
import 'package:winget_gui/helpers/locale_parser.dart';
import 'github_api/github_api.dart';
import 'github_api/github_api_file_info.dart';
import 'github_api/winget_packages/winget_package_version_manifest.dart';
import 'package_source.dart';

class WingetSource extends PackageSource {
  WingetSource(super.package);

  @override
  Future<PackageInfosFull> fetchInfos(Locale? guiLocale) async {
    if (package.hasCompleteId()) {
      return extractInfosOnlineFromId(guiLocale, package.id!.value);
    } else {
      String idWithoutEllipsis = package.idWithoutEllipsis()!;
      List<String> idParts = idWithoutEllipsis.split('.');
      if (idWithoutEllipsis.endsWith('.')) {
        idParts.add('');
      }
      List<String> soundParts = idParts.take(idParts.length - 1).toList();
      GithubApi api = GithubApi.wingetManifest(packageID: soundParts.join('.'));
      List<GithubApiFileInfo> files = await api.getFiles();
      if (files.isEmpty) {
        throw Exception('No files found');
      }
      List<GithubApiFileInfo> matchingFiles = files
          .where((element) => element.name.startsWith(idParts.last))
          .toList();
      if (matchingFiles.length != 1) {
        matchingFiles.removeWhere((element) => element.name == idParts.last);
        if (matchingFiles.length != 1) {
          List<GithubApiFileInfo> matchingFilesByName = matchingFiles
              .where((element) =>
                  package.name?.value
                      .replaceAll(' ', '')
                      .endsWith(element.name) ??
                  false)
              .toList();
          if (matchingFilesByName.length == 1) {
            matchingFiles = matchingFilesByName;
          } else {
            throw Exception(
                'Not  1 matching file found: ${matchingFiles.map((e) => e.name)}');
          }
        }
      }
      soundParts.add(matchingFiles.single.name);
      return extractInfosOnlineFromId(guiLocale, soundParts.join('.'));
    }
  }

  Future<PackageInfosFull> extractInfosOnlineFromId(
      Locale? guiLocale, String packageID) async {
    bool hasAnyVersion =
        package.hasSpecificVersion() || package.hasSpecificAvailableVersion();
    List<GithubApiFileInfo> files;
    if (hasAnyVersion) {
      GithubApi manifestApi = GithubApi.wingetVersionManifest(
          packageID: packageID,
          version: (package.hasSpecificAvailableVersion()
                  ? package.availableVersion?.value
                  : null) ??
              (package.hasSpecificVersion()
                  ? package.version?.value
                  : throw Exception('package has no specific version'))!);

      files = await manifestApi.getFiles(
          onError: () =>
              GithubApi.wingetManifest(packageID: packageID).getFiles());
    } else {
      GithubApi manifestApi = GithubApi.wingetManifest(packageID: packageID);

      files = await manifestApi.getFiles();
    }

    if (files.isEmpty) {
      throw Exception('No files found');
    }
    if (!WingetPackageVersionManifest.isVersionManifest(files,
        packageId: packageID)) {
      files = await tryGetNewestVersionManifest(files);
      //throw Exception('Files are not a version manifest');
    }

    WingetPackageVersionManifest manifest =
        WingetPackageVersionManifest.fromList(files, packageId: packageID);

    GithubApiFileInfo details;
    if (manifest.localizedFiles.length == 1) {
      details = manifest.localizedFiles.first;
    }
    Locale locale =
        await chooseLocale(guiLocale, manifest, packageID: packageID);
    details = manifest.localizedFiles.firstWhere((element) =>
        getLocaleFromName(element, packageID: packageID) == locale);
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
      Locale? guiLocale, WingetPackageVersionManifest manifest,
      {String? packageID}) async {
    List<GithubApiFileInfo> localizedFiles = manifest.localizedFiles;

    List<Locale> availableLocales = localizedFiles
        .map<Locale>((e) => getLocaleFromName(e, packageID: packageID))
        .toList();

    if (availableLocales.length == 1) {
      return availableLocales.single;
    }

    if (guiLocale != null) {
      Locale? bestFitting = guiLocale.bestFittingLocale(availableLocales);
      if (bestFitting != null) {
        return bestFitting;
      }
    }
    Locale? defaultLocale = await getDefaultLocale(manifest);
    return defaultLocale ?? availableLocales.first;
  }

  Locale getLocaleFromName(GithubApiFileInfo e, {String? packageID}) {
    String localeString = e.name
        .replaceFirst("${packageID ?? package.id!.value}.locale.", '')
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
    if(url.toString().contains('#')) {
      url = Uri.parse(url.toString().replaceAll('#', '%23'));
    }
    Response response = await get(url);
    if (response.statusCode == 200) {
      try {
        return loadYaml(response.body) as YamlMap;
      } on FormatException {
        String body = String.fromCharCodes(response.bodyBytes);
        return loadYaml(body) as YamlMap;
      }
    }
    log.error(
        'Failed to load file from Github API: ${response.statusCode}\n${response.reasonPhrase}\n${response.body}');

    return null;
  }

  Future<List<GithubApiFileInfo>> tryGetNewestVersionManifest(
      List<GithubApiFileInfo> files) {
    List<String> newestVersionManifestPath =
        tryGetNewestVersionManifestPath(files);
    GithubApi api = GithubApi.wingetRepo(newestVersionManifestPath);
    return api.getFiles();
  }

  List<String> tryGetNewestVersionManifestPath(List<GithubApiFileInfo> files) {
    List<GithubApiFileInfo> versionManifests =
        files.where((element) => isBuiltInVersion(element.name)).toList();
    if (versionManifests.isNotEmpty) {
      List<Version> versions =
          versionManifests.map<Version>((e) => Version.parse(e.name)).toList();
      Version newestVersion = Version.primary(versions);
      GithubApiFileInfo newestVersionManifest = versionManifests.firstWhere(
          (element) => Version.parse(element.name) == newestVersion);

      return newestVersionManifest.pathFragments;
    }
    versionManifests =
        files.where((element) => isFourPartVersion(element.name)).toList();
    if (versionManifests.isNotEmpty) {
      return versionManifests.last.pathFragments;
    }
    if (package.version != null) {
      List<GithubApiFileInfo> maybeCurrentVersionManifest = files
          .where((element) =>
              element.name.startsWith(package.versionWithoutEllipsis()!))
          .toList();
      if (maybeCurrentVersionManifest.isNotEmpty) {
        return maybeCurrentVersionManifest.last.pathFragments;
      }
    }
    if (files.length == 1) {
      return files.single.pathFragments;
    }
    throw Exception('No version manifest found: ${files.map((e) => e.name)}');
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
