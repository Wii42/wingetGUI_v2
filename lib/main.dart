import 'package:fluent_ui/fluent_ui.dart';
// 'package:system_theme/system_theme.dart';

import 'main_page.dart';

void main() {
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
      home: const MainPage(title: "WingetGUI"),
    );
  }
}
