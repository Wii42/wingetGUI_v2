import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/string_map_extension.dart';
import 'package:winget_gui/widget_assets/right_side_buttons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../content/content_holder.dart';
import '../../content/content_pane.dart';
import '../info_enum.dart';
import '../infos.dart';

class PackageShortInfo extends StatelessWidget {
  final Infos infos;

  final MainAxisAlignment columnAlign = MainAxisAlignment.center;

  const PackageShortInfo(this.infos, {super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Button(
      onPressed: (isClickable(locale))
          ? () {
              ContentPane? target = ContentHolder.maybeOf(context)?.content;
              if (target != null && infos.details.hasInfo(Info.id, locale)) {
                target.showResultOfCommand(
                    ['show', '--id', infos.details[Info.id.key(locale)]!],
                    title: infos.details[Info.name.key(locale)]);
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
          children: _versions([Info.version, Info.availableVersion], locale),
        ),
        if (isClickable(locale)) ...[
          const SizedBox(width: 20),
          RightSideButtons(
            infos: infos.details,
            alignment: columnAlign,
            upgrade: infos.details.hasInfo(Info.availableVersion, locale),
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
          infos.details[Info.name.key(locale)]!,
          style: _titleStyle(context),
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          infos.details[Info.id.key(locale)]!,
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
        ),
        if (infos.details.hasInfo(Info.source, locale))
          Text(
            locale.fromSource(infos.details[Info.source.key(locale)]!),
            style: TextStyle(
              color: FluentTheme.of(context).disabledColor,
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
      style = style?.apply(color: FluentTheme.of(context).disabledColor);
    }
    return style;
  }

  List<Widget> _versions(List<Info> versions, AppLocalizations locale) {
    return [
      for (Info info in versions)
        if (infos.details.hasInfo(info, locale))
          Text("${info.title(locale)}: ${infos.details[info.key(locale)]!}"),
    ];
  }

  bool isClickable(AppLocalizations locale) {
    return infos.details.hasInfo(Info.source, locale);
  }
}
