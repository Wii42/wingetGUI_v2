import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:winget_gui/global_app_data.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/helpers/route_parameter.dart';
import 'package:winget_gui/routes.dart';
import 'package:winget_gui/widget_assets/decorated_card.dart';
import 'package:winget_gui/widget_assets/pane_item_body.dart';
import 'package:winget_gui/winget_commands.dart';
import 'package:winget_gui/winget_process/winget_process.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart'
    as fluent_icons;

import 'package:winget_gui/widget_assets/custom_combo_box.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  factory SettingsPage.inRoute([RouteParameter? _]) => const SettingsPage();

  @override
  State<StatefulWidget> createState() => _SettingsPageSate();

  static Widget settingsItem(String title, Widget options) {
    return DecoratedCard(
      padding: 20,
      child: Row(
        children: [Expanded(child: Text(title)), options],
      ),
    );
  }
}

class _SettingsPageSate extends State<SettingsPage> {
  ThemeMode? themeMode;
  Locale? guiLocale;
  Locale? wingetLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppLocales appLocales = AppLocales.of(context);
    guiLocale = appLocales.guiLocale;
    themeMode = AppThemeMode.of(context).value;
    wingetLocale = appLocales.wingetLocale;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return PaneItemBody(
      title: Routes.settingsPage.title(localizations),
      child: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          themeModeOption(localizations, context),
          guiLocaleOption(localizations, context),
          wingetLocaleOption(localizations, context),
          SettingsPage.settingsItem(
            Winget.settings.title(localizations),
            Button(
              onPressed: () {
                WingetProcess.fromWinget(Winget.settings);
              },
              child: Text(localizations.openWingetSettingsFile),
            ),
          ),
        ].withSpaceBetween(height: 10),
      ),
    );
  }

  Widget themeModeOption(AppLocalizations localizations, BuildContext context) {
    IconData themeModeIcon(ThemeMode mode) => switch (mode) {
          ThemeMode.system => fluent_icons.FluentIcons.dark_theme_24_filled,
          ThemeMode.light => FluentIcons.brightness,
          ThemeMode.dark => FluentIcons.clear_night,
        };
    return SettingsPage.settingsItem(
      localizations.chooseDisplayMode,
      CustomComboBox<ThemeMode>(
        value: themeMode,
        onChanged: (mode) {
          setState(() {
            themeMode = mode;
            if (themeMode != null) {
              AppThemeMode.of(context).value = themeMode!;
            }
          });
        },
        items: [
          for (ThemeMode themeMode in ThemeMode.values)
            ComboBoxItem<ThemeMode>(
              value: themeMode,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(themeModeIcon(themeMode), size: 12),
                  const SizedBox(width: 10),
                  Text(localizations.themeMode(themeMode.name)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget guiLocaleOption(AppLocalizations localizations, BuildContext context) {
    return SettingsPage.settingsItem(
      localizations.chooseLanguage,
      CustomComboBox<Locale>(
        value: guiLocale,
        placeholder: Text(localizations.autoLanguage),
        onChanged: (value) {
          setState(() {
            guiLocale = value;
            AppLocales.of(context).guiLocale = guiLocale;
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
    return SettingsPage.settingsItem(
      localizations.chooseWingetLanguage,
      CustomComboBox<Locale>(
        value: wingetLocale,
        placeholder: Text(localizations.autoLanguage),
        onChanged: (value) {
          setState(() {
            wingetLocale = value;
            AppLocales.of(context).wingetLocale = wingetLocale;
          });
        },
        items: [
          for (Locale language in AppLocalizations.supportedLocales)
            languageItem(language),
        ],
      ),
    );
  }
}
