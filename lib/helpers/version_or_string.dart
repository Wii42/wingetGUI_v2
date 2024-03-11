

import 'package:winget_gui/helpers/version.dart';

class VersionOrString {
  final String? stringVersion;
  final Version? version;

  VersionOrString.version(Version this.version) : stringVersion = null;

  VersionOrString.stringVersion(String this.stringVersion) : version = null;

  factory VersionOrString.parse(String string) {
    Version? version = Version.tryParse(string);
    if (version != null) {
      return VersionOrString.version(version);
    }
    return VersionOrString.stringVersion(string);
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

  String get sortingString {
    return version?.sortingString ?? stringVersion!;
  }

  bool isVersion() {
    return version != null ||
        (stringVersion != null && stringVersion!.isNotEmpty);
  }

  bool isSpecificVersion() {
    bool isSpecific;
    if (isTypeVersion()) {
      isSpecific = version!.rangeIndicator == null;
    } else {
      isSpecific = stringVersion != 'Unknown' &&
          !stringVersion!.contains('<') &&
          !stringVersion!.contains('>') &&
          !stringVersion!.contains('…');
    }
    return isSpecific && isVersion();
  }

  bool isTypeVersion() {
    return version != null;
  }

  bool isTypeString() {
    return stringVersion != null;
  }
}
