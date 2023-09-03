import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// When the language is changed.
typedef OnChangeLocale = void Function(Locale locale);

/// Builds the widget in the [Locale].
typedef LocaleBuilder = Widget Function(
  BuildContext context,
  Locale locale,
);

/// Class with actions to manipulate [Locale].
@immutable
@visibleForTesting
class LocaleData {
  const LocaleData({
    required this.locale,
    required this.setLocale,
  });

  /// Gets the current [Locale].
  final Locale locale;

  /// Changes [Locale].
  final OnChangeLocale setLocale;

  /// Create a new [LocaleData] based in other.
  LocaleData copyWith({
    Locale? locale,
    OnChangeLocale? setLocale,
  }) {
    return LocaleData(
      locale: locale ?? this.locale,
      setLocale: setLocale ?? this.setLocale,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LocaleData &&
        other.locale == locale &&
        other.setLocale == setLocale;
  }

  @override
  int get hashCode => Object.hashAll([locale, setLocale]);
}

/// Provides access to [LocaleData] in its descendant widgets to
/// manage your [Locale]. Rebuilds every time that a new [Locale] is set.

class AppLocale extends StatefulWidget {
  AppLocale({
    required this.builder,
    this.onChangeLocale,
    Locale? initialLocale,
    super.key,
  }) : initialLocale = initialLocale ??
            determineClosestSupportedLocale(parse(Intl.getCurrentLocale()));

  /// [Locale] initial, changing it later does not
  /// change the current [Locale].
  final Locale initialLocale;

  /// Builders the widget every time that a new [Locale] is set.
  final LocaleBuilder builder;

  /// It's called every time when a new different [Locale] is set.
  final OnChangeLocale? onChangeLocale;

  @override
  State<AppLocale> createState() => _AppLocaleState();

  /// Gets the [LocaleData].
  static LocaleData of(BuildContext context) {
    final inheritedLocale =
        context.dependOnInheritedWidgetOfExactType<_InheritedLocaleData>();
    if (inheritedLocale != null) {
      return inheritedLocale.localeData;
    }
    throw FlutterError(
      '''
        AppLocale.of() called with a context that does not contain a $AppLocale.        
        This can happen if the context you used comes from a widget above the AppLocale.
        The context used was: $context
      ''',
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        EnumProperty('defaultLocale', initialLocale),
      )
      ..add(
        ObjectFlagProperty<LocaleBuilder>.has('builder', builder),
      )
      ..add(
        ObjectFlagProperty<OnChangeLocale>.has(
          'onChangeLocale',
          onChangeLocale,
        ),
      );
  }

  static Locale parse(String string) {
    List<String> tags = string.split('_');
    String language = tags.first;
    String? country = tags.length >= 2 ? tags[1] : null;
    return Locale(language, country);
  }

  static Locale determineClosestSupportedLocale(Locale locale) {
    List<Locale> supportedLocales = AppLocalizations.supportedLocales;
    if (supportedLocales.contains(locale)) {
      return locale;
    }
    Locale? countryMatch;
    Locale? languageMatch;
    for (Locale supported in supportedLocales) {
      if (locale.languageCode == supported.languageCode) {
        languageMatch = supported;
        if (locale.countryCode == supported.countryCode) {
          countryMatch = supported;
        }
      }
    }
    Locale? closestMatch = countryMatch ?? languageMatch;
    if (closestMatch != null) {
      return closestMatch;
    }
    return supportedLocales.first;
  }
}

class _AppLocaleState extends State<AppLocale> {
  late LocaleData _localeData = LocaleData(
    locale: widget.initialLocale,
    setLocale: _setLocale,
  );

  Locale get _currentLocale => _localeData.locale;

  @override
  Widget build(BuildContext context) {
    return _InheritedLocaleData(
      localeData: _localeData,
      child: widget.builder(context, _currentLocale),
    );
  }

  void _setLocale(Locale locale) {
    if (_currentLocale != locale) {
      widget.onChangeLocale?.call(locale);
      setState(
        () => _localeData = _localeData.copyWith(
          locale: locale,
        ),
      );
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty('locale', _currentLocale));
  }
}

class _InheritedLocaleData extends InheritedWidget {
  const _InheritedLocaleData({
    required this.localeData,
    required super.child,
  });

  final LocaleData localeData;

  @override
  bool updateShouldNotify(_InheritedLocaleData oldWidget) =>
      localeData.locale != oldWidget.localeData.locale;
}
