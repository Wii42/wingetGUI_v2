import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Info<T extends Object> {
  final String Function(AppLocalizations) title;
  final T value;
  final bool copyable;
  final bool couldBeLink;

  Info({required this.title, required this.value, this.copyable = false, this.couldBeLink = true});
}
