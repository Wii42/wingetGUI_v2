import 'package:app_theme_mode/app_theme_mode.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/helpers/settings_cache.dart';
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
    return PaneItemBody(
      title: Routes.settingsPage.title(localizations),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            themeModeOption(localizations, context),
            guiLocaleOption(localizations, context),
            wingetLocaleOption(localizations, context),
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
              SettingsCache.instance.themeMode = themeMode;
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
            SettingsCache.instance.guiLocale = guiLocale;
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
            SettingsCache.instance.wingetLocale = wingetLocale;
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
