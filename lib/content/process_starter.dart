import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/winget_process.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widget_assets/full_width_progress_bar.dart';
import '../winget_commands.dart';
import 'output_pane.dart';

class ProcessStarter extends StatelessWidget {
  final List<String> command;
  final Winget? winget;
  final String? titleInput;

  const ProcessStarter(
      {super.key, required this.command, this.winget, this.titleInput});

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    Future<WingetProcess> futureProcess = WingetProcess.runCommand(command);
    return FutureBuilder<WingetProcess>(
      future: futureProcess,
      builder: (BuildContext context, AsyncSnapshot<dynamic> processSnapshot) {
        if (processSnapshot.hasData) {
          return OutputPane(
              process: processSnapshot.data,
              title: titleInput != null
                  ? winget?.titleWithInput(titleInput!, localization: locale)
                  : winget?.title(locale));
        } else if (processSnapshot.hasError) {
          return Center(child: Text('Error: ${processSnapshot.error}'));
        } else {
          return const FullWidthProgressbar();
        }
      },
    );
  }
}
