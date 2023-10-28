import 'package:flutter_gen/gen_l10n/app_localizations.dart';
enum InstallScope{
  user(key: 'user'),machine(key: 'machine');

  final String key;
  const InstallScope({required this.key});

  String title(AppLocalizations locale){
    switch(this){
      case InstallScope.user:
        return locale.userScope;
      case InstallScope.machine:
        return locale.machineScope;
    }
  }

  factory InstallScope.fromYaml(dynamic string) {
    return maybeParse(string)!;
  }

  factory InstallScope.parse(String string) {
    return maybeParse(string)!;
  }

  static InstallScope? maybeParse(String? scope){
    if(scope == null){
      return null;
    }
    for(InstallScope s in InstallScope.values){
      if(s.key == scope){
        return s;
      }
    }
    throw ArgumentError('Unknown scope: $scope');
  }
}