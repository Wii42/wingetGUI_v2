import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Info<T extends Object> {
  final String Function(AppLocalizations) title;
  final T value;

  Info({required this.title, required this.value});
}
