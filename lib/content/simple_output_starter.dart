import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/content/process_starter.dart';
import 'package:winget_gui/content/process_output.dart';
import 'package:winget_gui/content/simple_output.dart';
import 'package:winget_gui/winget_process.dart';

class SimpleOutputStarter extends ProcessStarter {
  const SimpleOutputStarter({super.key, required super.command});

  @override
  ProcessOutput processOutput(WingetProcess process, AppLocalizations locale) {
    return SimpleOutput(process: process);
  }
}
