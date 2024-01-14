import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/string_map_extension.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/widget_assets/icon_link_button.dart';

import '../../../helpers/extensions/string_extension.dart';
import '../../../widget_assets//link_button.dart';
import '../../package_infos/info.dart';
import 'compartment.dart';

abstract class ExpanderCompartment extends Compartment {
  const ExpanderCompartment({super.key});

  String compartmentTitle(AppLocalizations locale);

  IconData get titleIcon;

  bool get initiallyExpanded => true;

  EdgeInsetsGeometry get bodyPadding => const EdgeInsets.all(16);

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: buildCompartment(context),
    );
    return buildWithoutContent(context, content);
  }

  Expander buildWithoutContent(BuildContext context, content) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Expander(
      header: Row(
        children: [
          Icon(
            titleIcon,
            size: 16,
            color: FluentTheme.of(context)
                .accentColor
                .defaultBrushFor(FluentTheme.of(context).brightness),
          ),
          Expanded(
            child: Text(compartmentTitle(locale),
                style:
                    compartmentTitleStyle(FluentTheme.of(context).typography)),
          ),
        ].withSpaceBetween(width: 10),
      ),
      content: content,
      initiallyExpanded: initiallyExpanded,
      contentPadding: bodyPadding,
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
      ...?mainColumn,
      if (mainColumn != null &&
          mainColumn.isNotEmpty &&
          buttonRow != null &&
          buttonRow.children.isNotEmpty)
        divider(),
      if (buttonRow != null && buttonRow.children.isNotEmpty) buttonRow
    ].withSpaceBetween(height: 10);
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
    if (isLink(text.value)) {
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

  Wrap buttonRow(List<Info<Uri>?> links, BuildContext context,
      {List<Widget> otherButtons = const []}) {
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
            ),
        ...otherButtons
      ],
    );
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
                    padding: ButtonState.all(const EdgeInsets.symmetric(
                        vertical: 0, horizontal: 10)),
                  ),
                ),
              ),
              alignment: PlaceholderAlignment.middle)
        ]));
  }

  List<Widget> detailsList(List<Info<String>?> details, BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    //return [
    //  table(details
    //      .where((e) => e != null)
    //      .map<(String, Widget)>((info) => (
    //            info!.title(locale),
    //            info.copyable
    //                ? copyableInfo(info: info, context: context)
    //                : info.couldBeLink
    //                    ? textOrIconLink(
    //                        context: context,
    //                        text: info.value,
    //                        url: isLink(info.value)
    //                            ? Uri.tryParse(info.value)
    //                            : null)
    //                    : Text(info.value)
    //          ))
    //      .toList())
    //];
    return [
      for (Info<String>? info in details)
        if (info != null)
          wrapInWrap(
              title: info.title(locale),
              body: info.copyable
                  ? copyableInfo(info: info, context: context)
                  : info.couldBeLink
                      ? textOrIconLink(
                          context: context,
                          text: info.value,
                          url: isLink(info.value)
                              ? Uri.tryParse(info.value)
                              : null)
                      : Text(info.value)),
    ];
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

  Widget displayDetails(List<(String, Widget)> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var (title, widget) in list)
          wrapInWrap(title: title, body: widget),
      ].withSpaceBetween(height: 10),
    );
  }

  List<Widget> displayRest(
      Map<String, String>? otherInfos, BuildContext context) {
    if (otherInfos == null) {
      return [];
    }
    Iterable<String> restKeys = otherInfos.keys;
    String value(String key) => otherInfos[key]!;
    return [
      for (String key in restKeys)
        if (otherInfos.hasEntry(key))
          wrapInWrap(
            title: key,
            body: textOrIconLink(
                context: context,
                text: value(key),
                url: isLink(value(key)) ? Uri.tryParse(value(key)) : null),
          ),
    ];
  }
}
