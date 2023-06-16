import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/string_map_extension.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/show/compartments/compartment.dart';
import 'package:winget_gui/widget_assets/link_text.dart';
import 'package:winget_gui/widget_assets/right_side_buttons.dart';
import 'package:winget_gui/widget_assets/store_button.dart';

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

  Widget _nameAndVersion(BuildContext context) {
    return Wrap(
      spacing: 18,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        ..._name(context),
        if (infos.hasVersion())
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'v${infos.details[Info.version.key]!}',
              style: FluentTheme.of(context).typography.title,
            ),
          )
      ],
    );
  }

  List<Widget> _name(BuildContext context) {
    if (!infos.details.hasInfo(Info.name)) {
      return [_nameFragment('<unknown>', context)];
    }
    List<String> nameFragments = infos.details[Info.name.key]!.split(' ');
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
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 5,
      runSpacing: 5,
      children: [
        infos.details.hasInfo(Info.author)
            ? textOrInlineLink(
                context: context, name: Info.author, url: Info.publisherUrl)
            : infos.details.hasInfo(Info.publisher)
                ? publisher(context)
                : Text(infos.details[Info.id.key]!),
        if (infos.details.hasInfo(Info.website)) _website(),
        if (infos.details.hasInfo(Info.category)) ...[
          LinkText(line: infos.details[Info.category.key]!),
          if (infos.hasInstallerDetails() &&
              infos.installerDetails!.hasInfo(Info.installerType) &&
              infos.installerDetails![Info.installerType.key]?.trim() ==
                  'msstore' &&
              infos.installerDetails!.hasInfo(Info.storeProductID))
            _showInStore(),
        ]
      ].withSpaceBetween(width: 5),
    );
  }

  Widget publisher(BuildContext context) {
    return textOrInlineLink(
        context: context, name: Info.publisher, url: Info.publisherUrl);
  }

  Widget _website() {
    return LinkButton(
        url: infos.details[Info.website.key]!, text: Text(Info.website.title));
  }

  StoreButton _showInStore() {
    return StoreButton(
      storeId: infos.installerDetails![Info.storeProductID.key]!,
    );
  }

  static Iterable<String> manuallyHandledStringKeys() =>
      manuallyHandledKeys.map<String>((Info info) => info.key);

  static bool containsData(Map<String, String> infos) {
    for (String key in manuallyHandledStringKeys()) {
      if (infos.hasEntry(key)) {
        return true;
      }
    }
    return false;
  }
}
