import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/route_parameter.dart';
import 'package:winget_gui/widget_assets/right_side_buttons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../routes.dart';
import '../../package_infos/package_infos_peek.dart';

class PackagePeek extends StatelessWidget {
  final PackageInfosPeek infos;
  final List<String> command;

  final MainAxisAlignment columnAlign = MainAxisAlignment.center;

  const PackagePeek(this.infos, {super.key, required this.command});

  @override
  Widget build(BuildContext context) {
    return Button(
      onPressed: (isClickable())
          ? () {
              if (infos.id != null) {
                pushPackageDetails(context);
              }
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SizedBox(height: 90, child: _shortInfo(context)),
      ),
    );
  }

  Future<void> pushPackageDetails(BuildContext context) async {
    NavigatorState router = Navigator.of(context);
    router.pushNamed(Routes.show.route,
        arguments: RouteParameter(commandParameter: [
          '--id',
          infos.id!.value,
          //if (infos.hasVersion()) ...['-v', infos.version!.value]
        ], titleAddon: infos.name?.value));
  }

  Widget _shortInfo(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: nameAndSource(context),
        ),
        Column(
          mainAxisAlignment: columnAlign,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ..._versions(locale),
            //if (infos.match != null) Text("${infos.match!.title(locale)}: ${infos.match!.value}", style: FluentTheme.of(context).typography.caption,),
          ],
        ),
        if (isClickable()) ...[
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

  Widget nameAndSource(BuildContext context) {
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
            style: correctColor(
                FluentTheme.of(context).typography.caption, context),
            //style: TextStyle(
            // color: FluentTheme.of(context).inactiveColor,
            //),
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  TextStyle? _titleStyle(BuildContext context) {
    TextStyle? style = FluentTheme.of(context).typography.title;
    return correctColor(style, context);
  }

  TextStyle? correctColor(TextStyle? style, BuildContext context) {
    if (!isClickable()) {
      style = style?.apply(
          color: ButtonThemeData.buttonForegroundColor(
              context, {ButtonStates.disabled}));
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

  bool isClickable() => infos.hasInfosFull();

  String? name() => infos.name?.value;

  String? id() => infos.id?.value;
}
