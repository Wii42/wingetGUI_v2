import 'dart:math';

import 'extensions/list_extension.dart';
import 'extensions/string_extension.dart';

class Version implements Comparable<Version> {
  static const List<String> rangeIndicators = ['<=', '>=', '<', '>', '^'];

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
    return _VersionParser(string).tryParse();
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

  bool get isPreRelease => preRelease != null;

  /// Compares two versions, returns -1 if this version is lower, 0 if they are equal, 1 if this version is higher.
  /// If two version differ in number segments, but are otherwise equal (e.g one has trailing zeroes), the version with more segments is considered higher.
  /// If two versions are equal, but one has a pre-release tag, it is higher.
  /// The order of comparison is [intSegments] -> [preRelease] -> [prefix] -> [intSegments.length] -> [rangeIndicator]
  @override
  int compareTo(Version other) {
    return _VersionComparator(this, other).compare();
  }

  /// Returns a new version with the given properties
  Version copyWith({
    List<String>? stringSegments,
    String? preRelease,
    String? prefix,
    String? rangeIndicator,
  }) {
    return Version(
      stringSegments ?? this.stringSegments,
      preRelease: preRelease ?? this.preRelease,
      prefix: prefix ?? this.prefix,
      rangeIndicator: rangeIndicator ?? this.rangeIndicator,
    );
  }

  /// Returns a new version with the given properties if they are null in the original version
  Version copyWithIfNull({
    String? preRelease,
    String? prefix,
    String? rangeIndicator,
  }) {
    return Version(
      stringSegments,
      preRelease: this.preRelease ?? preRelease,
      prefix: this.prefix ?? prefix,
      rangeIndicator: this.rangeIndicator ?? rangeIndicator,
    );
  }

  /// Returns the primary version from a list of versions, the primary version is the highest non-pre-release version, if there are no non-pre-release versions, the highest pre-release version is returned.
  /// Return null if the list is empty.
  static Version? primary(Iterable<Version> versions) {
    if (versions.isEmpty) return null;
    Version primary = versions.first;
    for (var version in versions.skip(1)) {
      if ((!version.isPreRelease && primary.isPreRelease) ||
          (version.isPreRelease == primary.isPreRelease && version > primary)) {
        primary = version;
      }
    }
    return primary;
  }

  @override
  bool operator ==(Object other) {
    if (other is Version) {
      return compareTo(other) == 0;
    }
    return false;
  }

  @override
  int get hashCode {
    List<Object?> data = [
      for (int e in intSegments) e,
      preRelease,
      prefix,
      rangeIndicator,
    ];
    return Object.hashAll(data);
  }

  bool operator <(Version other) => compareTo(other) < 0;
  bool operator <=(Version other) => compareTo(other) <= 0;
  bool operator >(Version other) => compareTo(other) > 0;
  bool operator >=(Version other) => compareTo(other) >= 0;
}

class _VersionParser {
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
    'PB',
    'PBv',
    'Alpha',
    'alpha-',
  ];
  String string;

  _VersionParser(this.string);

  Version? tryParse() {
    string = string.trim();
    if (string.endsWith('…')) {
      return null;
    }
    String? rangeIndicator = getRangeIndicator();
    String? prefix = getPrefix();

    String? preRelease = getPreReleaseByHyphen();
    List<String> segments = string.split('.').toList();
    if (segments.isEmpty) return null;
    if (segments.any((e) => e.isEmpty)) return null;
    if (segments.length > 1 && preRelease == null) {
      preRelease = getPreReleaseInLastPart(segments, preRelease);
    }
    if (segments.any((e) => !e.isDigits())) return null;
    return Version(segments,
        preRelease: preRelease, rangeIndicator: rangeIndicator, prefix: prefix);
  }

  String? getPreReleaseInLastPart(List<String> segments, String? preRelease) {
    String lastSegment = segments.last;
    if (!lastSegment.isDigits()) {
      int preReleaseIndex = _getPreReleaseIndex(lastSegment);
      preRelease = lastSegment.substring(preReleaseIndex);
      lastSegment = lastSegment.take(preReleaseIndex);
      segments.last = lastSegment;
      if (preReleaseIndex == 0) {
        segments.removeLast();
        preRelease = '.$preRelease';
      }
    }
    return preRelease;
  }

  String? getPreReleaseByHyphen() {
    int preReleaseIndex = string.indexOf('-');
    String? preRelease;
    if (preReleaseIndex != -1) {
      preRelease = string.substring(preReleaseIndex);
      string = string.take(preReleaseIndex);
    }
    return preRelease;
  }

  String? getPrefix() {
    String? prefix;
    bool startsWithPrefix(String e) => string.startsWith(RegExp('$e[0-9]+'));
    if (prefixes.any(startsWithPrefix)) {
      int index = prefixes.indexWhere(startsWithPrefix);
      prefix = prefixes[index];
      string = string.substring(prefix.length).trim();
    }
    return prefix;
  }

  String? getRangeIndicator() {
    String? rangeIndicator;
    if (Version.rangeIndicators.any(string.startsWith)) {
      int index = Version.rangeIndicators.indexWhere(string.startsWith);
      rangeIndicator = Version.rangeIndicators[index];
      string = string.substring(rangeIndicator.length).trim();
    }
    return rangeIndicator;
  }

  ///Get index of the first non digit character in the string
  static int _getPreReleaseIndex(String string) {
    for (int i = 0; i < string.length; i++) {
      if (!string[i].isDigits()) {
        return i;
      }
    }
    return string.length;
  }
}

class _VersionComparator {
  static const Map<(String?, String?), int> rangeIndicatorCompareTable = {
    ('<', '>'): -1,
    ('<', '<='): -1,
    ('<', '>='): -1,
    ('<', '^'): -1,
    ('<', null): -1,
    ('>', '<='): 1,
    ('>', '>='): 1,
    ('>', '^'): 1,
    ('>', null): 1,
    ('<=', '>='): -1,
    ('<=', '^'): -1,
    ('<=', null): -1,
    ('>=', '^'): 1,
    ('>=', null): 1,
    ('^', null): 0,
  };

  final Version version;
  final Version other;

  _VersionComparator(this.version, this.other);

  /// Compares two versions, returns -1 if this version is lower, 0 if they are equal, 1 if this version is higher.
  /// If two version differ in number segments, but are otherwise equal (e.g one has trailing zeroes), the version with more segments is considered higher.
  /// If two versions are equal, but one has a pre-release tag, it is higher.
  /// The order of comparison is [intSegments] -> [preRelease] -> [prefix] -> [intSegments.length] -> [rangeIndicator]
  int compare() {
    List<int Function()> comparators = [
      for (int i = 0;
          i < max(version.intSegments.length, other.intSegments.length);
          i++)
        //compare intSegments one by one
        () => nullableCompare(
            version.intSegments.get(i), other.intSegments.get(i)),
      //compare preReleases
      () => nullableCompare(version.preRelease, other.preRelease),
      //compare prefixes
      () => nullableCompare(version.prefix, other.prefix),
      //compare intSegments length
      () => version.intSegments.length.compareTo(other.intSegments.length),
      // compare rangeIndicators
      () => compareRangeIndicators(version.rangeIndicator, other.rangeIndicator)
    ];
    for (int Function() comparator in comparators) {
      int compare = comparator();
      if (compare != 0) {
        return compare;
      }
    }
    return 0;
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

  static int compareRangeIndicators(String? a, String? b) {
    if (a == b) return 0;
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
}
