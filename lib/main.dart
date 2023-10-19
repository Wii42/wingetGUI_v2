import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:winget_gui/helpers/settings_cache.dart';
import 'package:winget_gui/main_navigation.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_peek.dart';

import 'global_app_data.dart';
import 'helpers/package_screenshots_list.dart';

const String appTitle = 'WingetGUI';

void main() async {
  await initAppPrerequisites();
  PackageScreenshotsList.instance.fetchScreenshots().then((_) {
    PackageScreenshotsList.instance.getPackage(PackageInfosPeek());
  });
  runApp(const WingetGui());
}

Future<void> initAppPrerequisites() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    Window.initialize().then((_) async => await Future.wait([
          Window.setEffect(effect: WindowEffect.mica),
          Window.setWindowBackgroundColorToClear(),
        ])),
    WindowManager.instance.ensureInitialized().then((_) async =>
        await WindowManager.instance
            .waitUntilReadyToShow()
            .then((_) async => await Future.wait([
                  WindowManager.instance.setTitle(appTitle),
                  WindowManager.instance.setMinimumSize(const Size(460, 300)),
                  WindowManager.instance.setAlignment(Alignment.center),
                ]))),
    SystemTheme.accentColor.load(),
    SettingsCache.instance.ensureInitialized(),
    PackageScreenshotsList.instance.ensureInitialized(),
  ]);
}

class WingetGui extends StatelessWidget {
  const WingetGui({super.key});

  @override
  Widget build(BuildContext context) {
    return GlobalAppData(
      builder: (context, themeMode, guiLocale, systemAccentColor) {
        return FluentApp(
          title: appTitle,
          theme: theme(Brightness.light, systemAccentColor.dark),
          darkTheme: theme(Brightness.dark, systemAccentColor.light),
          themeMode: themeMode,
          locale: guiLocale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: WindowBrightnessSetter(child: MainNavigation(title: appTitle)),
        );
      },
    );
  }

  static FluentThemeData theme(Brightness brightness, Color accentColor) {
    return FluentThemeData(
      scaffoldBackgroundColor: Colors.transparent,
      accentColor: accentColor.toAccentColor(),
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
