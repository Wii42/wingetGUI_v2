import 'package:winget_gui/helpers/extensions/string_extension.dart';
import 'package:winget_gui/package_sources/package_source.dart';

const String ellipsis = '…';

class PackageId {
  final String? publisherId;

  /// The parts of the id, separated by [separator], with the publisherId at the start.
  final List<String> idParts;
  final bool hasEllipsis;
  final String? separator;

  PackageId({
    this.publisherId,
    this.idParts = const [],
    this.hasEllipsis = false,
    this.separator,
  }) {
    assert(allParts.length <= 1 || separator != null);
  }

  factory PackageId.parse(String id,
      {PackageSources source = PackageSources.none}) {
    bool hasEllipsis = id.endsWith(ellipsis);
    if (hasEllipsis) {
      id = id.take(id.length - 1);
    }
    String separator = '.';
    List<String> parts = id.split(separator);
    String? publisherId;
    if (source != PackageSources.unknownSource &&
        source != PackageSources.none) {
      if (parts.length > 1) {
        publisherId = parts.removeAt(0);
      }
    }
    return PackageId(
      publisherId: publisherId,
      idParts: parts,
      hasEllipsis: hasEllipsis,
      separator: separator,
    );
  }

  /// The parts of the id, including the publisherId.
  List<String> get allParts =>
      [if (publisherId != null) publisherId!, ...idParts];

  String? probablyPublisherId() {
    if (publisherId != null) {
      return publisherId;
    }
    if (idParts.length > 1) {
      return idParts.first;
    }
    if (idParts.length == 1) {
      String id = idParts.first;
      if (id.trim().contains(' ')) {
        return id.trim().split(' ').first;
      }
    }
    return null;
  }

  /// The id as a string, with [separator] between the parts.
  /// If instantiated with [PackageId.parse], this is the original id.
  String get string {
    String result = stringWithoutEllipsis();
    if (hasEllipsis) {
      result += ellipsis;
    }
    return result;
  }

  @override
  String toString() => string;

  bool get isComplete {
    return string.isNotEmpty && !hasEllipsis;
  }

  String stringWithoutEllipsis() => allParts.join(separator ?? ' ');

  PackageId copyWith({
    String? publisherId,
    List<String>? idParts,
    bool? hasEllipsis,
    String? separator,
  }) {
    return PackageId(
      publisherId: publisherId ?? this.publisherId,
      idParts: idParts ?? this.idParts,
      hasEllipsis: hasEllipsis ?? this.hasEllipsis,
      separator: separator ?? this.separator,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! PackageId) {
      return false;
    }
    return string == other.string;
  }

  @override
  int get hashCode => string.hashCode;

  String? get initialLetter => string.firstChar().toLowerCase();
}
