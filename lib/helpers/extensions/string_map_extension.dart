import '../../output_handling/infos/info_enum.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension HasEntryExtension<T> on Map<T, String> {
  bool hasEntry(T key) {
    return (containsKey(key) && this[key]!.isNotEmpty);
  }
}

extension HasInfoExtension on Map<String, String> {
  bool hasInfo(Info info, AppLocalizations local){
    return hasEntry(info.key(local));
  }
}
