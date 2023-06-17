import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/content/content_snapshot.dart';
import 'package:winget_gui/widget_assets/run_button_tooltip.dart';

import 'content/content_pane.dart';

class HistoryEntry extends StatelessWidget {
  final ContentSnapshot snapshot;
  final ContentPane content;

  const HistoryEntry(
      {super.key, required this.snapshot, required this.content});

  @override
  Widget build(BuildContext context) {
    FluentThemeData theme = FluentTheme.of(context);

    return RunButtonTooltip(
      command: snapshot.command,
      useMousePosition: true,
      button: Button(
        onPressed: () {
          content.showResultOfCommand(snapshot.command);
        },
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                snapshot.title,
                style: theme.typography.bodyStrong,
              ),
              Text(
                'winget ${snapshot.command.join(' ')}',
                style: TextStyle(color: theme.disabledColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
