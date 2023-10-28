import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/widget_assets/icon_link_button.dart';

import '../../../helpers/extensions/string_extension.dart';
import '../../../widget_assets//link_button.dart';
import '../../package_infos/info.dart';
import 'compartment.dart';

abstract class ExpanderCompartment extends Compartment {
  const ExpanderCompartment({super.key});

  String compartmentTitle(AppLocalizations locale);

  bool get initiallyExpanded => true;

  EdgeInsetsGeometry get bodyPadding => const EdgeInsets.all(16);

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Expander(
      header: Text(compartmentTitle(locale),
          style: compartmentTitleStyle(FluentTheme.of(context).typography)),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buildCompartment(context),
      ),
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
        const Padding(
          padding: EdgeInsetsDirectional.symmetric(vertical: 5),
          child: Divider(
            style: DividerThemeData(horizontalMargin: EdgeInsets.zero),
          ),
        ),
      if (buttonRow != null && buttonRow.children.isNotEmpty) buttonRow
    ].withSpaceBetween(height: 10);
  }

  Widget textOrIconLink(
      {required BuildContext context,
      required String? text,
      required Uri? url}) {
    if (url != null) {
      return RichText(
          text: TextSpan(text: text ?? url.toString(), children: [
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
    return LinkButton(url: link.value, text: Text(link.title(locale)));
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

  Widget copyableInfo(
      {required Info<String> info, required BuildContext context}) {
    return RichText(
        text: TextSpan(text: info.value, children: [
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
          alignment: PlaceholderAlignment.middle)
    ]));
  }

  Info<String>? tryFromLocaleInfo(Info<Locale>? info, BuildContext context) {
    LocaleNames localeNames = LocaleNames.of(context)!;
    return tryFrom(info, (locale) => localeNames.nameOf(locale.toString()) ??
        locale.toLanguageTag());
  }

  Info<String>? tryFrom<T extends Object>(Info<T>? info, String Function(T) toString) {
    if (info == null) {
      return null;
    }
    return Info<String>(
        title: info.title, value: toString(info.value));
  }

  List<Widget> detailsList(List<Info<String>?> details, BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return [
      for (Info<String>? info in details)
        if (info != null)
          wrapInWrap(
              title: info.title(locale),
              body: info.copyable
                  ? copyableInfo(info: info, context: context)
                  : textOrIconLink(
                      context: context,
                      text: info.value,
                      url: isLink(info.value)
                          ? Uri.tryParse(info.value)
                          : null)),
    ];
  }
}
