import 'package:isar/isar.dart';

abstract class Model<T extends Object>{
  Id id = Isar.autoIncrement;
  @Index(type: IndexType.value, unique: true, replace: true)
  String key;
  String value;

  Model({required this.key, required this.value});


  MapEntry<String, T> toMapEntry();
}

class StringModel extends Model<String>{
  StringModel({required super.key, required super.value});

  @override
  MapEntry<String, String> toMapEntry() {
    return MapEntry(key, value);
  }
}