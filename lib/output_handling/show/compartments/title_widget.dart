import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/string_map_extension.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/show/compartments/compartment.dart';
import 'package:winget_gui/widget_assets/link_text.dart';
import 'package:winget_gui/widget_assets/right_side_buttons.dart';
import 'package:winget_gui/widget_assets/store_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../widget_assets/link_button.dart';
import '../../info_enum.dart';

class TitleWidget extends Compartment {
  static final List<Info> manuallyHandledKeys = [
    Info.name,
    Info.publisher,
    Info.publisherUrl,
    Info.version,
    Info.website,
    Info.category
  ];

  const TitleWidget({required super.infos, super.key});

  @override
  List<Widget> buildCompartment(BuildContext context) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _nameAndVersion(context),
                _detailsBelow(context),
              ].withSpaceBetween(height: 10),
            ),
          ),
          RightSideButtons(infos: infos.details),
        ],
      ),
    ];
  }

  @override
  String compartmentTitle(AppLocalizations locale) {
    return Info.name.title(locale);
  }

  Widget _nameAndVersion(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 18,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        ..._name(context),
        if (infos.hasVersion(locale))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'v${infos.details[Info.version.key(locale)]!}',
              style: FluentTheme.of(context).typography.title,
            ),
          )
      ],
    );
  }

  List<Widget> _name(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    if (!infos.details.hasInfo(Info.name, locale)) {
      return [_nameFragment('<unknown>', context)];
    }
    List<String> nameFragments =
        infos.details[Info.name.key(locale)]!.split(' ');
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

  Widget _detailsBelow(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 5,
      runSpacing: 5,
      children: [
        infos.details.hasInfo(Info.author, locale)
            ? textOrInlineLink(
                context: context, name: Info.author, url: Info.publisherUrl)
            : infos.details.hasInfo(Info.publisher, locale)
                ? publisher(context)
                : Text(infos.details[Info.id.key(locale)]!),
        if (infos.details.hasInfo(Info.website, locale)) _website(locale),
        if (infos.details.hasInfo(Info.category, locale)) ...[
          LinkText(line: infos.details[Info.category.key(locale)]!),
          if (infos.hasInstallerDetails() &&
              infos.installerDetails!.hasInfo(Info.installerType, locale) &&
              infos.installerDetails![Info.installerType.key(locale)]?.trim() ==
                  'msstore' &&
              infos.installerDetails!.hasInfo(Info.storeProductID, locale))
            _showInStore(locale),
        ]
      ].withSpaceBetween(width: 5),
    );
  }

  Widget publisher(BuildContext context) {
    return textOrInlineLink(
        context: context, name: Info.publisher, url: Info.publisherUrl);
  }

  Widget _website(AppLocalizations locale) {
    return LinkButton(
        url: infos.details[Info.website.key(locale)]!,
        text: Text(Info.website.title(locale)));
  }

  StoreButton _showInStore(AppLocalizations locale) {
    return StoreButton(
      storeId: infos.installerDetails![Info.storeProductID.key(locale)]!,
    );
  }

  static Iterable<String> manuallyHandledStringKeys(AppLocalizations locale) =>
      manuallyHandledKeys.map<String>((Info info) => info.key(locale));

  static bool containsData(Map<String, String> infos, AppLocalizations locale) {
    for (String key in manuallyHandledStringKeys(locale)) {
      if (infos.hasEntry(key)) {
        return true;
      }
    }
    return false;
  }
}
