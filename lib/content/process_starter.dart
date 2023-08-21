import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/winget_process.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../winget_commands.dart';
import 'output_pane.dart';

class ProcessStarter extends StatelessWidget {
  final List<String> command;
  final Winget? winget;
  const ProcessStarter({super.key, required this.command, this.winget});

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    Future<WingetProcess> futureProcess = WingetProcess.startProcess(command);
    return FutureBuilder<WingetProcess>(
      future: futureProcess,
      builder: (BuildContext context, AsyncSnapshot<dynamic> processSnapshot) {
        if (processSnapshot.hasData) {
          return OutputPane(process: processSnapshot.data, title: winget?.title(locale));
        } else if (processSnapshot.hasError) {
          return Center(child: Text('Error: ${processSnapshot.error}'));
        } else {
          return const ProgressBar();
        }
      },
    );
  }
}
