import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:winget_gui/output_handling/show/compartments/compartment.dart';

import '../../../helpers/extensions/string_extension.dart';
import '../../../widget_assets/icon_link_button.dart';
import '../../../widget_assets/link_button.dart';
import '../../package_infos/info.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../package_infos/info_with_link.dart';

mixin CompartmentBuildingBlocks on Compartment {
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

  Padding divider() {
    return const Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: 5),
      child: Divider(
        style: DividerThemeData(horizontalMargin: EdgeInsets.zero),
      ),
    );
  }

  Widget textOrIconLink(
      {required BuildContext context,
      required String? text,
      required Uri? url}) {
    if (url != null) {
      return RichText(
          text: TextSpan(
              text: text ?? url.toString(),
              style: FluentTheme.of(context).typography.body,
              children: [
            WidgetSpan(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 19),
                    child: IconLinkButton(url: url)),
                alignment: PlaceholderAlignment.middle)
          ]));
    }
    return textWithLinks(text: text!, context: context);
  }

  Widget textOrLinkButton(
      {required BuildContext context, required Info<String> text}) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    if (StringHelper.isLink(text.value)) {
      return LinkButton(
          url: Uri.parse(text.value), text: Text(text.title(locale)));
    }
    return textWithLinks(text: text.value, context: context);
  }

  Widget linkButton(
      {required Info<Uri> link, required AppLocalizations locale}) {
    return LinkButton(
        url: link.value, text: Text(link.customTitle ?? link.title(locale)));
  }

  Widget copyableInfo(
      {required Info<String> info, required BuildContext context}) {
    return RichText(
      text: TextSpan(
        text: info.value,
        style: FluentTheme.of(context).typography.body,
        children: [
          WidgetSpan(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 19),
              child: IconButton(
                icon: const Icon(FluentIcons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: info.value));
                },
                style: ButtonStyle(
                  padding: ButtonState.all(
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 10)),
                ),
              ),
            ),
            alignment: PlaceholderAlignment.middle,
          )
        ],
      ),
    );
  }

  Widget fromInfoWithLink(BuildContext context, InfoWithLink? info) {
    return textOrIconLink(context: context, text: info?.text, url: info?.url);
  }

  Widget wrapInfoWithLink(BuildContext context, InfoWithLink? info) {
    return wrapInWrap(
        title: info?.title(AppLocalizations.of(context)!) ?? '',
        body: fromInfoWithLink(context, info));
  }

  Widget table(List<(String, Widget)> list) {
    return Table(
      columnWidths: const {0: FixedColumnWidth(170)},
      children: [
        for (var (title, widget) in list)
          TableRow(
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              widget
            ],
          ),
      ],
    );
  }
}
