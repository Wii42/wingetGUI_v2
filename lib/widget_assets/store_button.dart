import 'package:fluent_ui/fluent_ui.dart';
import 'package:open_store/open_store.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StoreButton extends StatelessWidget {
  final String storeId;
  final String? text;

  const StoreButton({super.key, required this.storeId, this.text});

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Button(
        child: Text(text ?? locale.showInStore),
        onPressed: () {
          OpenStore.instance.open(windowsProductId: storeId);
        });
  }
}
