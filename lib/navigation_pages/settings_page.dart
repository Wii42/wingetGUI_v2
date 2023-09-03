import 'package:app_theme_mode/app_theme_mode.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/winget_process.dart';

import '../helpers/route_parameter.dart';
import '../routes.dart';
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
  Locale? language;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    language = Localizations.localeOf(context);
    themeMode = AppThemeMode.of(context).themeMode;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return PaneItemBody(
      title: Routes.settingsPage.title(locale),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            settingsItem(
              locale.chooseDisplayMode,
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
                      child: Text(locale.themeMode(themeMode.name)),
                    ),
                ],
              ),
            ),
            settingsItem(
              locale.chooseLanguage,
              ComboBox<Locale>(
                value: language,
                onChanged: (value) {
                  setState(() {
                    language = value;
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
                Winget.settings.title(locale),
                Button(
                  onPressed: () {
                    WingetProcess.runWinget(Winget.settings);
                  },
                  child: Text(locale.openWingetSettingsFile),
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
