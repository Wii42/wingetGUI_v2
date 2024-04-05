import 'abstract_button.dart';
import 'abstract_link_button.dart';

class LinkButton extends AbstractLinkButton
    with TextButtonMixin, PlainButtonMixin {
  @override
  final String buttonText;

  const LinkButton({super.key, required super.url, required this.buttonText});
}
