class Dependencies {
  final List<String>? windowsFeatures;
  final List<String>? windowsLibraries;
  final List<PackageDependencies>? packageDependencies;
  final List<String>? externalDependencies;

  Dependencies(
      {this.windowsFeatures,
      this.windowsLibraries,
      this.packageDependencies,
      this.externalDependencies});

  factory Dependencies.fromYamlMap(Map<dynamic, dynamic> map) {
    return Dependencies(
      windowsFeatures: map['WindowsFeatures'] != null
          ? List<String>.from(map['WindowsFeatures'])
          : null,
      windowsLibraries: map['WindowsLibraries'] != null
          ? List<String>.from(map['WindowsLibraries'])
          : null,
      packageDependencies: map['PackageDependencies'] != null
          ? List<PackageDependencies>.from(map['PackageDependencies']
              .map((e) => PackageDependencies.fromYamlMap(e)))
          : null,
      externalDependencies: map['ExternalDependencies'] != null
          ? List<String>.from(map['ExternalDependencies'])
          : null,
    );
  }
}

class PackageDependencies {
  final String packageID;
  final String? minimumVersion;

  PackageDependencies({required this.packageID, this.minimumVersion});

  factory PackageDependencies.fromYamlMap(Map<dynamic, dynamic> map) {
    return PackageDependencies(
      packageID: map['PackageIdentifier'],
      minimumVersion: map['MinimumVersion'],
    );
  }
}
