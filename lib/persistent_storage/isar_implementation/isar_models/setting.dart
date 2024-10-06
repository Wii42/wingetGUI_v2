import 'package:isar/isar.dart';

import 'model.dart';

part 'setting.g.dart';

@Collection()
class Setting extends StringModel {
  Setting({required super.key, required super.value});
}
