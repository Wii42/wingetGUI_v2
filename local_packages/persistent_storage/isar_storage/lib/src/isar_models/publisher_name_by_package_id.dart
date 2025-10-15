import 'package:isar_community/isar.dart';

import 'model.dart';

part 'publisher_name_by_package_id.g.dart';

@Collection(accessor: 'publisherNameByPackageId')
class PublisherNameByPackageId extends StringModel {
  PublisherNameByPackageId({required super.key, required super.value});
}
