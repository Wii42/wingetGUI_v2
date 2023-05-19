import 'package:expandable_text/expandable_text.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'link_button.dart';

class ExpandableWidget extends StatelessWidget {
  final String title;
  final String text;
  final int maxLines;
  final LinkButton? linkButton;

  const ExpandableWidget({
    super.key,
    required this.title,
    required this.text,
    this.maxLines = 5,
    this.linkButton,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Text(title, style: FluentTheme.of(context).typography.title),
              if (linkButton != null)
                Padding(
                    padding: const EdgeInsetsDirectional.symmetric(vertical: 6),
                    child: linkButton!),
            ],
          ),
          ExpandableText(
            text,
            expandText: 'show more',
            collapseText: 'show less',
            maxLines: maxLines,
            linkColor: FluentTheme.of(context).accentColor,
          ),
        ],
      ),
    );
  }
}
