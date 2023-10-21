import 'package:expandable_text/expandable_text.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkText extends StatelessWidget {
  static const int maxValue = -1 >>> 1;
  final String line;
  final String? title;
  final int maxLines;
  final TextStyle? style;

  const LinkText(
      {required this.line, this.maxLines = maxValue, super.key, this.style, this.title});

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    //FluentThemeData theme = FluentTheme.of(context);
    //return Expander(header: Linkable(text: line,textColor: theme.activeColor, maxLines: 1,), content: Linkable(text: line, textColor: theme.activeColor),);
    return ExpandableText(
      line,
      style: style,
      prefixText: title,
      prefixStyle: const TextStyle(fontWeight: FontWeight.bold),
      linkEllipsis: false,
      expandText: locale.showMore,
      collapseText: locale.showLess,
      maxLines: maxLines,
      animation: true,
      linkColor: FluentTheme.of(context).accentColor,
      onUrlTap: (url) => launchUrl(Uri.parse(url)),
      urlStyle: const TextStyle(
        decoration: TextDecoration.underline,
      ),
    );
  }
}
