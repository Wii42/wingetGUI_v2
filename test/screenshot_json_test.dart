import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:winget_gui/helpers/package_screenshots.dart';

void main() {
  Map<String, PackageScreenshots> packageScreenshots = {
    'packageKey': PackageScreenshots(
      packageKey: 'packageKey',
      icon: Uri.parse('icon'),
      screenshots: [
        Uri.parse('screenshot1'),
        Uri.parse('screenshot2'),
      ],
    ),
    'packageKey2': PackageScreenshots(
      packageKey: 'packageKey2',
      icon: Uri.parse('icon2'),
      screenshots: [
        Uri.parse('screenshot3'),
        Uri.parse('screenshot4'),
      ],
    ),
  };

  test('screenshotsFromWingetUIJson', () async {
    print(packageScreenshots);
    dynamic json = jsonEncode(PackageScreenshots.mapToJson(packageScreenshots));
    print(json);
    Map<String, dynamic> transformedScreenshots = jsonDecode(json);
    Map<String, PackageScreenshots> transformedScreenshots2 =
        PackageScreenshots.mapFromJson(transformedScreenshots);
    print(transformedScreenshots2);
    for (String key in transformedScreenshots2.keys) {
      expect(transformedScreenshots2[key]?.packageKey,
          packageScreenshots[key]?.packageKey);
      expect(transformedScreenshots2[key]?.icon, packageScreenshots[key]?.icon);
      expect(transformedScreenshots2[key]?.screenshots,
          packageScreenshots[key]?.screenshots);
    }
  });
}
