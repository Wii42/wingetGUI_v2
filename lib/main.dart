import 'package:app_theme_mode/app_theme_mode.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:go_router/go_router.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:winget_gui/helpers/settings_cache.dart';
import 'package:winget_gui/main_navigation.dart';
import 'package:winget_gui/routes.dart';
import 'package:winget_gui/widget_assets/app_locale.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await flutter_acrylic.Window.initialize();
  await WindowManager.instance.ensureInitialized();
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setMinimumSize(const Size(460, 300));
  });
  SettingsCache settings = SettingsCache.instance;
  await settings.init();
  runApp(WingetGui());
}

class WingetGui extends StatelessWidget {
  final String appTitle = 'WingetGUI';
  WingetGui({super.key});

  @override
  Widget build(BuildContext context) {
    return AppThemeMode(
      initialThemeMode: SettingsCache.instance.themeMode,
      builder: (BuildContext context, ThemeMode themeMode) {
        return AppLocale(
          initialGuiLocale: SettingsCache.instance.guiLocale,
          initialWingetLocale: SettingsCache.instance.wingetLocale,
          builder: (BuildContext context, Locale? guiLocale, Locale? _) {
            return FluentApp(
              locale: guiLocale,
              title: appTitle,
              theme: FluentThemeData(
                accentColor: SystemTheme.accentColor.accent.toAccentColor(),
                brightness: Brightness.light,
              ),
              darkTheme: FluentThemeData(
                accentColor: SystemTheme.accentColor.accent.toAccentColor(),
                brightness: Brightness.dark,
              ),
              themeMode: themeMode,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: MainNavigation(title: appTitle),
              //routerConfig: router,
              //supportedLocales: const [Locale("en")],
            );
          },
        );
      },
    );
  }

  final GoRouter router = GoRouter(
    routes: [
      ShellRoute(
        routes: [
          for (Routes route in Routes.values)
            GoRoute(
              path: route.route,
              builder: (context, state) {
                return route.buildPage();
              },
            ),
        ],
        builder: (context, state, widget) {
          return MainNavigation(
            title: '',
            //child: widget,
          );
        },
      ),
    ],
    initialLocation: Routes.help.route,
  );
}
