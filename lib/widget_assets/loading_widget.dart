import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/package_tables/db_message.dart';

class LoadingWidget extends StatelessWidget {
  final LocalizedString text;
  const LoadingWidget({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const ProgressRing(
          backgroundColor: Colors.transparent,
        ),
        Text(text(locale)),
      ].withSpaceBetween(height: 20),
    ));
  }
}
