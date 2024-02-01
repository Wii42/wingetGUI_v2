// ignore_for_file: avoid_print

import 'dart:io';

import 'package:http/http.dart';
import 'package:ribs_json/ribs_json.dart';
import 'package:winget_gui/helpers/publisher.dart';
import 'package:winget_gui/helpers/screenshots_list_load_helper.dart';
import 'package:winget_gui/helpers/package_screenshots.dart';

ScreenshotsListLoadHelper loadHelper = ScreenshotsListLoadHelper();
void main() async {
  await checkCustomIcons();
  print('');
  await checkPublisherIcons();
}

Future<void> checkCustomIcons() async {
  print('CUSTOM ICONS:');
  JsonObject? object = await getJson('custom_package_screenshots.json');
  if (object == null) {
    print('Json in custom icons is not an object');
    return;
  }
  Map<String, PackageScreenshots> map = loadHelper.parseScreenshotsMap(object);
  for (PackageScreenshots packageScreenshots in map.values) {
    if (packageScreenshots.icon != null) {
      Response response = await get(packageScreenshots.icon!);
      if (response.statusCode != 200) {
        print(
            '${response.statusCode}: ${packageScreenshots.packageKey} icon ${packageScreenshots.icon}');
      }
    }
    if (packageScreenshots.screenshots != null) {
      for (Uri screenshot in packageScreenshots.screenshots!) {
        Response response = await get(screenshot);
        if (response.statusCode != 200) {
          print(
              '${response.statusCode}: ${packageScreenshots.packageKey} screenshot $screenshot');
        }
      }
    }
  }
}

Future<void> checkPublisherIcons() async {
  print('PUBLISHER:');
  String? publisherString = await loadString('publisher.json');
  if (publisherString == null || publisherString.isEmpty) {
    print('publisher.json is empty');
    return;
  }
  Map<String, Publisher> map = Publisher.parseJsonMap(publisherString);
  for (Publisher publisher in map.values) {
    if (publisher.iconUrl != null) {
      Response response = await get(publisher.iconUrl!);
      if (response.statusCode != 200) {
        print(
            '${response.statusCode}: ${publisher.publisherNameOrId} icon ${publisher.iconUrl}');
      }
    }
  }
}

Future<JsonObject?> getJson(String fileName) async {
  String? customScreenshotsString = await loadString(fileName);
  if (customScreenshotsString == null || customScreenshotsString.isEmpty) {
    print('$fileName is empty');
    return null;
  }
  Json json = Json.parse(customScreenshotsString).getOrElse(
    () {
      throw Exception('Error parsing JSON of $fileName');
    },
  );
  return json.asObject().toNullable();
}

Future<String?> loadString(String fileName) async {
  String string = await File('assets/$fileName').readAsString();
  if (string.isEmpty) {
    return null;
  }
  return string;
}
