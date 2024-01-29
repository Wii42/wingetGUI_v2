import 'dart:convert';

import 'package:winget_gui/helpers/package_screenshots_list.dart';

class Publisher {
  final String publisherId;
  final String? publisherName;
  final Uri? iconUrl;
  final String?
      sourcePublisherId; // PublisherId of the source where the data is saved

  const Publisher(
      {required this.publisherId,
      this.publisherName,
      this.iconUrl,
      this.sourcePublisherId});

  factory Publisher.fromJson(String publisherId, Map<String, dynamic> object) {
    String? iconUrl = object['icon_url'];
    return Publisher(
        publisherId: publisherId,
        publisherName: object['publisher_name'],
        iconUrl: iconUrl != null ? Uri.tryParse(object['icon_url']) : null,
        sourcePublisherId: object['source_publisher_id']);
  }

  @override
  String toString() {
    return 'PublisherObject{publisherId: $publisherId, publisherName: $publisherName, iconUrl: $iconUrl}';
  }

  String get publisherNameOrId => publisherName ?? publisherId;

  String? nameUsingSource(Map<String, Publisher> objects) {
    if (publisherName != null) {
      return publisherName;
    }
    if (sourcePublisherId == null) {
      return null;
    }
    Publisher? sourceObject = objects[sourcePublisherId!];
    return sourceObject?.publisherNameOrId ?? sourcePublisherId;
  }

  Uri? iconUsingSource(Map<String, Publisher> objects) {
    if (iconUrl != null) {
      return iconUrl;
    }
    if (sourcePublisherId == null) {
      return null;
    }
    Publisher? sourceObject = objects[sourcePublisherId!];
    return sourceObject?.iconUrl;
  }

  String? get nameUsingDefaultSource =>
      nameUsingSource(PackageScreenshotsList.instance.publisherIcons);
  Uri? get iconUsingDefaultSource =>
      iconUsingSource(PackageScreenshotsList.instance.publisherIcons);

  static Map<String, Publisher> parseJsonMap(String json) {
    Map<String, dynamic> jsonMap = jsonDecode(json);
    return jsonMap.map((key, value) {
      return MapEntry(key, Publisher.fromJson(key, value));
    });
  }
}
