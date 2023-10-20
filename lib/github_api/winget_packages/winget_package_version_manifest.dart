import '../github_api_file_info.dart';

class WingetPackageVersionManifest {
  final GithubApiFileInfo installer;
  final List<GithubApiFileInfo> localizedFiles;
  final GithubApiFileInfo manifest;

  WingetPackageVersionManifest({
    required this.installer,
    required this.localizedFiles,
    required this.manifest,
  });

  factory WingetPackageVersionManifest.fromList(List<GithubApiFileInfo> files,
      {required String packageId}) {
    GithubApiFileInfo installer = files
        .firstWhere((element) => isInstaller(element, packageId: packageId));
    List<GithubApiFileInfo> localizedFiles = files.where(isLocale).toList();
    GithubApiFileInfo manifest = files
        .firstWhere((element) => isManifest(element, packageId: packageId));
    return WingetPackageVersionManifest(
      installer: installer,
      localizedFiles: localizedFiles,
      manifest: manifest,
    );
  }

  static bool isInstaller(GithubApiFileInfo file, {required String packageId}) {
    return file.name == '$packageId.installer.yaml' && file.type.isFile;
  }

  static bool isLocale(GithubApiFileInfo file) {
    return file.name.contains('.locale.') && file.type.isFile;
  }

  static bool isManifest(GithubApiFileInfo file, {required String packageId}) {
    return file.name == "$packageId.yaml" && file.type.isFile;
  }

  static isVersionManifest(List<GithubApiFileInfo> files,
      {required String packageId}) {
    return files.any((element) => isInstaller(element, packageId: packageId)) &&
        files.any(isLocale) &&
        files.any((element) => isManifest(element, packageId: packageId));
  }
}
