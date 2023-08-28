import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:go_router/go_router.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:winget_gui/main_navigation.dart';
import 'package:winget_gui/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await flutter_acrylic.Window.initialize();
  await WindowManager.instance.ensureInitialized();
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setMinimumSize(const Size(460, 300));
  });
  runApp(WingetGui());
}

class WingetGui extends StatelessWidget {
  WingetGui({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'WingetGUI',
      theme: FluentThemeData(
        accentColor: SystemTheme.accentColor.accent.toAccentColor(),
        brightness: Brightness.light,
      ),
      darkTheme: FluentThemeData(
        accentColor: SystemTheme.accentColor.accent.toAccentColor(),
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MainNavigation(title: "WingetGUI"),
      //routerConfig: router,
      //supportedLocales: const [Locale("en")],
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
