import 'package:pub_semver/pub_semver.dart';

class VersionOrString {
  final String? stringVersion;
  final Version? version;

  VersionOrString.version(this.version) : stringVersion = null;

  VersionOrString.stringVersion(this.stringVersion) : version = null;

  factory VersionOrString.parse(String string) {
    try {
      return VersionOrString.version(Version.parse(string));
    } catch (e) {
      return VersionOrString.stringVersion(string);
    }
  }
  Type get nestedType =>
      isTypeVersion() ? version.runtimeType : stringVersion.runtimeType;
  @override
  String toString() {
    return "VersionOrString: $nestedType: ${version ?? stringVersion}";
  }

  String get stringValue {
    return version?.toString() ?? stringVersion!;
  }

  bool isSpecificVersion() {
    if (isTypeVersion()) {
      print('$version is any version: ${version!.isAny}');
      return !version!.isAny;
    }
    return stringVersion != 'Unknown' &&
        !stringVersion!.contains('<') &&
        !stringVersion!.contains('>') &&
        !stringVersion!.contains('…');
  }

  bool isTypeVersion() {
    return version != null;
  }

  bool isTypeString() {
    return stringVersion != null;
  }
}
