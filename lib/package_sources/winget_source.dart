import 'dart:collection';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:winget_gui/helpers/extensions/best_fitting_locale.dart';
import 'package:winget_gui/helpers/extensions/string_extension.dart';
import 'package:winget_gui/helpers/locale_parser.dart';
import 'package:winget_gui/helpers/version.dart';
import 'package:winget_gui/helpers/version_or_string.dart';
import 'package:winget_gui/package_infos/package_id.dart';
import 'package:winget_gui/package_infos/package_infos_full.dart';
import 'package:winget_gui/package_infos/package_infos_peek.dart';
import 'package:yaml/yaml.dart';

import 'github_api/github_api.dart';
import 'github_api/github_api_file_info.dart';
import 'github_api/winget_package_version_manifest.dart';
import 'package_source.dart';

class WingetSource extends PackageSource {
  WingetSource(super.package);

  @override
  Uri? get manifestUrl {
    return Uri(scheme: 'https', host: 'github.com', pathSegments: [
      'microsoft',
      'winget-pkgs',
      'tree',
      'master',
      'manifests',
      idInitialLetter ?? '',
      ...idAsPath
    ]);
  }

  /// First letter of the package id
  String? get idInitialLetter => package.id?.value.string.get(0)?.toLowerCase();

  /// The package id as a list of path segments
  List<String> get idAsPath => package.id?.value.allParts ?? [];

  @override
  Future<PackageInfosFull> fetchInfos(Locale? guiLocale) async {
    PackageId packageID =
        package.hasCompleteId() ? package.id!.value : await reconstructFullId();
    return extractInfosOnlineFromId(guiLocale, packageID);
  }

  Future<PackageId> reconstructFullId() async {
    String idWithoutEllipsis = package.id!.value.stringWithoutEllipsis();
    List<String> idParts = package.id!.value.allParts;
    if (idParts.last.isEmpty) {
      idParts.removeLast();
    }
    bool endsWithPoint = idWithoutEllipsis.endsWith('.');
    int soundPartsLength = endsWithPoint ? idParts.length : idParts.length - 1;
    List<String> soundParts = idParts.take(soundPartsLength).toList();
    String lastPart = endsWithPoint ? '' : idParts.last;

    GithubApiFileInfo matchingFiles = await guessIdPartsBasedOnRepo(
        soundIdPart: PackageId.parse(soundParts.join('.')),
        lastKnownPart: lastPart);
    soundParts.add(matchingFiles.name);
    return PackageId.parse(soundParts.join('.'), source: PackageSources.winget);
  }

  /// Tries to guess the last part of the package ID
  /// based on the files and directories in the winget-pkgs repository
  Future<GithubApiFileInfo> guessIdPartsBasedOnRepo(
      {required PackageId soundIdPart, required String lastKnownPart}) async {
    GithubApi api = GithubApi.wingetManifest(packageId: soundIdPart);
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
      Locale? guiLocale, PackageId packageID) async {
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

  /// Returns the files of the manifest of the given package.
  Future<List<GithubApiFileInfo>> getFiles(PackageId packageID) async {
    GithubApi fallBackApi = GithubApi.wingetManifest(packageId: packageID);
    List<GithubApiFileInfo> files;
    GithubApi manifestApi = versionManifest ?? fallBackApi;
    files = await manifestApi.getFiles(onError: fallBackApi.getFiles);
    if (files.isEmpty) {
      throw Exception('No files found');
    }
    return files;
  }

  /// Returns the [GithubApi] for the manifest of the given version.
  /// If  [package] is a [PackageInfosPeek] and has a specific available version,
  /// returns the manifest of the available version.
  /// Returns null if no specific version is available.
  GithubApi? get versionManifest {
    VersionOrString? availableVersion;
    VersionOrString? versionManifest;
    if (package is PackageInfosPeek) {
      PackageInfosPeek package = this.package as PackageInfosPeek;
      if (package.hasSpecificAvailableVersion()) {
        availableVersion = package.availableVersion?.value;
      }
    }
    if (package.hasSpecificVersion()) {
      versionManifest = package.version?.value;
    }
    if (availableVersion == null && versionManifest == null) {
      return null;
    }
    return _getManifestOfVersion((availableVersion ?? versionManifest)!);
  }

  /// return the [GithubApi] for the manifest of the given version.
  /// If the version is not a specific version, throws an exception.
  GithubApi _getManifestOfVersion(VersionOrString version) {
    if (!version.isSpecificVersion()) {
      throw Exception('Version is not a specific version: $version');
    }
    return GithubApi.wingetVersionManifest(
        packageID: package.id!.value, version: version.stringValue);
  }

  Future<Locale> chooseLocale(
      Locale? guiLocale, WingetPackageVersionManifest manifest,
      {PackageId? packageID}) async {
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

  Locale getLocaleFromName(GithubApiFileInfo e, {PackageId? packageID}) {
    String localeString = e.name
        .replaceFirst("${(packageID ?? package.id!.value).string}.locale.", '')
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
