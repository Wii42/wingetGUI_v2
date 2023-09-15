import 'package:app_theme_mode/app_theme_mode.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:winget_gui/helpers/settings_cache.dart';
import 'package:winget_gui/main_navigation.dart';
import 'package:winget_gui/widget_assets/app_locale.dart';

const String appTitle = 'WingetGUI';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();
  await Window.setEffect(effect: WindowEffect.mica);
  await Window.setWindowBackgroundColorToClear();
  await WindowManager.instance.ensureInitialized();
  await windowManager.waitUntilReadyToShow().then(
        (_) => Future.wait(
          [
            windowManager.setTitle(appTitle),
            windowManager.setMinimumSize(const Size(460, 300)),
            windowManager.setAlignment(Alignment.center),
          ],
        ),
      );

  SettingsCache settings = SettingsCache.instance;
  await settings.init();
  runApp(WingetGui());
}

class WingetGui extends StatelessWidget {
  final FluentThemeData lightTheme = theme(Brightness.light);
  final FluentThemeData darkTheme = theme(Brightness.dark);

  WingetGui({super.key});

  @override
  Widget build(BuildContext context) {
    WindowManager.instance.setTitle(appTitle);
    return GlobalAppData(
      builder: (context, themeMode, guiLocale) {
        return FluentApp(
          title: appTitle,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          locale: guiLocale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: WindowBrightnessSetter(child: MainNavigation(title: appTitle)),
        );
      },
    );
  }

  static FluentThemeData theme(Brightness brightness) {
    return FluentThemeData(
      scaffoldBackgroundColor: Colors.transparent,
      accentColor: SystemTheme.accentColor.dark.toAccentColor(),
      brightness: brightness,
      navigationPaneTheme: const NavigationPaneThemeData(
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

class WindowBrightnessSetter extends StatelessWidget {
  final Widget child;
  const WindowBrightnessSetter({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    Brightness brightness = FluentTheme.of(context).brightness;
    WindowManager.instance.setBrightness(brightness);
    return child;
  }
}

class GlobalAppData extends StatelessWidget {
  final Widget Function(
      BuildContext context, ThemeMode themeMode, Locale? guiLocale) builder;
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
              builder: (BuildContext context, Locale? guiLocale, Locale? _) =>
                  builder(context, themeMode, guiLocale));
        });
  }
}
