import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:winget_gui/helpers/settings_cache.dart';
import 'package:winget_gui/l10n/generated/app_localizations.dart';
import 'package:winget_gui/winget_client/ps_client/powershell_winget_client.dart';
import 'package:winget_gui/winget_client/winget_client.dart';
import 'package:winget_gui/winget_client/cli_winget/cli_winget_client.dart';


class GlobalAppData extends StatelessWidget {
  final Widget Function(BuildContext context, Widget? _) builder;

  const GlobalAppData({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    SettingsCache settings = SettingsCache.instance;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppLocales>(
          create:
              (_) => AppLocales(
                initialGuiLocale: settings.guiLocale,
                initialWingetLocale: settings.wingetLocale,
              ),
        ),
        ChangeNotifierProvider<AppThemeMode>(
          create: (_) => AppThemeMode(settings.themeMode ?? ThemeMode.system),
        ),
        StreamProvider<SystemAccentColor>(
          create: (_) => SystemTheme.onChange,
          initialData: SystemTheme.accentColor,
        ),
        ProxyProvider<AppLocales, WingetClient>(
          update: (_, AppLocales value, WingetClient? previous) {
            AppLocalizations wingetLocale = value.getWingetAppLocalization() ?? AppLocalizations.of(context)!;
            if (previous == null || previous is! CliWingetClient) {
              return PowershellWingetClient();
            }
            if (previous.wingetLocale != wingetLocale) {
              return previous..wingetLocale = wingetLocale;
            }
            return previous;

          }
        ),
      ],
      builder: builder,
    );
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
      SettingsCache.instance.guiLocale = locale;
      notifyListeners();
    }
  }

  set wingetLocale(Locale? locale) {
    if (_wingetLocale != locale) {
      _wingetLocale = locale;
      SettingsCache.instance.wingetLocale = locale;
      if (locale != null) {
        //PackageTables.instance.reloadDBs(lookupAppLocalizations(locale));
      }
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

  @override
  set value(ThemeMode themeMode) {
    super.value = themeMode;
    SettingsCache.instance.themeMode = themeMode;
  }
}
