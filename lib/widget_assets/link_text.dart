import 'package:expandable_text/expandable_text.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkText extends StatelessWidget {
  static const int maxValue = -1 >>> 1;
  final String line;
  final int maxLines;
  final TextStyle? style;

  const LinkText(
      {required this.line, this.maxLines = maxValue, super.key, this.style});

  @override
  Widget build(BuildContext context) {
    //return ExpandablePanel(collapsed: Text(line,maxLines: maxLines), expanded: Text( line));
    return ExpandableText(
      line,
      style: style,
      linkEllipsis: false,
      expandText: 'show more',
      collapseText: 'show less',
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
