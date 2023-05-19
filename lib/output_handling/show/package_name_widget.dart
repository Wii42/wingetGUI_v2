import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/link.dart';
import 'package:winget_gui/extensions/string_map_extension.dart';

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    infos['Name'] ?? "<unknown name>",
                    style: FluentTheme.of(context).typography.display,
                    softWrap: true,
                  ),
                  if (hasVersion()) const SizedBox(width: 10),
                  if (hasVersion())
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'v${infos['Version']!}',
                          style: FluentTheme.of(context).typography.title,
                        ))
                ],
              ),
              if (hasVersion()) const SizedBox(height: 10),
              infos.hasEntry('Herausgeber')
                  ? _herausgeber()
                  : Text(infos['ID']!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _herausgeber() {
    if (infos.hasEntry('Herausgeber-URL')) {
      return _herausgeberWithLink();
    } else {
      return _herausgeberText();
    }
  }

  Widget _herausgeberWithLink() {
    return Link(
      uri: Uri.parse(checkUrlContainsHttp(infos['Herausgeber-URL']!)),
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
    return Text(infos['Herausgeber']!);
  }

  bool hasVersion() {
    return (infos.hasEntry('Version') && infos['Version']! != 'Unknown');
  }
}
