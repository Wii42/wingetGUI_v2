import 'package:winget_gui/output_handling/output_scanner.dart';
import 'package:winget_gui/output_handling/package_infos/package_attribute.dart';
import 'package:winget_gui/output_handling/show/show_parser.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ShowScanner extends OutputScanner {
  List<String> command;
  List<String>? prevCommand;

  ShowScanner(super.respList, {required this.command, this.prevCommand});

  @override
  void markResponsibleLines(AppLocalizations wingetLocale) {
    if (respList.isEmpty || command.isEmpty) //||
    //command[0] != Winget.show.command[0])
    {
      return;
    }
    int identifierPos = _findIdentifier(wingetLocale);
    if (identifierPos > -1) {
      ShowParser showPart = ShowParser([]);
      for (int i = identifierPos; i < respList.length; i++) {
        if (respList[i].isHandled()) {
          break;
        }
        showPart.addLine(respList[i].line);
        respList[i].respPart = showPart;
      }
    }
  }

  int _findIdentifier(AppLocalizations wingetLocale) {
    for (int i = 0; i < respList.length; i++) {
      if (!respList[i].isHandled() &&
              (_isIdentifier(respList[i].line, command, wingetLocale)) ||
          (prevCommand != null &&
              _isIdentifier(respList[i].line, prevCommand!, wingetLocale))) {
        return i;
      }
    }
    return -1;
  }

  bool _isIdentifier(
      String line, List<String> command, AppLocalizations locale) {
    line = line.trim();
    if (!line.startsWith(locale.packageLongInfoIdentifier)) {
      return false;
    }
    line = line.toLowerCase();
    if (command.contains('--id')) {
      String id = command[command.indexOf('--id') + 1].toLowerCase();
      return (line.endsWith('[$id]') ||
          line.contains(
              '[$id] ${locale.infoKey(PackageAttribute.version.name)}'.toLowerCase()));
    }

    if (command.contains('--name')) {
      String name = command[command.indexOf('--name') + 1].toLowerCase();
      return (line.contains(name));
    }

    String? name = _findNameInCommand()?.toLowerCase();
    if (name != null) {
      return (line.contains(name) || line.endsWith('[$name]'));
    }

    return false;
  }

  String? _findNameInCommand() {
    bool prevWasNotOption = false;
    for (int i = 0; i < command.length; i++) {
      bool isNotOption = !command[i].trim().startsWith('-');
      if (prevWasNotOption && isNotOption) {
        return command[i];
      }
      prevWasNotOption = isNotOption;
    }
    return null;
  }
}
