import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Info<T extends Object> {
  final String Function(AppLocalizations) title;
  final T value;
  final bool copyable;

  Info({required this.title, required this.value, this.copyable = false});
}
