import 'dart:math';

import 'package:winget_gui/helpers/extensions/list_extension.dart';
import 'package:winget_gui/helpers/extensions/string_extension.dart';

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

  bool isSpecificVersion() {
    if (isTypeVersion()) {
      return version!.rangeIndicator == null;
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

class Version implements Comparable<Version> {
  static const List<String> rangeIndicators = ['<=', '>=', '<', '>', '^'];
  static const List<String> prefixes = [
    'v.',
    'v',
    'V.',
    'V',
    'R',
    'r',
    'G',
    'D',
    'B',
    'PB'
  ];

  static const Map<(String?, String?), int> rangeIndicatorCompareTable = {
    ('<', '>'): -1,
    ('<', '<='): 0,
    ('<', '>='): -1,
    ('<', '^'): -1,
    ('<', null): -1,
    ('>', '<='): 1,
    ('>', '>='): 0,
    ('>', '^'): 1,
    ('>', null): 1,
    ('<=', '>='): 0,
    ('<=', '^'): 0,
    ('<=', null): 0,
    ('>=', '^'): 0,
    ('>=', null): 0,
    ('^', null): 0,
  };

  static int compareRangeIndicators(String? a, String? b) {
    int? result = rangeIndicatorCompareTable[(a, b)];
    if (result != null) {
      return result;
    }
    result = rangeIndicatorCompareTable[(b, a)];
    if (result != null) {
      return -result;
    }
    return 0;
  }

  final List<String> stringSegments;
  final String? preRelease;

  /// Prefix of the version, e.g. "v" in "v1.2.3"
  final String? prefix;

  /// Range indicator, e.g. ">" in "> 1.2.3"
  final String? rangeIndicator;

  Version(this.stringSegments,
      {this.preRelease, this.prefix, this.rangeIndicator});

  /// Parses a version string, returns null if the string is not a valid version.
  static Version? tryParse(String string) {
    string = string.trim();
    if (string.endsWith('…')) {
      return null;
    }
    String? rangeIndicator;
    if (rangeIndicators.any(string.startsWith)) {
      int index = rangeIndicators.indexWhere(string.startsWith);
      rangeIndicator = rangeIndicators[index];
      string = string.substring(rangeIndicator.length).trim();
    }
    String? prefix;
    bool startsWithPrefix(String e) => string.startsWith(RegExp('$e[0-9]+'));
    if (prefixes.any(startsWithPrefix)) {
      int index = prefixes.indexWhere(startsWithPrefix);
      prefix = prefixes[index];
      string = string.substring(prefix.length).trim();
    }

    int preReleaseIndex = string.indexOf('-');
    String? preRelease;
    if (preReleaseIndex != -1) {
      preRelease = string.substring(preReleaseIndex);
      string = string.take(preReleaseIndex);
    }
    List<String> segments = string.split('.').toList();
    if (segments.isEmpty) return null;
    if (segments.any((e) => e.isEmpty)) return null;
    if (segments.length > 1 && preRelease == null) {
      String lastSegment = segments.last;
      if (!lastSegment.isDigits()) {
        int preReleaseIndex = _getPreReleaseIndex(lastSegment);
        if (preReleaseIndex == 0) return null;
        preRelease = lastSegment.substring(preReleaseIndex);
        lastSegment = lastSegment.take(preReleaseIndex);
        segments.last = lastSegment;
      }
    }
    if (segments.any((e) => !e.isDigits())) return null;
    return Version(segments,
        preRelease: preRelease, rangeIndicator: rangeIndicator, prefix: prefix);
  }

  /// Parses a version string, throws a [FormatException] if the string is not a valid version.
  factory Version.parse(String string) {
    Version? version = tryParse(string);
    if (version == null) {
      throw FormatException('Invalid version string: $string');
    }
    return version;
  }

  int get major => intSegments[0];
  int? get minor => intSegments.get(1);
  int? get patch => intSegments.get(2);

  List<int> get intSegments => stringSegments.map((e) => int.parse(e)).toList();

  ///Get index of the first non digit character in the string
  static int _getPreReleaseIndex(String string) {
    for (int i = 0; i < string.length; i++) {
      if (!string[i].isDigits()) {
        return i;
      }
    }
    return string.length;
  }

  /// String representation, if version is initialized with [parse]/[tryParse], it will return the original string
  @override
  String toString() {
    List<String> parts = [
      if (rangeIndicator != null) '$rangeIndicator ',
      if (prefix != null) '$prefix',
      stringSegments.join('.'),
      preRelease != null ? '$preRelease' : '',
    ];
    return parts.join();
  }

  /// Canonicalized version string, identical to [toString], prefixes and prefixed zeroes are omitted
  String get canonicalizedVersion {
    List<String> parts = [
      if (rangeIndicator != null) '$rangeIndicator ',
      intSegments.join('.'),
      (preRelease != null ? '$preRelease' : ''),
    ];
    return parts.join();
  }

  String get sortingString {
    List<String> parts = [
      stringSegments.join('.'),
      preRelease != null ? '$preRelease' : '',
      if (prefix != null) '$prefix',
      if (rangeIndicator != null) '$rangeIndicator ',
    ];
    return parts.join();
  }

  /// Compares two versions, returns -1 if this version is lower, 0 if they are equal, 1 if this version is higher.
  /// If two version differ in number segments, but are otherwise equal (e.g one has trailing zeroes), the version with more segments is considered higher.
  /// If two versions are equal, but one has a pre-release tag, it is higher.
  /// The order of comparison is [intSegments] -> [preRelease] -> [prefix] -> [intSegments.length] -> [rangeIndicator]
  @override
  int compareTo(Version other) {
    for (int i = 0;
        i < max(intSegments.length, other.intSegments.length);
        i++) {
      int thisSegment = intSegments.get(i) ?? 0;
      int otherSegment = other.intSegments.get(i) ?? 0;
      int compare = thisSegment.compareTo(otherSegment);
      if (compare != 0) {
        return compare;
      }
    }
    int prereleaseCompare = nullableCompare(preRelease, other.preRelease);
    if (prereleaseCompare != 0) {
      return prereleaseCompare;
    }
    int prefixCompare = nullableCompare(prefix, other.prefix);
    if (prefixCompare != 0) {
      return prefixCompare;
    }
    int segmentsLengthCompare =
        intSegments.length.compareTo(other.intSegments.length);
    if (segmentsLengthCompare != 0) {
      return segmentsLengthCompare;
    }
    return compareRangeIndicators(rangeIndicator, other.rangeIndicator);
  }

  static nullableCompare(Comparable<dynamic>? a, Comparable<dynamic>? b) {
    if (a != null && b != null) {
      return a.compareTo(b);
    }
    if (a != null) {
      return 1;
    }
    if (b != null) {
      return -1;
    }
    return 0;
  }
}
