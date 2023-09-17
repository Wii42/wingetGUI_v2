import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import './process_starter.dart';
import './process_output.dart';
import './simple_output.dart';
import './winget_process.dart';

class SimpleOutputStarter extends ProcessStarter {
  const SimpleOutputStarter({super.key, required super.command});

  @override
  ProcessOutput processOutput(WingetProcess process, AppLocalizations locale) {
    return SimpleOutput(process: process);
  }
}
