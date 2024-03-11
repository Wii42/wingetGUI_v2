import 'dart:collection';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:winget_gui/helpers/extensions/best_fitting_locale.dart';
import 'package:winget_gui/helpers/extensions/string_extension.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_full.dart';
import 'package:yaml/yaml.dart';
import 'package:winget_gui/helpers/locale_parser.dart';
import '../helpers/version.dart';
import 'github_api/github_api.dart';
import 'github_api/github_api_file_info.dart';
import 'github_api/winget_packages/winget_package_version_manifest.dart';
import 'package_source.dart';

class WingetSource extends PackageSource {
  WingetSource(super.package);

  @override
  Future<PackageInfosFull> fetchInfos(Locale? guiLocale) async {
    String packageID =
        package.hasCompleteId() ? package.id!.value : await reconstructFullId();
    return extractInfosOnlineFromId(guiLocale, packageID);
  }

  Future<String> reconstructFullId() async {
    String idWithoutEllipsis = package.idWithoutEllipsis()!;
    List<String> idParts = idWithoutEllipsis.split('.');
    if (idParts.last.isEmpty) {
      idParts.removeLast();
    }
    bool endsWithPoint = idWithoutEllipsis.endsWith('.');
    int soundPartsLength = endsWithPoint ? idParts.length : idParts.length - 1;
    List<String> soundParts = idParts.take(soundPartsLength).toList();
    String lastPart = endsWithPoint ? '' : idParts.last;

    GithubApiFileInfo matchingFiles = await guessIdPartsBasedOnRepo(
        soundIdPart: soundParts.join('.'), lastKnownPart: lastPart);
    soundParts.add(matchingFiles.name);
    return soundParts.join('.');
  }

  /// Tries to guess the last part of the package ID
  /// based on the files and directories in the winget-pkgs repository
  Future<GithubApiFileInfo> guessIdPartsBasedOnRepo(
      {required String soundIdPart, required String lastKnownPart}) async {
    GithubApi api = GithubApi.wingetManifest(packageID: soundIdPart);
    List<GithubApiFileInfo> files = await api.getFiles();
    if (files.isEmpty) {
      throw Exception('No files found in ${api.apiUri}');
    }
    List<GithubApiFileInfo> matchingFiles =
        findBestMatchingFiles(files, lastKnownPart);
    if (matchingFiles.length != 1) {
      throw Exception(
          'Found ${matchingFiles.length} matching files, expected 1: ${matchingFiles.map((e) => e.name)} in ${api.apiUri}');
    }
    return matchingFiles.single;
  }

  List<GithubApiFileInfo> findBestMatchingFiles(
      List<GithubApiFileInfo> files, String lastKnownPart) {
    List<GithubApiFileInfo> matchingFiles = List.from(files);

    Queue<bool Function(GithubApiFileInfo)> matchCriteria = Queue.from(
      [
        (GithubApiFileInfo element) => element.name.startsWith(lastKnownPart),
        (GithubApiFileInfo element) => element.name != lastKnownPart,
        (GithubApiFileInfo element) =>
            package.name?.value.replaceAll(' ', '').endsWith(element.name) ??
            false
      ],
    );
    List<GithubApiFileInfo> previousMatchingFiles = List.from(matchingFiles);
    while (matchCriteria.isNotEmpty && matchingFiles.length > 1) {
      previousMatchingFiles = List.from(matchingFiles);
      bool Function(GithubApiFileInfo) matchCriterion =
          matchCriteria.removeFirst();
      matchingFiles = matchingFiles.where(matchCriterion).toList();
    }
    matchingFiles =
        matchingFiles.isNotEmpty ? matchingFiles : previousMatchingFiles;

    if (matchingFiles.length > 1) {
      matchingFiles = findNameMatch(matchingFiles);
    }
    return matchingFiles;
  }

  List<GithubApiFileInfo> findNameMatch(List<GithubApiFileInfo> matchingFiles) {
    String? packageName = package.name?.value;
    if (packageName != null) {
      List<GithubApiFileInfo> nameMatchingFiles = List.from(matchingFiles);
      int matchLength = 0;
      while (nameMatchingFiles.length > 1) {
        matchLength++;
        nameMatchingFiles = matchingFiles
            .where((element) =>
                packageName.contains(element.name.take(matchLength)))
            .toList();
      }
      if (nameMatchingFiles.isNotEmpty) {
        matchingFiles = nameMatchingFiles;
      }
    }
    return matchingFiles;
  }

  Future<PackageInfosFull> extractInfosOnlineFromId(
      Locale? guiLocale, String packageID) async {
    List<GithubApiFileInfo> files = await getFiles(packageID);
    if (!WingetPackageVersionManifest.isVersionManifest(files,
        packageId: packageID)) {
      files = await tryGetNewestVersionManifest(files);
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

    Map<dynamic, dynamic>? detailsMap = await getMap(details.downloadUrl,
        keysToRemove: ['ManifestVersion', 'ManifestType']);
    Map<dynamic, dynamic>? installerMap = await getMap(
      manifest.installer.downloadUrl,
      keysToRemove: [
        'ManifestVersion',
        'ManifestType',
        'PackageIdentifier',
        'PackageVersion',
      ],
    );

    return PackageInfosFull.fromYamlMap(
        details: detailsMap, installerDetails: installerMap, source: 'winget');
  }

  Future<List<GithubApiFileInfo>> getFiles(String packageID) async {
    bool hasAnyVersion =
        package.hasSpecificVersion() || package.hasSpecificAvailableVersion();
    fallBackFiles() =>
        GithubApi.wingetManifest(packageID: packageID).getFiles();
    List<GithubApiFileInfo> files;
    if (hasAnyVersion) {
      GithubApi manifestApi = GithubApi.wingetVersionManifest(
          packageID: packageID,
          version: (package.hasSpecificAvailableVersion()
                  ? package.availableVersion?.value.stringValue
                  : null) ??
              (package.hasSpecificVersion()
                  ? package.version?.value.stringValue
                  : throw Exception('package has no specific version'))!);
      files = await manifestApi.getFiles(onError: fallBackFiles);
    } else {
      files = await fallBackFiles();
    }
    if (files.isEmpty) {
      throw Exception('No files found');
    }
    return files;
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
    if (url.toString().contains('#')) {
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

  Future<Map<dynamic, dynamic>?> getMap(Uri? url,
      {List<String> keysToRemove = const []}) async {
    if (url == null) {
      return null;
    }
    YamlMap? yaml = await getYaml(url);

    Map<dynamic, dynamic>? map =
        yaml?.map<dynamic, dynamic>((key, value) => MapEntry(key, value));
    for (var element in keysToRemove) {
      map?.remove(element);
    }

    return map;
  }

  Future<List<GithubApiFileInfo>> tryGetNewestVersionManifest(
      List<GithubApiFileInfo> files) {
    List<String> newestVersionManifestPath =
        tryGetNewestVersionManifestPath(files);
    GithubApi api = GithubApi.wingetRepo(newestVersionManifestPath);
    return api.getFiles();
  }

  List<String> tryGetNewestVersionManifestPath(List<GithubApiFileInfo> files) {
    List<GithubApiFileInfo> versionManifests = files
        .where((element) => Version.tryParse(element.name) != null)
        .toList();
    if (versionManifests.isNotEmpty) {
      List<Version> versions =
          versionManifests.map<Version>((e) => Version.parse(e.name)).toList();
      Version? newestVersion = Version.primary(versions);
      GithubApiFileInfo newestVersionManifest = versionManifests.firstWhere(
          (element) => Version.parse(element.name) == newestVersion);

      return newestVersionManifest.pathFragments;
    }
    if (package.version != null) {
      List<GithubApiFileInfo> maybeCurrentVersionManifest = files
          .where((element) =>
              element.name.startsWith(package.versionWithoutEllipsis()!))
          .toList();
      if (maybeCurrentVersionManifest.isNotEmpty) {
        List<Version> versions = maybeCurrentVersionManifest
            .map<Version?>((e) => Version.tryParse(e.name))
            .nonNulls
            .toList();
        Version? primaryVersion = Version.primary(versions);
        GithubApiFileInfo? primaryFile =
            maybeCurrentVersionManifest.firstWhereOrNull(
                (element) => element.name == primaryVersion.toString());
        return (primaryFile ?? maybeCurrentVersionManifest.last).pathFragments;
      }
    }
    if (files.length == 1) {
      return files.single.pathFragments;
    }
    throw Exception('No version manifest found: ${files.map((e) => e.name)}');
  }
}
