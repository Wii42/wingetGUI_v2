import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/infos/package_infos.dart';
import 'package:winget_gui/output_handling/show/compartments/compartment.dart';
import 'package:winget_gui/widget_assets/link_text.dart';
import 'package:winget_gui/widget_assets/right_side_buttons.dart';
import 'package:winget_gui/widget_assets/store_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../widget_assets/link_button.dart';
import '../../infos/app_attribute.dart';

class TitleWidget extends Compartment {
  final PackageInfos infos;

  const TitleWidget({required this.infos, super.key});

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

  @override
  String compartmentTitle(AppLocalizations locale) {
    return AppAttribute.name.title(locale);
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
              'v${infos.version!.value}',
              style: FluentTheme.of(context).typography.title,
            ),
          )
      ],
    );
  }

  List<Widget> _name(BuildContext context) {
    if (infos.name == null) {
      return [_nameFragment('<unknown>', context)];
    }
    List<String> nameFragments = infos.name!.value.split(' ');
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
        infos.author != null
            ? textOrInlineLink(
                context: context,
                text: infos.author?.value,
                url: infos.agreement?.publisher?.url)
            : infos.agreement?.publisher != null
                ? publisher(context)
                : Text(infos.id!.value),
        if (infos.website != null) _website(locale),
        if (infos.category != null) ...[
          LinkText(line: infos.category!.value),
          if (infos.installer?.type?.value.trim() == 'msstore' &&
              infos.installer?.storeProductID != null)
            _showInStore(locale),
        ]
      ].withSpaceBetween(width: 5),
    );
  }

  Widget publisher(BuildContext context) {
    return textOrInlineLink(
        context: context,
        text: infos.agreement?.publisher?.text,
        url: infos.agreement?.publisher?.url);
  }

  Widget _website(AppLocalizations locale) {
    return LinkButton(
        url: infos.website!.value,
        text: Text(AppAttribute.website.title(locale)));
  }

  StoreButton _showInStore(AppLocalizations locale) {
    return StoreButton(
      storeId: infos.installer!.storeProductID!.value,
    );
  }
}
