import 'package:fluent_ui/fluent_ui.dart';
import 'package:open_store/open_store.dart';
import 'package:winget_gui/helpers/extensions/string_map_extension.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/show/compartments/compartment.dart';
import 'package:winget_gui/widget_assets/link_text.dart';
import 'package:winget_gui/widget_assets/right_side_buttons.dart';

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
          RightSideButtons(infos: infos),
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
        if (hasVersion())
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'v${infos[Info.version.key]!}',
              style: FluentTheme.of(context).typography.title,
            ),
          )
      ],
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

  Widget _detailsBelow(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 5,
      runSpacing: 5,
      children: [
        infos.hasEntry(Info.publisher.key)
            ? publisher(context)
            : Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
                child: Text(infos[Info.id.key]!)),
        if (infos.hasEntry(Info.website.key)) _website(),
        if (infos.hasEntry(Info.category.key)) ...[
          Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
              child: LinkText(line: infos[Info.category.key]!)),
          if (infos.hasEntry(Info.installerType.key) &&
              infos[Info.installerType.key]?.trim() == 'msstore' &&
              infos.hasEntry(Info.storeProductID.key))
            _showInStore(),
        ]
      ],
    );
  }

  Widget publisher(BuildContext context) {
    return textOrLink(
        context: context, name: Info.publisher, url: Info.publisherUrl);
  }

  bool hasVersion() {
    return (infos.hasEntry(Info.version.key) &&
        infos[Info.version.key]! != 'Unknown');
  }

  Widget _website() {
    return LinkButton(
        url: infos[Info.website.key]!, text: Text(Info.website.title));
  }

  Button _showInStore() {
    return Button(
        child: Text("Open in Store"),
        onPressed: () {
          OpenStore.instance
              .open(windowsProductId: infos[Info.storeProductID.key]!);
        });
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
