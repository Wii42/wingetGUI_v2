import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../output_handling/package_infos/package_attribute.dart';

extension HasEntryExtension<T> on Map<T, String> {
  bool hasEntry(T key) {
    return (containsKey(key) && this[key]!.isNotEmpty);
  }
}

extension HasInfoExtension on Map<String, String> {
  bool hasInfo(PackageAttribute attribute, AppLocalizations local) {
    return hasEntry(attribute.key(local));
  }
}
