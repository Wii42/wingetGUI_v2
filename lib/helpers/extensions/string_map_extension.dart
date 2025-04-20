import 'package:winget_core/winget_core.dart';

extension HasEntryExtension<T> on Map<T, String> {
  bool hasEntry(T key) {
    return (containsKey(key) && this[key]!.isNotEmpty);
  }
}

extension HasInfoExtension on Map<String, String> {
  bool hasInfo(PackageAttribute attribute, PackageLocalizer local) {
    return hasEntry(attribute.key(local));
  }
}
