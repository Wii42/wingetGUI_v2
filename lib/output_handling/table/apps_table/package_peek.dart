import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/route_parameter.dart';
import 'package:winget_gui/widget_assets/favicon_widget.dart';
import 'package:winget_gui/widget_assets/right_side_buttons.dart';

import '../../../routes.dart';
import '../../package_infos/package_infos_peek.dart';

class PackagePeek extends StatelessWidget {
  final PackageInfosPeek infos;
  final bool installButton;
  final bool upgradeButton;
  final bool uninstallButton;

  final MainAxisAlignment columnAlign = MainAxisAlignment.center;

  const PackagePeek(this.infos,
      {super.key,
      this.installButton = true,
      this.upgradeButton = true,
      this.uninstallButton = true});

  factory PackagePeek.fromCommand(PackageInfosPeek infos,
      {required List<String> command}) {
    return PackagePeek(infos,
        installButton: !(command[0] == 'upgrade' || command[0] == 'list'),
        upgradeButton: infos.availableVersion != null &&
            infos.availableVersion!.value.isNotEmpty);
  }

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
        arguments: PackageRouteParameter(commandParameter: [
          '--id',
          infos.id!.value,
          //if (infos.hasVersion()) ...['-v', infos.version!.value]
        ], titleAddon: infos.name?.value, package: infos));
  }

  Widget _shortInfo(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //if (infos.screenshots?.icon != null &&
        //    infos.screenshots!.icon.toString().isNotEmpty)
        favicon(faviconSize()),
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
            mainAlignment: MainAxisAlignment.spaceEvenly,
            upgrade: upgradeButton,
            install: installButton,
            iconsOnly: true,
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
            style: withoutColor(FluentTheme.of(context).typography.caption),
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
    TextStyle? blueprint = FluentTheme.of(context).typography.title;
    return withoutColor(blueprint);
  }

  TextStyle? correctColor(TextStyle? style, BuildContext context) {
    if (!isClickable()) {
      style = style?.apply(
          color: ButtonThemeData.buttonForegroundColor(
              context, {ButtonStates.disabled}));
    }
    return style;
  }

  TextStyle? withoutColor(TextStyle? blueprint) {
    if (blueprint == null) return null;
    return TextStyle(
      fontSize: blueprint.fontSize,
      fontWeight: blueprint.fontWeight,
      fontFamily: blueprint.fontFamily,
      fontFamilyFallback: blueprint.fontFamilyFallback,
      fontStyle: blueprint.fontStyle,
      letterSpacing: blueprint.letterSpacing,
      wordSpacing: blueprint.wordSpacing,
      textBaseline: blueprint.textBaseline,
      height: blueprint.height,
      locale: blueprint.locale,
      leadingDistribution: blueprint.leadingDistribution,
      debugLabel: blueprint.debugLabel,
      shadows: blueprint.shadows,
      fontFeatures: blueprint.fontFeatures,
      decoration: blueprint.decoration,
      decorationColor: blueprint.decorationColor,
      decorationStyle: blueprint.decorationStyle,
      decorationThickness: blueprint.decorationThickness,
    );
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

  Widget favicon(double faviconSize) {
    return DefaultFavicon(faviconSize: faviconSize);
    //return FaviconWidget(infos: infos, faviconSize: faviconSize);
  }

  double faviconSize() => 60;

  static Widget get prototypeWidget {
    return Button(
      onPressed: () {},
      child: const Padding(
        padding: EdgeInsets.all(10),
        child: SizedBox(height: 90),
      ),
    );
  }
}
