import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Info<T extends Object> {
  final String Function(AppLocalizations) title;
  final T value;
  final bool copyable;
  final bool couldBeLink;
  final String? customTitle;

  Info(
      {required this.title,
      required this.value,
      this.copyable = false,
      this.couldBeLink = true,
      this.customTitle});

  Info<T> copyWith({String Function(AppLocalizations)? title, T? value, bool? copyable, bool? couldBe, String? customTitle}){
    return Info<T>(
      title: title ?? this.title,
      value: value ?? this.value,
      copyable: copyable ?? this.copyable,
      couldBeLink: couldBe ?? this.couldBeLink,
      customTitle: customTitle ?? this.customTitle
    );
  }
}