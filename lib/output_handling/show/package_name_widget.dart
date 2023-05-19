import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/link.dart';
import 'package:winget_gui/extensions/string_map_extension.dart';
import 'package:winget_gui/extensions/widget_list_extension.dart';

import '../../command_button.dart';
import '../info_enum.dart';

class PackageNameWidget extends StatelessWidget {
  final Map<String, String> infos;
  const PackageNameWidget(this.infos, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 18,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    ..._name(context),
                    if (hasVersion())
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'v${infos[Info.version.key]!}',
                          style: FluentTheme.of(context).typography.title,
                        ),
                      )
                  ],
                ),
                if (hasVersion()) const SizedBox(height: 10),
                infos.hasEntry(Info.publisher.key)
                    ? _herausgeber()
                    : Text(infos[Info.id.key]!),
              ],
            ),
          ),
          _buttons(context),
        ],
      ),
    );
  }

  List<Widget> _name(BuildContext context) {
    if (!infos.containsKey(Info.name.key)) {
      return [_nameFragment('<unknown>', context)];
    }
    List<String> nameFragments = infos[Info.name.key]!.split(' ');
    return nameFragments
        .map<Widget>((String fragment) => _nameFragment(fragment, context))
        .toList();
  }

  Text _nameFragment(String fragment, BuildContext context) {
    return Text(
      fragment,
      style: FluentTheme.of(context).typography.display,
      softWrap: true,
    );
  }

  Widget _herausgeber() {
    if (infos.hasEntry(Info.publisherUrl.key)) {
      return _herausgeberWithLink();
    } else {
      return _herausgeberText();
    }
  }

  Widget _herausgeberWithLink() {
    return Link(
      uri: Uri.parse(checkUrlContainsHttp(infos[Info.publisherUrl.key]!)),
      builder: (context, open) {
        return HyperlinkButton(
          onPressed: open,
          child: _herausgeberText(),
        );
      },
    );
  }

  String checkUrlContainsHttp(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    } else {
      return 'https://$url';
    }
  }

  Text _herausgeberText() {
    return Text(infos[Info.publisher.key]!);
  }

  bool hasVersion() {
    return (infos.hasEntry(Info.version.key) &&
        infos[Info.version.key]! != 'Unknown');
  }

  Widget _buttons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CommandButton(text: 'Install', command: _createCommand('install')),
        CommandButton(text: 'Upgrade', command: _createCommand('upgrade')),
        CommandButton(text: 'Uninstall', command: _createCommand('uninstall')),
      ].withSpaceBetween(height: 5),
    );
  }

  List<String> _createCommand(String command) {
    return [command, '--id', infos[Info.id.key]!];
  }
}
