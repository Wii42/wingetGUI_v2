import 'package:isar/isar.dart';

import 'model.dart';

part 'publisher_name_by_publisher_id.g.dart';
@Collection(accessor: 'publisherNameByPublisherId')
class PublisherNameByPublisherId extends StringModel {
  PublisherNameByPublisherId({required super.key, required super.value});
}
