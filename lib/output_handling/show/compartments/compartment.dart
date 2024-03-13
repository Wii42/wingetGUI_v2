import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/widget_assets/link_text.dart';

import '../../../widget_assets/inline_link_button.dart';

abstract class Compartment extends StatelessWidget {
  const Compartment({super.key});

  List<Widget> buildCompartment(BuildContext context);

  TextStyle? compartmentTitleStyle(Typography typography) {
    return typography.bodyLarge
        ?.merge(const TextStyle(inherit: true, fontWeight: FontWeight.w500));
  }

  Widget textOrInlineLink(
      {required BuildContext context,
      required String? text,
      required Uri? url}) {
    if (url != null && url.toString().isNotEmpty) {
      return InlineLinkButton(url: url, text: Text(text ?? url.toString()));
    }
    return textWithLinks(text: text!, context: context);
  }

  Widget textWithLinks(
      {required String text, required BuildContext context, int maxLines = 1}) {
    return LinkText(
      line: text,
      maxLines: maxLines,
    );
  }
}
