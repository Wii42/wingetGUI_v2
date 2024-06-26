import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as icons;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/helpers/route_parameter.dart';
import 'package:winget_gui/package_infos/package_infos_peek.dart';
import 'package:winget_gui/package_infos/publisher.dart';
import 'package:winget_gui/package_sources/package_source.dart';
import 'package:winget_gui/routes.dart';
import 'package:winget_gui/widget_assets/app_icon.dart';
import 'package:winget_gui/widget_assets/buttons/page_button.dart';
import 'package:winget_gui/widget_assets/buttons/right_side_buttons.dart';

class PackagePeek extends StatelessWidget {
  final PackageInfosPeek infos;
  final bool installButton;
  final bool upgradeButton;
  final bool uninstallButton;
  final bool checkFavicon;
  final bool showMatch;
  final bool showInstalledIcon;
  final bool defaultSourceIsLocalPC;

  final MainAxisAlignment columnAlign = MainAxisAlignment.center;

  const PackagePeek(
    this.infos, {
    super.key,
    this.installButton = true,
    this.upgradeButton = true,
    this.uninstallButton = true,
    this.checkFavicon = false,
    this.showMatch = false,
    this.showInstalledIcon = false,
    this.defaultSourceIsLocalPC = false,
  });

  factory PackagePeek.fromCommand(PackageInfosPeek infos,
      {required List<String> command}) {
    return PackagePeek(infos,
        installButton: !(command[0] == 'upgrade' || command[0] == 'list'),
        upgradeButton: infos.availableVersion != null &&
            infos.availableVersion!.value.isVersion());
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageButton(
      pageRoute: Routes.show,
      disabled: !isClickable(),
      routeParameter: PackageRouteParameter(commandParameter: [
        '--id',
        infos.id!.value.string,
        //if (infos.hasVersion()) ...['-v', infos.version!.value]
      ], titleAddon: infos.name?.value, package: infos),
      tooltipMessage: (locale) =>
          infos.name?.value ?? locale.packagePeekTooltip,
      useMousePosition: true,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: LayoutBuilder(builder: (context, constraints) {
          double width = constraints.maxWidth;
          bool isWide = width > 410;
          return SizedBox(
              height: isWide ? 90 : 150, child: _shortInfo(context, isWide));
        }),
      ),
    );
  }

  Future<void> pushPackageDetails(BuildContext context) async {
    NavigatorState router = Navigator.of(context);
    router.pushNamed(Routes.show.route,
        arguments: PackageRouteParameter(commandParameter: [
          '--id',
          infos.id!.value.string,
          //if (infos.hasVersion()) ...['-v', infos.version!.value]
        ], titleAddon: infos.name?.value, package: infos));
  }

  Widget _shortInfo(BuildContext context, bool isWide) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    List<Widget> versionsMatchAndInstalledMark = [
      if (showInstalledIcon)
        Row(
          children: [
            const Icon(
              icons.FluentIcons.checkmark_circle_20_regular,
            ),
            const SizedBox(width: 5),
            smallText(locale.installed, context),
          ],
        ),
      _versions(locale,
          alignment:
              isWide ? CrossAxisAlignment.end : CrossAxisAlignment.start),
      if (showMatch &&
          infos.match != null &&
          infos.match!.value.trim().isNotEmpty)
        Text(
          "${infos.match!.title(locale)}: ${infos.match!.value}",
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
        )
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        favicon(faviconSize()),
        if (isWide) ...[
          Expanded(
            child: nameAndSource(context),
          ),
          Column(
            mainAxisAlignment: columnAlign,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: versionsMatchAndInstalledMark.withSpaceBetween(height: 5),
          ),
        ] else
          Expanded(
              child: Column(
            mainAxisAlignment: columnAlign,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              nameAndSource(context),
              const SizedBox(height: 5),
              ...versionsMatchAndInstalledMark,
            ],
          )),
        if (isClickable()) ...[
          const SizedBox(width: 20),
          RightSideButtons(
            infos: infos,
            mainAlignment: MainAxisAlignment.spaceEvenly,
            upgrade: upgradeButton,
            install: installButton,
            uninstall: uninstallButton,
            iconsOnly: true,
          )
        ],
      ],
    );
  }

  Widget nameAndSource(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Builder(// to ensure rebuild if publisherNameFromDB() changes
        builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: columnAlign,
        children: [
          Text(
            infos.name?.value ?? '<Name>',
            style: _titleStyle(context),
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            infos.publisher?.nameFittingId ??
                infos.publisher?.nameFromDBbyPublisherId() ??
                Publisher.nameFromDBbyPackageId(infos.id?.value) ??
                infos.publisher?.id ??
                infos.id?.value.string ??
                '<ID>',
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
          ),
          sourceAndID(locale, context)
        ],
      );
    });
  }

  Widget sourceAndID(AppLocalizations locale, BuildContext context) {
    bool hasSource =
        infos.source.value != PackageSources.none || !defaultSourceIsLocalPC;
    bool showSource = true;
    bool showId = infos.id != null &&
        infos.id!.value.string.isNotEmpty &&
        (infos.publisher?.id != null ||
            infos.publisher?.nameFittingId != null ||
            infos.publisher?.nameFromDBbyPublisherId() != null ||
            Publisher.nameFromDBbyPackageId(infos.id?.value) != null);
    //AppLocalizations locale = AppLocalizations.of(context)!;
    return Row(
      children: [
        if (showSource)
          smallText(
              locale.fromSource(
                  hasSource ? infos.source.value.title : locale.localPC),
              context),
        if (showSource && showId)
          SizedBox(
            width: 15,
            child: Center(child: smallText('·', context)),
          ),
        if (showId) Expanded(child: smallText(infos.id!.value.string, context)),
      ],
    );
  }

  Widget smallText(String text, BuildContext context) {
    return Text(
      text,
      style: withoutColor(FluentTheme.of(context).typography.caption),
      //style: TextStyle(
      // color: FluentTheme.of(context).inactiveColor,
      //),
      textAlign: TextAlign.start,
      overflow: TextOverflow.ellipsis,
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

  Widget _versions(AppLocalizations locale,
      {CrossAxisAlignment alignment = CrossAxisAlignment.end}) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        if (infos.version != null)
          Text(
            "${infos.version!.title(locale)}: ${infos.version!.value.stringValue}",
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        if (infos.availableVersion != null &&
            infos.availableVersion!.value.isVersion())
          Text(
            "${infos.availableVersion!.title(locale)}: ${infos.availableVersion!.value.stringValue}",
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  bool isClickable() => infos.hasInfosFull();

  Widget favicon(double faviconSize) {
    return AppIcon.fromInfos(infos,
        iconSize: faviconSize, isClickable: isClickable());
  }

  static double faviconSize() => 60;

  static final Widget prototypeWidget = PackagePeek(
    PackageInfosPeek.exampleInfos,
    showInstalledIcon: true,
    showMatch: true,
  );
}
