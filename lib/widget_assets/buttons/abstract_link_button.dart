import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/link.dart';

abstract class AbstractLinkButton extends StatelessWidget {
  final Uri url;

  const AbstractLinkButton({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Link(
      uri: url,
      builder: (context, open) {
        return Tooltip(
          message: url.toString(),
          useMousePosition: false,
          style: const TooltipThemeData(preferBelow: true),
          child: button(context, open),
        );
      },
    );
  }

  String checkUrlContainsHttp(String url) {
    if (url.startsWith('http://') ||
        url.startsWith('https://') ||
        url.startsWith('mailto:') ||
        url.startsWith('ms-windows-store://')) {
      return url;
    } else {
      return 'https://$url';
    }
  }

  BaseButton button(BuildContext context, Future<void> Function()? open);
}
