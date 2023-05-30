import '../../output_handling/info_enum.dart';

extension HasEntryExtension<T> on Map<T, String> {
  bool hasEntry(T key) {
    return (containsKey(key) && this[key]!.isNotEmpty);
  }
}

extension HasInfoExtension on Map<String, String> {
  bool hasInfo(Info info){
    return hasEntry(info.key);
  }
}
