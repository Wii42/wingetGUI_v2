import 'package:app_theme_mode/app_theme_mode.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/helpers/package_screenshots_list.dart';
import 'package:winget_gui/winget_process/winget_process.dart';

import '../helpers/route_parameter.dart';
import '../output_handling/output_handler.dart';
import '../routes.dart';
import '../widget_assets/app_locale.dart';
import '../widget_assets/decorated_card.dart';
import '../widget_assets/pane_item_body.dart';
import '../winget_commands.dart';
import '../winget_db/winget_db.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  factory SettingsPage.inRoute([RouteParameter? _]) => const SettingsPage();

  @override
  State<StatefulWidget> createState() => _SettingsPageSate();
}

class _SettingsPageSate extends State<SettingsPage> {
  ThemeMode? themeMode;
  Locale? guiLocale;
  Locale? wingetLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    guiLocale = AppLocale.of(context).guiLocale;
    themeMode = AppThemeMode.of(context).themeMode;
    wingetLocale = AppLocale.of(context).wingetLocale;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    AppLocalizations wingetLocale = OutputHandler.getWingetLocale(context);
    return PaneItemBody(
      title: Routes.settingsPage.title(localizations),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            themeModeOption(localizations, context),
            guiLocaleOption(localizations, context),
            wingetLocaleOption(localizations, context),
            settingsItem(
              Winget.settings.title(localizations),
              Button(
                onPressed: () {
                  WingetProcess.fromWinget(Winget.settings);
                },
                child: Text(localizations.openWingetSettingsFile),
              ),
            ),
            buildDBSettings(wingetLocale),
            screenshotSettings(),
          ].withSpaceBetween(height: 10),
        ),
      ),
    );
  }

  Widget buildDBSettings(AppLocalizations wingetLocale) {
    return settingsItem(
      'WingetDB',
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Button(
            onPressed: () async {
              WingetDB.instance.updates.reloadFuture(wingetLocale);
            },
            child: const Text('Reload updates'),
          ),
          Button(
            onPressed: () {
              WingetDB.instance.updates.removeAllInfos();
            },
            child: const Text('Remove all updates'),
          ),
        ].withSpaceBetween(height: 20),
      ),
    );
  }

  Widget themeModeOption(AppLocalizations localizations, BuildContext context) {
    return settingsItem(
      localizations.chooseDisplayMode,
      ComboBox<ThemeMode>(
        value: themeMode,
        onChanged: (mode) {
          setState(() {
            themeMode = mode;
            if (themeMode != null) {
              AppThemeMode.of(context).setThemeMode(themeMode!);
            }
          });
        },
        items: [
          for (ThemeMode themeMode in ThemeMode.values)
            ComboBoxItem<ThemeMode>(
              value: themeMode,
              child: Text(localizations.themeMode(themeMode.name)),
            ),
        ],
      ),
    );
  }

  Widget guiLocaleOption(AppLocalizations localizations, BuildContext context) {
    return settingsItem(
      localizations.chooseLanguage,
      ComboBox<Locale>(
        value: guiLocale,
        placeholder: Text(localizations.autoLanguage),
        onChanged: (value) {
          setState(() {
            guiLocale = value;
            AppLocale.of(context).setGuiLocale(guiLocale);
          });
        },
        items: [
          for (Locale locale in AppLocalizations.supportedLocales)
            languageItem(locale),
        ],
      ),
    );
  }

  ComboBoxItem<Locale> languageItem(Locale locale) {
    LocaleNames localeNames = LocaleNames.of(context)!;
    return ComboBoxItem<Locale>(
      value: locale,
      child: Text(
          "${localeNames.nameOf(locale.toLanguageTag())} (${locale.toString()})"),
    );
  }

  Widget wingetLocaleOption(
      AppLocalizations localizations, BuildContext context) {
    return settingsItem(
      localizations.chooseWingetLanguage,
      ComboBox<Locale>(
        value: wingetLocale,
        placeholder: Text(localizations.autoLanguage),
        onChanged: (value) {
          setState(() {
            wingetLocale = value;
            AppLocale.of(context).setWingetLocale(wingetLocale);
          });
        },
        items: [
          for (Locale language in AppLocalizations.supportedLocales)
            languageItem(language),
        ],
      ),
    );
  }

  Widget settingsItem(String title, Widget options) {
    return DecoratedCard(
      padding: 20,
      child: Row(
        children: [Expanded(child: Text(title)), options],
      ),
    );
  }

  Widget screenshotSettings() {
    PackageScreenshotsList screenshots = PackageScreenshotsList.instance;
    return settingsItem(
      'Screenshots/Icons',
      Column(
        children: [
          Button(
            onPressed: () {
              screenshots.reloadPublisherIcons();
            },
            child: const Text('Reload Publisher Icons'),
          ),
          Button(
            onPressed: () {
              screenshots.reloadCustomIcons();
            },
            child: const Text('Reload Custom Icons'),
          ),
        ].withSpaceBetween(height: 20),
      ),
    );
  }
}
