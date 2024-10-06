import 'package:isar/isar.dart';

import 'model.dart';

part 'bulk_storage.g.dart';

@Collection(accessor: 'bulkStorage')
class IsarBulkStorage extends StringModel {
  IsarBulkStorage({required super.key, required super.value});
}
