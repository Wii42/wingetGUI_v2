import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/string_map_extension.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';

import '../../../helpers/extensions/string_extension.dart';
import '../../package_infos/info.dart';
import 'compartment.dart';
import 'compartment_building_blocks.dart';

abstract class ExpanderCompartment extends Compartment
    with CompartmentBuildingBlocks {
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

  List<Widget> detailsList(List<Info<String>?> details, BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return [
      for (Info<String>? info in details)
        if (info != null && info.value.isNotEmpty)
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
