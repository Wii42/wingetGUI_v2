import 'package:winget_gui/output_handling/output_scanner.dart';
import 'package:winget_gui/output_handling/package_infos/package_attribute.dart';
import 'package:winget_gui/output_handling/responsibility.dart';
import 'package:winget_gui/output_handling/show/show_parser.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ShowScanner extends OutputScanner {
  List<String> command;

  ShowScanner(super.respList, {required this.command});

  @override
  void markResponsibleLines(AppLocalizations wingetLocale) {
    if (respList.isEmpty || command.isEmpty) //||
    //command[0] != Winget.show.command[0])
    {
      return;
    }
    int identifierPos = _findIdentifier(wingetLocale);
    if (identifierPos > -1) {
      ShowParser showPart = ShowParser([], command: command);
      for (int i = identifierPos; i < respList.length; i++) {
        Responsibility resp = respList[i];
        if (resp.isHandled()) {
          break;
        }
        if (i > identifierPos) {
          if (!resp.line.startsWith(' ') &&
              !resp.line.trim().contains(':') &&
              resp.line.isNotEmpty) {
            break;
          }
        }
        showPart.addLine(resp.line);
        resp.respPart = showPart;
      }
      markResponsibleLines(wingetLocale);
    }
  }

  int _findIdentifier(AppLocalizations wingetLocale) {
    for (int i = 0; i < respList.length; i++) {
      if (!respList[i].isHandled() &&
          (_isIdentifier(respList[i].line, command, wingetLocale))) {
        return i;
      }
    }
    return -1;
  }

  bool _isIdentifier(
      String line, List<String> command, AppLocalizations locale) {
    line = line.trim();
    if (!line.startsWith(locale.found) &&
        !line.startsWith(locale.agreementsFor)) {
      return false;
    }
    line = line.toLowerCase();
    if (command.contains('--id')) {
      String id = command[command.indexOf('--id') + 1].toLowerCase();
      return (line.endsWith('[$id]') ||
          line.contains('[$id] ${locale.infoKey(PackageAttribute.version.name)}'
              .toLowerCase()));
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
