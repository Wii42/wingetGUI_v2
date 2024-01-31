import 'package:ribs_json/ribs_json.dart';

class PackageScreenshots {
  String packageKey;
  Uri? icon;
  List<Uri>? screenshots;
  PackageScreenshots? backup;

  PackageScreenshots({required this.packageKey, this.icon, this.screenshots});

  factory PackageScreenshots.fromJson(String packageName, JsonObject json) {
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

  static MapEntry<String, PackageScreenshots> getScreenshotsEntryFromJson(
      String packageName, JsonObject packageScreenshotsMap) {
    return MapEntry(packageName,
        PackageScreenshots.fromJson(packageName, packageScreenshotsMap));
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
}
