import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_store/open_store.dart';
import 'package:winget_gui/widget_assets/buttons/abstract_button.dart';
import 'package:winget_gui/widget_assets/buttons/normal_button.dart';

class StoreButton extends NormalButton
    with CustomToolTipMixin, PlainButtonMixin, TextButtonMixin {
  final String storeId;
  final String? text;
  final AppLocalizations locale;

  const StoreButton(
      {super.key, required this.storeId, this.text, required this.locale});

  @override
  void onPressed(BuildContext context) {
    OpenStore.instance.open(windowsProductId: storeId);
  }

  @override
  String get buttonText => text ?? locale.showInStore;

  @override
  String Function(AppLocalizations) get tooltipMessage =>
      (locale) => locale.openMSStorePageTooltip;
}
