import 'package:flutter_gen/gen_l10n/app_localizations.dart';
enum InstallMode {
  interactive(key: 'interactive'),
  silent(key: 'silent'),
  silentWithProgress(key: 'silentWithProgress');

  final String key;
  const InstallMode({required this.key});

  factory InstallMode.fromYaml(dynamic string) {
    return maybeParse(string)!;
  }

  static InstallMode parse(String string) {
    return maybeParse(string)!;
  }

  static InstallMode? maybeParse(String? mode){
    if(mode == null){
      return null;
    }
    for(InstallMode m in InstallMode.values){
      if(m.key == mode){
        return m;
      }
    }
    throw ArgumentError('Unknown mode: $mode');
  }

  String title(AppLocalizations locale){
    return locale.installMode(key);
  }
}
