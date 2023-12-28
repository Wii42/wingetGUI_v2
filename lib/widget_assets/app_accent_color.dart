import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';

/// When the theme mode is changed.
typedef OnChangeAccentColor = void Function(SystemAccentColor accentColor);

/// Builders the widget with the base in the [ThemeMode].
typedef AccentColorBuilder = Widget Function(
    BuildContext context,
    SystemAccentColor accentColor,
    );

/// {@template theme_mode_data}
/// Class with actions to manipulate [ThemeMode].
/// {@endtemplate}
@immutable
@visibleForTesting
class AccentColorData {
  /// {@macro theme_mode_data}
  const AccentColorData({
    required this.accentColor,
    required this.setAccentColor,
  });

  /// Gets the current [ThemeMode].
  final SystemAccentColor accentColor;

  /// Changes [ThemeMode].
  final OnChangeAccentColor setAccentColor;

  /// Create a new [AccentColorData] based in other.
  AccentColorData copyWith({
    SystemAccentColor? accentColor,
    OnChangeAccentColor? setAccentColor,
  }) {
    return AccentColorData(
      accentColor: accentColor ?? this.accentColor,
      setAccentColor: setAccentColor ?? this.setAccentColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AccentColorData &&
        other.accentColor == accentColor &&
        other.setAccentColor == setAccentColor;
  }

  @override
  int get hashCode => Object.hashAll([accentColor, setAccentColor]);
}

/// {@template app_theme_mode}
/// Provides access to [AccentColorData] in its descendant widgets to
/// manage your [ThemeMode]. Rebuilds every time that a new [ThemeMode] is set.
/// {@endtemplate}
class AppAccentColor extends StatefulWidget {
  /// {@macro app_theme_mode}
  AppAccentColor({
    required this.builder,
    this.onChangeAccentColor,
    SystemAccentColor? accentColor,
    super.key,
  }) : initialAccentColor = accentColor?? SystemAccentColor(SystemTheme.fallbackColor);

  /// [ThemeMode] initial, changing it later does not
  /// change the current [ThemeMode].
  final SystemAccentColor initialAccentColor;

  /// Builders the widget every time that a new [ThemeMode] is set.
  final AccentColorBuilder builder;

  /// It's called every time when a new different [ThemeMode] is set.
  final OnChangeAccentColor? onChangeAccentColor;

  @override
  State<AppAccentColor> createState() => _AppAccentColorState();

  /// Gets the [AccentColorData].
  static AccentColorData of(BuildContext context) {
    final inheritedAccentColor =
    context.dependOnInheritedWidgetOfExactType<_InheritedAccentColorData>();
    if (inheritedAccentColor != null) {
      return inheritedAccentColor.accentColorData;
    }
    throw FlutterError(
      '''
        AppAccentColor.of() called with a context that does not contain a $AppAccentColor.        
        This can happen if the context you used comes from a widget above the AppThemeMode.
        The context used was: $context
      ''',
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      //..add(
        //EnumProperty('defaultThemeMode', initialAccentColor),
      //)
      ..add(
        ObjectFlagProperty<AccentColorBuilder>.has('builder', builder),
      )
      ..add(
        ObjectFlagProperty<OnChangeAccentColor>.has(
          'onChangeThemeMode',
          onChangeAccentColor,
        ),
      );
  }
}

class _AppAccentColorState extends State<AppAccentColor> {
  late AccentColorData _accentColorData = AccentColorData(
    accentColor: widget.initialAccentColor,
    setAccentColor: _setThemeMode,
  );

  SystemAccentColor get _currentAccentColor => _accentColorData.accentColor;

  @override
  Widget build(BuildContext context) {
    return _InheritedAccentColorData(
      accentColorData: _accentColorData,
      child: widget.builder(context, _currentAccentColor),
    );
  }

  void _setThemeMode(SystemAccentColor accentColor) {
    if (_currentAccentColor != accentColor) {
      widget.onChangeAccentColor?.call(accentColor);
      setState(
            () => _accentColorData = _accentColorData.copyWith(
          accentColor: accentColor,
        ),
      );
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    //properties.add(EnumProperty('themeMode', _currentAccentColor));
  }
}

class _InheritedAccentColorData extends InheritedWidget {
  const _InheritedAccentColorData({
    required this.accentColorData,
    required super.child,
  });

  final AccentColorData accentColorData;

  @override
  bool updateShouldNotify(_InheritedAccentColorData oldWidget) =>
      accentColorData.accentColor != oldWidget.accentColorData.accentColor;
}
