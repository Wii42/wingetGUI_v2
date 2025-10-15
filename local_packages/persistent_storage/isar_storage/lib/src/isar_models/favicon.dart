import 'package:isar_community/isar.dart';

import 'model.dart';

part 'favicon.g.dart';

@Collection()
class Favicon extends Model<Uri> {
  @Ignore()
  Uri get uri => Uri.parse(value);

  Favicon({required super.key, required super.value});

  factory Favicon.fromUrl({required String key, required Uri uri}) =>
      Favicon(key: key, value: uri.toString());

  @override
  MapEntry<String, Uri> toMapEntry() {
    return MapEntry(key, uri);
  }
}
