import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';

import 'db/db_message.dart';
import 'db/package_db.dart';
import 'db/package_tables.dart';
import 'global_app_data.dart';
import 'helpers/package_screenshots_list.dart';
import 'helpers/settings_cache.dart';
import 'main_navigation.dart';
import 'output_handling/one_line_info_builder.dart';
import 'output_handling/one_line_info_parser.dart';
import 'package_actions_notifier.dart';
import 'widget_assets/loading_widget.dart';
import 'winget_process/winget_process_scheduler.dart';

const String appTitle = 'WingetGUI';

void main() async {
  await initAppPrerequisites();
  await PackageScreenshotsList.instance.fetchScreenshots();
  await PackageDB.instance.ensureInitialized();
  runApp(const WingetGui());
}

Future<void> initAppPrerequisites() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  await Future.wait([
    Window.initialize().then((_) async => await Future.wait([
          Window.setEffect(effect: WindowEffect.mica),
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
      builder: (context, _) {
        SystemAccentColor systemAccentColor =
            context.watch<SystemAccentColor>();
        ThemeMode themeMode = context.watch<AppThemeMode>().value;
        Locale? guiLocale = context.watch<AppLocales>().guiLocale;
        return FluentApp(
          title: appTitle,
          theme: theme(Brightness.light, systemAccentColor.dark),
          darkTheme: theme(Brightness.dark, systemAccentColor.light),
          themeMode: themeMode,
          locale: guiLocale,
          localizationsDelegates: const [
            ...AppLocalizations.localizationsDelegates,
            LocaleNamesLocalizationsDelegate()
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: ChangeNotifierProvider(
            create: (context) => PackageActionsNotifier(),
            child: const WindowBrightnessSetter(
              child: MainWidget(),
            ),
          ),
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

class MainWidget extends StatelessWidget {
  const MainWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        DBInitializer(),
        ProcessSchedulerWarnings(), //PackageActionsList(),
      ],
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

class DBInitializer extends StatelessWidget {
  const DBInitializer({super.key, required});

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return PackageTables.instance.isReady()
        ? MainNavigation(title: appTitle)
        : StreamBuilder<LocalizedString>(
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                if (snapshot.hasData) {
                  return LoadingWidget(text: snapshot.data!);
                }
                return const Center(child: Text('...'));
              }
              return PackageTables.instance.isReady()
                  ? MainNavigation(title: appTitle)
                  : Center(
                      child: Text(snapshot.hasData
                          ? snapshot.data!(locale)
                          : snapshot.error?.toString() ??
                              locale.errorOccurred));
            },
            stream: PackageTables.instance.init(context),
          );
  }
}

class ProcessSchedulerWarnings extends StatelessWidget {
  const ProcessSchedulerWarnings({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return StreamBuilder<int>(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data! > 0) {
            return Positioned(
              child: OneLineInfoWidget(OneLineInfo(
                  title: locale.warning,
                  details: locale.processesQueued(snapshot.data!),
                  severity: InfoBarSeverity.warning)),
            );
          }
        }
        return const SizedBox();
      },
      stream: ProcessScheduler.instance.queueLengthStream,
    );
  }
}
