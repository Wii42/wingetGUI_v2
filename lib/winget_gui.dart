import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
// import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';

import 'main_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await flutter_acrylic.Window.initialize();
  await WindowManager.instance.ensureInitialized();
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setMinimumSize(const Size(400, 500));
  });
  runApp(const WingetGui());
}

class WingetGui extends StatelessWidget {
  const WingetGui({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'WingetGUI',
      theme: FluentThemeData(
        //accentColor: SystemTheme.accentColor.accent.toAccentColor(),
        brightness: Brightness.light,
      ),
      darkTheme: FluentThemeData(
        //accentColor: SystemTheme.accentColor.accent.toAccentColor(),
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      //supportedLocales: const [Locale("en")],
      home: const Acrylic(child: MainPage(title: "WingetGUI")),
    );
  }
}
