import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/link.dart';

import 'abstract_button.dart';
import 'tooltips.dart';

abstract class AbstractLinkButton extends AbstractButton {
  final Uri url;

  const AbstractLinkButton({super.key, required this.url});

  @override
  ButtonTooltip buildTooltip(BuildContext context, {required Widget child}) {
    return LinkToolTip(
        useMousePosition: false,
        url: url,
        button: Link(
          uri: url,
          builder: (context, open) => child,
        ));
  }

  @override
  Widget buildButton(BuildContext context) {
    return Link(
      uri: url,
      builder: (context, open) => buttonType(
        child: child,
        onPressed: disabledOrNullOr(open),
      ),
    );
  }

  Future<void> Function()? disabledOrNullOr(
          Future<void> Function()? onPressed) =>
      disabled || onPressed == null ? null : onPressed;
}
