import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';

import 'helpers/settings_cache.dart';

class GlobalAppData extends StatelessWidget {
  final Widget Function(BuildContext context, Widget? _) builder;
  const GlobalAppData({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    SettingsCache settings = SettingsCache.instance;
    return MultiProvider(providers: [
      ChangeNotifierProvider(
        create: (_) => AppLocales(
            initialGuiLocale: settings.guiLocale,
            initialWingetLocale: settings.wingetLocale),
      ),
      ChangeNotifierProvider(
          create: (_) => AppThemeMode(settings.themeMode ?? ThemeMode.system)),
      StreamProvider<SystemAccentColor>(
          create: (_) => SystemTheme.onChange,
          initialData: SystemTheme.accentColor),
    ], builder: builder);
  }
}

class AppLocales extends ChangeNotifier {
  Locale? _guiLocale;
  Locale? _wingetLocale;

  AppLocales({Locale? initialGuiLocale, Locale? initialWingetLocale}) {
    _guiLocale = initialGuiLocale;
    _wingetLocale = initialWingetLocale;
  }

  Locale? get guiLocale => _guiLocale;
  Locale? get wingetLocale => _wingetLocale;

  set guiLocale(Locale? locale) {
    if (_guiLocale != locale) {
      _guiLocale = locale;
      notifyListeners();
    }
  }

  set wingetLocale(Locale? locale) {
    if (_wingetLocale != locale) {
      _wingetLocale = locale;
      notifyListeners();
    }
  }

  static AppLocales of(BuildContext context) {
    return Provider.of<AppLocales>(context, listen: false);
  }

  AppLocalizations? getWingetAppLocalization() {
    if (wingetLocale == null) {
      return null;
    }
    return lookupAppLocalizations(wingetLocale!);
  }

  AppLocalizations? getGuiAppLocalization() {
    if (guiLocale == null) {
      return null;
    }
    return lookupAppLocalizations(guiLocale!);
  }
}

class AppThemeMode extends ValueNotifier<ThemeMode> {
  AppThemeMode(super.value);

  static AppThemeMode of(BuildContext context) {
    return Provider.of<AppThemeMode>(context, listen: false);
  }
}
