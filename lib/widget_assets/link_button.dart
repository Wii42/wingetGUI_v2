import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/link.dart';

class LinkButton extends StatelessWidget {
  final String url;
  final Text text;

  const LinkButton({super.key, required this.url, required this.text});

  @override
  Widget build(BuildContext context) {
    return Link(
        uri: Uri.parse(checkUrlContainsHttp(url)),
        builder: (context, open) {
          return Tooltip(
            message: url,
            useMousePosition: false,
            style: const TooltipThemeData(preferBelow: true),
            child: Button(
              onPressed: open,
              child: text,
            ),
          );
        });
  }

  String checkUrlContainsHttp(String url) {
    if (url.startsWith('http://') ||
        url.startsWith('https://') ||
        url.startsWith('mailto:')) {
      return url;
    } else {
      return 'https://$url';
    }
  }
}
