import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/route_parameter.dart';
import 'package:winget_gui/widget_assets/right_side_buttons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../routes.dart';
import '../infos/package_infos.dart';

class PackageShortInfo extends StatelessWidget {
  final PackageInfos infos;
  final List<String> command;

  final MainAxisAlignment columnAlign = MainAxisAlignment.center;

  const PackageShortInfo(this.infos, {super.key, required this.command});

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Button(
      onPressed: (isClickable(locale))
          ? () {
              if (infos.id != null) {
                pushPackageDetails(context, locale);
              }
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SizedBox(height: 90, child: _shortInfo(context)),
      ),
    );
    //return ;
  }

  Future<void> pushPackageDetails(
      BuildContext context, AppLocalizations locale) async {
    NavigatorState router = Navigator.of(context);
    router.pushNamed(Routes.show.route,
        arguments: RouteParameter(commandParameter: [
          '--id',
          infos.id!.value,
          if (infos.hasVersion()) ...['-v', infos.version!.value]
        ], titleAddon: infos.name?.value));
  }

  Widget _shortInfo(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _leftSide(context),
        ),
        Column(
          mainAxisAlignment: columnAlign,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: _versions(locale),
        ),
        if (isClickable(locale)) ...[
          const SizedBox(width: 20),
          RightSideButtons(
            infos: infos,
            alignment: columnAlign,
            upgrade: infos.availableVersion != null,
            install: !(command[0] == 'upgrade' || command[0] == 'list'),
          )
        ],
      ],
    );
  }

  Widget _leftSide(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: columnAlign,
      children: [
        Text(
          infos.name!.value,
          style: _titleStyle(context),
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          infos.id!.value,
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
        ),
        if (infos.source != null && infos.source!.value.isNotEmpty)
          Text(
            locale.fromSource(infos.source!.value),
            style: TextStyle(
              color: FluentTheme.of(context).inactiveColor,
            ),
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
          )
      ],
    );
  }

  TextStyle? _titleStyle(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    TextStyle? style = FluentTheme.of(context).typography.title;
    if (!isClickable(locale)) {
      style = style?.apply(color: FluentTheme.of(context).inactiveColor);
    }
    return style;
  }

  List<Widget> _versions(AppLocalizations locale) {
    return [
      if (infos.version != null)
        Text("${infos.version!.title(locale)}: ${infos.version!.value}"),
      if (infos.availableVersion != null &&
          infos.availableVersion!.value.isNotEmpty)
        Text(
            "${infos.availableVersion!.title(locale)}: ${infos.availableVersion!.value}"),
    ];
  }

  bool isClickable(AppLocalizations locale) {
    return infos.source != null && infos.source!.value.isNotEmpty;
  }

  String? name() => infos.name?.value;

  String? id() => infos.id?.value;
}
