import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/extensions/string_map_extension.dart';
import 'package:winget_gui/extensions/widget_list_extension.dart';

import '../../command_button.dart';
import '../../content.dart';
import '../../content_place.dart';

class PackageShortInfo extends StatelessWidget {
  final Map<String, String> infos;
  const PackageShortInfo(this.infos, {super.key});

  @override
  Widget build(BuildContext context) {
    return Button(
      onPressed: (infos.hasEntry('Quelle'))
          ? () {
              Content? target = ContentPlace.maybeOf(context)?.content;
              if (target != null && infos.containsKey('ID')) {
                target.showResultOfCommand(['show', '--id', infos['ID']!]);
              }
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    infos['Name']!,
                    style: _titleStyle(context),
                    softWrap: true,
                    textAlign: TextAlign.start,
                  ),
                  Text(infos['ID']!),
                  if (infos.hasEntry('Quelle'))
                    Text(
                      "from ${infos['Quelle']!}",
                      style: TextStyle(
                          color: FluentTheme.of(context).disabledColor),
                    )
                ],
              ),
            ),
            if (infos.hasEntry('Quelle')) _buttons(context),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (infos.hasEntry('Version'))
                  Text("Version: ${infos['Version']!}"),
                if (infos.hasEntry('Verfügbar'))
                  Text("Verfügbar: ${infos['Verfügbar']!}")
              ],
            ),
          ],
        ),
      ),
    );
    //return ;
  }

  TextStyle? _titleStyle(BuildContext context) {
    TextStyle? style = FluentTheme.of(context).typography.title;
    if (!infos.hasEntry('Quelle')) {
      style = style?.apply(color: FluentTheme.of(context).disabledColor);
    }
    return style;
  }

  Widget _buttons(BuildContext context) {
    return Wrap(
      children: [
        CommandButton(text: 'Install', command: _createCommand('install')),
        CommandButton(text: 'Upgrade', command: _createCommand('upgrade')),
        CommandButton(text: 'Uninstall', command: _createCommand('uninstall')),
      ].withSpaceBetween(width: 5),
    );
  }

  List<String> _createCommand(String command) {
    return [command, '--id', infos['ID']!];
  }
}
