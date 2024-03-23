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
  final void Function(String)? onHashtagTap;
  final void Function(String)? onMentionTap;

  const LinkText({
    required this.line,
    this.maxLines = maxValue,
    super.key,
    this.style,
    this.title,
    this.onHashtagTap,
    this.onMentionTap,
  });

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
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
      onUrlTap: launch,
      urlStyle: linkTextStyle,
      onHashtagTap: onHashtagTap,
      hashtagStyle: onHashtagTap != null ? linkTextStyle : null,
      onMentionTap: onMentionTap,
      mentionStyle: onMentionTap != null ? linkTextStyle : null,
    );
  }

  TextStyle get linkTextStyle {
    return const TextStyle(
      decoration: TextDecoration.underline,
    );
  }

  void launch(String url) {
    Uri link = Uri.parse(url);
   if (link.scheme.isEmpty) {
      link = link.replace(scheme: 'https');
    }
    launchUrl(link);
  }
}
