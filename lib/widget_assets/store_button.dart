import 'package:fluent_ui/fluent_ui.dart';
import 'package:open_store/open_store.dart';

class StoreButton extends StatelessWidget {
  final String storeId;
  final Text text;

  const StoreButton(
      {super.key, required this.storeId, this.text = const Text("Show in Store")});

  @override
  Widget build(BuildContext context) {
    return Button(
        child: text,
        onPressed: () {
          OpenStore.instance.open(windowsProductId: storeId);
        });
  }
}
