import 'package:expandable_text/expandable_text.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:string_validator/string_validator.dart';
import 'package:winget_gui/extensions/string_map_extension.dart';
import 'package:winget_gui/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/show/link_button.dart';

import '../info_enum.dart';

class AgreementWidget extends StatelessWidget {
  final Map<String, String> infos;
  const AgreementWidget({super.key, required this.infos});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Agreement', style: FluentTheme.of(context).typography.title),
          if (infos.hasEntry(Info.license.key) ||
              infos.hasEntry(Info.licenseUrl.key))
            _wrapInWrap(title: 'License', body: _license(context)),
          if (infos.hasEntry(Info.copyright.key) ||
              infos.hasEntry(Info.copyrightUrl.key))
            _wrapInWrap(title: 'Copyright', body: _copyright(context)),
        ].withSpaceBetween(height: 5),
      ),
    );
  }

  Wrap _wrapInWrap({required String title, required Widget body}) {
    return Wrap(
      spacing: 5,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            '$title:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body
      ],
    );
  }

  Widget _textOrLink(
      {required BuildContext context, required Info name, required Info url}) {
    if (infos.hasEntry(url.key)) {
      return LinkButton(
          url: infos[url.key]!, text: Text(infos[name.key] ?? infos[url.key]!));
    } else {
      return _checkIfTextIsLink(context: context, name: name);
    }
  }

  Widget _checkIfTextIsLink(
      {required BuildContext context, required Info name, String? title}) {
    String text = infos[name.key]!.trim();
    if (isURL(text) ||
        (text.startsWith('ms-windows-store://') && !text.contains(' '))) {
      return LinkButton(
          url: infos[name.key]!, text: Text(title ?? infos[name.key]!));
    }
    return ExpandableText(
      infos[name.key]!,
      expandText: 'show more',
      collapseText: 'show less',
      maxLines: 1,
      linkColor: FluentTheme.of(context).accentColor,
    );
  }

  Widget _license(BuildContext context) {
    return _textOrLink(
        context: context, name: Info.license, url: Info.licenseUrl);
  }

  Widget _copyright(BuildContext context) {
    return _textOrLink(
        context: context, name: Info.copyright, url: Info.copyrightUrl);
  }
}
