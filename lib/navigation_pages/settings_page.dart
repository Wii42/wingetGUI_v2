import 'package:app_theme_mode/app_theme_mode.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/winget_process.dart';

import '../helpers/route_parameter.dart';
import '../routes.dart';
import '../widget_assets/app_locale.dart';
import '../widget_assets/decorated_box_wrap.dart';
import '../widget_assets/pane_item_body.dart';
import '../winget_commands.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  factory SettingsPage.inRoute([RouteParameter? _]) => const SettingsPage();

  @override
  State<StatefulWidget> createState() => _SettingsPageSate();
}

class _SettingsPageSate extends State<SettingsPage> {
  ThemeMode? themeMode;
  Locale? locale;
  Locale? wingetLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    locale = AppLocale.of(context).guiLocale;
    themeMode = AppThemeMode.of(context).themeMode;
    wingetLocale = AppLocale.of(context).wingetLocale;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return PaneItemBody(
      title: Routes.settingsPage.title(localizations),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            settingsItem(
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
            ),
            settingsItem(
              localizations.chooseLanguage,
              ComboBox<Locale>(
                value: locale,
                onChanged: (value) {
                  setState(() {
                    locale = value;
                    if (locale != null) {
                      AppLocale.of(context).setGuiLocale(locale!);
                    }
                  });
                },
                items: [
                  for (Locale locale in AppLocalizations.supportedLocales)
                    ComboBoxItem<Locale>(
                      value: locale,
                      child: Text(locale.toLanguageTag()),
                    ),
                ],
              ),
            ),
            settingsItem(
              localizations.chooseWingetLanguage,
              ComboBox<Locale>(
                value: wingetLocale,
                onChanged: (value) {
                  setState(() {
                    wingetLocale = value;
                    if (wingetLocale != null) {
                      AppLocale.of(context).setWingetLocale(wingetLocale!);
                    }
                  });
                },
                items: [
                  for (Locale language in AppLocalizations.supportedLocales)
                    ComboBoxItem<Locale>(
                      value: language,
                      child: Text(language.toLanguageTag()),
                    ),
                ],
              ),
            ),
            settingsItem(
                Winget.settings.title(localizations),
                Button(
                  onPressed: () {
                    WingetProcess.runWinget(Winget.settings);
                  },
                  child: Text(localizations.openWingetSettingsFile),
                ))
          ].withSpaceBetween(height: 10),
        ),
      ),
    );
  }

  Widget settingsItem(String title, Widget options) {
    return DecoratedBoxWrap(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [Expanded(child: Text(title)), options],
        ),
      ),
    );
  }
}
