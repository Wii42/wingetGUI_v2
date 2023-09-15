import 'package:app_theme_mode/app_theme_mode.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:system_theme/system_theme.dart';
import 'package:winget_gui/widget_assets/app_locale.dart';

import 'helpers/settings_cache.dart';

class GlobalAppData extends StatelessWidget {
  final Widget Function(BuildContext context, ThemeMode themeMode,
      Locale? guiLocale, SystemAccentColor systemAccentColor) builder;
  const GlobalAppData({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    SettingsCache settings = SettingsCache.instance;
    return AppThemeMode(
      initialThemeMode: settings.themeMode,
      onChangeThemeMode: (ThemeMode? themeMode) {
        settings.themeMode = themeMode;
      },
      builder: (BuildContext context, ThemeMode themeMode) {
        return AppLocale(
          initialGuiLocale: settings.guiLocale,
          onChangeGuiLocale: (Locale? guiLocale) {
            settings.guiLocale = guiLocale;
          },
          initialWingetLocale: settings.wingetLocale,
          onChangeWingetLocale: (Locale? wingetLocale) {
            settings.wingetLocale = wingetLocale;
          },
          builder: (BuildContext context, Locale? guiLocale, Locale? _) {
            return StreamBuilder<SystemAccentColor>(
              stream: SystemTheme.onChange,
              builder: (context, snapshot) {
                SystemAccentColor systemAccentColor =
                    snapshot.data ?? SystemTheme.accentColor;
                return builder(
                    context, themeMode, guiLocale, systemAccentColor);
              },
            );
          },
        );
      },
    );
  }
}
