import 'package:json_annotation/json_annotation.dart';
import 'package:ribs_json/ribs_json.dart';

part 'package_screenshots.g.dart';

@JsonSerializable()
class PackageScreenshots {
  String packageKey;
  Uri? icon;
  @JsonKey(name: 'images')
  List<Uri>? screenshots;
  @JsonKey(includeFromJson: false, includeToJson: false)
  PackageScreenshots? backup;

  PackageScreenshots(
      {required this.packageKey, this.icon, this.screenshots, this.backup});

  factory PackageScreenshots.fromJsonWithPackageName(
      String packageName, JsonObject json) {
    return PackageScreenshots(
        packageKey: packageName,
        icon:
            maybeParse(json.get('icon').toNullable()?.asString().toNullable()),
        screenshots: json
            .get('images')
            .toNullable()
            ?.asArray()
            .toNullable()
            ?.map((e) => maybeParse(e.asString().toNullable()))
            .toList()
            .nonNulls
            .toList());
  }

  factory PackageScreenshots.fromJson(Map<String, dynamic> json) =>
      _$PackageScreenshotsFromJson(json);

  Map<String, dynamic> toJson() => _$PackageScreenshotsToJson(this);

  static MapEntry<String, PackageScreenshots> getScreenshotsEntryFromJson(
      String packageName, JsonObject packageScreenshotsMap) {
    return MapEntry(
        packageName,
        PackageScreenshots.fromJsonWithPackageName(
            packageName, packageScreenshotsMap));
  }

  static Uri? maybeParse(String? url) {
    if (url == null || url.trim().isEmpty) {
      return null;
    }
    return Uri.tryParse(url);
  }

  @override
  String toString() {
    return 'PackageScreenshots{packageKey: $packageKey, icon: $icon, screenshots: $screenshots}';
  }

  PackageScreenshots copyWith({
    String? packageKey,
    Uri? icon,
    List<Uri>? screenshots,
    PackageScreenshots? backup,
  }) {
    return PackageScreenshots(
      packageKey: packageKey ?? this.packageKey,
      icon: icon ?? this.icon,
      screenshots: screenshots ?? this.screenshots,
      backup: backup ?? this.backup,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PackageScreenshots &&
        other.packageKey == packageKey &&
        other.icon == icon &&
        other.screenshots == screenshots;
  }

  @override
  int get hashCode =>
      Object.hash(packageKey, icon, Object.hashAll(screenshots ?? []));

  /// Decodes a map of [PackageScreenshots] from a JSON object.
  static Map<String, PackageScreenshots> mapFromJson(
      Map<String, dynamic> json) {
    return json
        .map((key, value) => MapEntry(key, PackageScreenshots.fromJson(value)));
  }
  /// Encodes a map of [PackageScreenshots] to a JSON object.
  static Map<String, dynamic> mapToJson(Map<String, PackageScreenshots> map) {
    return map.map((key, value) => MapEntry(key, value.toJson()));
  }
}
