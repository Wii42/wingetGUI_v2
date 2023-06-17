import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/widget_assets/run_button.dart';

import '../winget_commands.dart';

const Winget winget = Winget.search;

class SearchButton extends RunButton {
  
  
  const SearchButton.create(
      {super.key, required super.text, super.title, required super.command});

  factory SearchButton({
    Key? key,
    required String searchTarget,
    String? title,
  }) =>
      SearchButton.create(
        key: key,
        text: searchTarget,
        command: [...winget.command, searchTarget],
        title: title ?? winget.titleWithInput(searchTarget),
      );

  @override
  BaseButton buttonType(BuildContext context) =>
      Button(onPressed: onPressed(context), child: child());
}
