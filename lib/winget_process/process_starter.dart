import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import './process_output.dart';
import './winget_process.dart';
import '../widget_assets/full_width_progress_bar.dart';
import '../winget_commands.dart';

abstract class ProcessStarter extends StatelessWidget {
  final List<String> command;
  final Winget? winget;

  const ProcessStarter({super.key, required this.command, this.winget});

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    Future<WingetProcess> futureProcess = WingetProcess.runCommand(command);
    return FutureBuilder<WingetProcess>(
      future: futureProcess,
      builder:
          (BuildContext context, AsyncSnapshot<WingetProcess> processSnapshot) {
        if (processSnapshot.hasData) {
          return processOutput(processSnapshot.data!, locale);
        } else if (processSnapshot.hasError) {
          return Center(child: Text('Error: ${processSnapshot.error}'));
        } else {
          return const FullWidthProgressbar();
        }
      },
    );
  }

  ProcessOutput processOutput(WingetProcess process, AppLocalizations locale);
}
