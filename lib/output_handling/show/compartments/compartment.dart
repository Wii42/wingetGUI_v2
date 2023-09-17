import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/widget_assets/link_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../helpers/extensions/string_extension.dart';
import '../../../widget_assets//link_button.dart';
import '../../../widget_assets/decorated_card.dart';
import '../../../widget_assets/inline_link_button.dart';
import '../../package_infos/info.dart';

abstract class Compartment extends StatelessWidget {
  const Compartment({super.key});

  List<Widget> buildCompartment(BuildContext context);

  String? compartmentTitle(AppLocalizations locale);

  @override
  Widget build(BuildContext context) {
    return DecoratedCard(
      padding: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buildCompartment(context),
      ),
    );
  }

  Wrap wrapInWrap({required String title, required Widget body}) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Text(
            '$title:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body,
      ],
    );
  }

  List<Widget> fullCompartment(
      {String? title,
      List<Widget>? mainColumn,
      Wrap? buttonRow,
      required BuildContext context}) {
    return [
      if (title != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(title,
              style: FluentTheme.of(context).typography.bodyLarge?.merge(
                  const TextStyle(inherit: true, fontWeight: FontWeight.w500))),
        ),
      ...?mainColumn,
      if (mainColumn != null &&
          mainColumn.isNotEmpty &&
          buttonRow != null &&
          buttonRow.children.isNotEmpty)
        const Padding(
          padding: EdgeInsetsDirectional.symmetric(vertical: 5),
          child: Divider(),
        ),
      if (buttonRow != null) buttonRow
    ].withSpaceBetween(height: 10);
  }

  Widget textOrInlineLink(
      {required BuildContext context,
      required String? text,
      required Uri? url}) {
    if (url != null) {
      return InlineLinkButton(url: url, text: Text(text ?? url.toString()));
    }
    return textWithLinks(text: text!, context: context);
  }

  Widget textOrLinkButton(
      {required BuildContext context, required Info<String> text}) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    if (isLink(text.value)) {
      return LinkButton(
          url: Uri.parse(text.value), text: Text(text.title(locale)));
    }
    return textWithLinks(text: text.value, context: context);
  }

  Widget linkButton(
      {required Info<Uri> link, required AppLocalizations locale}) {
    return LinkButton(url: link.value, text: Text(link.title(locale)));
  }

  Widget textWithLinks(
      {required String text, required BuildContext context, int maxLines = 1}) {
    return LinkText(
      line: text,
      maxLines: maxLines,
    );
  }

  Wrap buttonRow(List<Info<Uri>?> links, BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        for (Info<Uri>? link in links)
          if (link != null)
            linkButton(
              locale: locale,
              link: link,
            )
      ],
    );
  }
}
