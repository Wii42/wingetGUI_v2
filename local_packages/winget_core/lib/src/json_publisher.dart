import 'dart:convert';

class JsonPublisher {
  final String publisherId;
  final String? publisherName;
  final Uri? icon;
  final Uri? solidIcon;

  /// PublisherId of the source where the data is saved
  final String? sourcePublisherId;

  const JsonPublisher(
      {required this.publisherId,
      this.publisherName,
      this.icon,
      this.solidIcon,
      this.sourcePublisherId});

  factory JsonPublisher.fromJson(
      String publisherId, Map<String, dynamic> object) {
    String? iconUrl = object['icon_url'];
    String? solidIconUrl = object['solid_icon_url'];
    return JsonPublisher(
        publisherId: publisherId,
        publisherName: object['publisher_name'],
        icon: iconUrl != null ? Uri.tryParse(iconUrl) : null,
        solidIcon: solidIconUrl != null ? Uri.tryParse(solidIconUrl) : null,
        sourcePublisherId: object['source_publisher_id']);
  }

  @override
  String toString() {
    return 'PublisherObject{publisherId: $publisherId, publisherName: $publisherName, iconUrl: $icon}';
  }

  String get publisherNameOrId => publisherName ?? publisherId;

  String? nameUsingSource(Map<String, JsonPublisher> objects) {
    if (publisherName != null) {
      return publisherName;
    }
    if (sourcePublisherId == null) {
      return null;
    }
    JsonPublisher? sourceObject = objects[sourcePublisherId!];
    return sourceObject?.publisherNameOrId ?? sourcePublisherId;
  }

  Uri? iconUsingSource(Map<String, JsonPublisher> objects) {
    if (icon != null) {
      return icon;
    }
    if (sourcePublisherId == null) {
      return null;
    }
    JsonPublisher? sourceObject = objects[sourcePublisherId!];
    return sourceObject?.icon;
  }

  Uri? solidIconUsingSource(Map<String, JsonPublisher> objects) {
    if (solidIcon != null) {
      return solidIcon;
    }
    if (sourcePublisherId == null) {
      return null;
    }
    JsonPublisher? sourceObject = objects[sourcePublisherId!];
    return sourceObject?.solidIcon;
  }

  static Map<String, JsonPublisher> parseJsonMap(String json) {
    Map<String, dynamic> jsonMap = jsonDecode(json);
    return jsonMap.map((key, value) {
      return MapEntry(key, JsonPublisher.fromJson(key, value));
    });
  }
}
