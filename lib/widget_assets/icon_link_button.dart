import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluent_ui/src/controls/inputs/buttons/base.dart';

import 'package:flutter/src/widgets/framework.dart';

import 'abstract_link_button.dart';


class IconLinkButton extends AbstractLinkButton{
  final IconData icon;
  const IconLinkButton({super.key, required super.url, this.icon = FluentIcons.open_in_new_window});

  @override
  BaseButton button(BuildContext context, Future<void> Function()? open) {
   return  IconButton(icon: Icon(icon), onPressed: open,);
  }

}