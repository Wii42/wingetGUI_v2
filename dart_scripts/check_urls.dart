import 'dart:io';

import 'package:http/http.dart';
import 'package:ribs_json/ribs_json.dart';
import 'package:winget_gui/helpers/json_publisher.dart';
import 'package:winget_gui/helpers/log_stream.dart';
import 'package:winget_gui/helpers/screenshots_list_load_helper.dart';
import 'package:winget_gui/helpers/package_screenshots.dart';

ScreenshotsListLoadHelper loadHelper = ScreenshotsListLoadHelper();
Logger log = Logger('UrlChecker');
void main() async {
  LogStream.instance.toStdOut();
  List<UrlTestResponse> failedCustomIcons = await checkCustomIcons();
  List<UrlTestResponse> failedPublisherIcons = await checkPublisherIcons();
  log.info(
      'Failed custom icons:\n${failedCustomIcons.map((e) => e.toShortString()).join('\n')}');
  log.info(
      'Failed publisher icons:\n${failedPublisherIcons.map((e) => e.toShortString()).join('\n')}');
}

Future<List<UrlTestResponse>> checkCustomIcons() async {
  return await check<PackageScreenshots>(
    testName: 'CUSTOM ICONS',
    fileName: 'custom_package_screenshots.json',
    parseJsonMap: parseCustomIcons,
    urlMap: (PackageScreenshots packageScreenshots) => {
      'icon': packageScreenshots.icon,
      ...urlMapEntriesFromList(packageScreenshots.screenshots, 'screenshot'),
    },
    objectId: (PackageScreenshots packageScreenshots) =>
        packageScreenshots.packageKey,
  );
}

Future<List<UrlTestResponse>> checkPublisherIcons() async {
  return await check<JsonPublisher>(
    testName: 'PUBLISHER ICONS',
    fileName: 'publisher.json',
    parseJsonMap: JsonPublisher.parseJsonMap,
    urlMap: (JsonPublisher publisher) => {
      'icon': publisher.icon,
      'solid icon': publisher.solidIcon,
    },
    objectId: (JsonPublisher publisher) => publisher.publisherNameOrId,
  );
}

JsonObject? getJson(String fileString) {
  Json json = Json.parse(fileString).getOrElse(
    () {
      throw Exception('Error parsing JSON');
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

Future<List<UrlTestResponse>> check<T extends Object>({
  String? testName,
  required String fileName,
  required Map<String, T>? Function(String) parseJsonMap,
  required Map<String, Uri?> Function(T) urlMap,
  required String Function(T) objectId,
}) async {
  List<UrlTestResponse> responseList = [];
  log.info("Checking ${testName ?? fileName}");
  String? fileString = await loadString(fileName);
  if (fileString == null || fileString.isEmpty) {
    log.info('$fileName is empty');
    return responseList;
  }
  Map<String, T>? maybeMap = parseJsonMap(fileString);
  if (maybeMap == null) {
    log.info('Map of $fileName is null');
    return responseList;
  }
  Map<String, T> map = maybeMap;
  log.info('entries: ${map.length}');
  for (T object in map.values) {
    for (MapEntry<String, Uri?> entry in urlMap(object).entries) {
      Uri? uri = entry.value;
      if (uri != null) {
        UrlTestResponse responseMsg = UrlTestResponse(
          objectId: objectId(object),
          objectField: entry.key,
          uri: uri,
        );
        try {
          Response response = await get(uri);
          responseMsg.statusCode = response.statusCode;
          if (response.statusCode != 200) {
            responseList.add(responseMsg);
          }
        } catch (e) {
          responseMsg.error = e;
          log.warning(responseMsg.toShortString());
          responseList.add(responseMsg);
        }
      }
    }
  }
  return responseList;
}

Map<String, Uri> urlMapEntriesFromList(List<Uri>? urls, String keyPrefix) {
  if (urls == null) {
    return {};
  }
  return Map.fromEntries(
    urls.indexed.map(
      ((int, Uri) entry) => MapEntry(
        '$keyPrefix${entry.$1 + 1}',
        entry.$2,
      ),
    ),
  );
}

Map<String, PackageScreenshots>? parseCustomIcons(String fileString) {
  JsonObject? object = getJson(fileString);
  if (object == null) {
    log.error('Json in custom icons is not an object');
    return null;
  }
  return loadHelper.parseScreenshotsMap(object);
}

class UrlTestResponse {
  String objectId;
  String objectField;
  Uri uri;
  int? statusCode;
  Object? error;
  UrlTestResponse({
    required this.objectId,
    required this.objectField,
    required this.uri,
    this.statusCode,
    this.error,
  });

  @override
  String toString() {
    return 'UrlTestResponse{objectId: $objectId, objectField: $objectField, uri: $uri, statusCode: $statusCode, error: $error}';
  }

  String toShortString() {
    return '${statusCode ?? (error != null ? 'ERROR' : 'null')}: $objectId $objectField $uri${error != null ? ', error: $error' : ''}';
  }
}
