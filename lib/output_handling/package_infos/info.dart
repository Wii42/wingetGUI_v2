import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/package_infos/package_attribute.dart';

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

  factory Info.fromAttribute(
      PackageAttribute attribute, {required T value}) {
    return Info<T>(
        title: attribute.title,
        value: value,
        copyable: attribute.copyable,
        couldBeLink: attribute.couldBeLink);
  }

  Info<T> copyWith(
      {String Function(AppLocalizations)? title,
      T? value,
      bool? copyable,
      bool? couldBe,
      String? customTitle}) {
    return Info<T>(
        title: title ?? this.title,
        value: value ?? this.value,
        copyable: copyable ?? this.copyable,
        couldBeLink: couldBe ?? this.couldBeLink,
        customTitle: customTitle ?? this.customTitle);
  }

  Info<String> toStringInfoFromObject(String Function(T object)? toString) {
    return Info<String>(
        title: title,
        value: toString != null ? toString(value) : value.toString(),
        copyable: copyable,
        couldBeLink: couldBeLink,
        customTitle: customTitle);
  }
  Type get valueType {
    return T;
  }
}
