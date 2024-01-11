import 'package:ribs_json/ribs_json.dart';

class PackageScreenshots {
  String packageKey;
  Uri? icon;
  Uri? backupIcon;
  List<Uri>? screenshots;

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

  static Uri? maybeParse(String? url) {
    if (url == null) {
      return null;
    }
    return Uri.tryParse(url);
  }

  @override
  String toString() {
    return 'PackageScreenshots{packageKey: $packageKey, icon: $icon, screenshots: $screenshots}';
  }
}
