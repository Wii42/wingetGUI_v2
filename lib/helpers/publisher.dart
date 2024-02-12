import 'dart:convert';

class Publisher {
  final String publisherId;
  final String? publisherName;
  final Uri? icon;
  final Uri? solidIcon;
  final String?
      sourcePublisherId; // PublisherId of the source where the data is saved

  const Publisher(
      {required this.publisherId,
      this.publisherName,
      this.icon,
      this.solidIcon,
      this.sourcePublisherId});

  factory Publisher.fromJson(String publisherId, Map<String, dynamic> object) {
    String? iconUrl = object['icon_url'];
    String? solidIconUrl = object['solid_icon_url'];
    return Publisher(
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
    if (icon != null) {
      return icon;
    }
    if (sourcePublisherId == null) {
      return null;
    }
    Publisher? sourceObject = objects[sourcePublisherId!];
    return sourceObject?.icon;
  }

  Uri? solidIconUsingSource(Map<String, Publisher> objects) {
    if (solidIcon != null) {
      return solidIcon;
    }
    if (sourcePublisherId == null) {
      return null;
    }
    Publisher? sourceObject = objects[sourcePublisherId!];
    return sourceObject?.solidIcon;
  }

  static Map<String, Publisher> parseJsonMap(String json) {
    Map<String, dynamic> jsonMap = jsonDecode(json);
    return jsonMap.map((key, value) {
      return MapEntry(key, Publisher.fromJson(key, value));
    });
  }
}
