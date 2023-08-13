import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/table/package_short_info.dart';

class PackageList extends StatelessWidget {
  final List<PackageShortInfo> packages;
  final List<String> command;

  const PackageList(this.packages, {super.key, required this.command});

  @override
  Widget build(BuildContext context) {
    return Column(children: packages.withSpaceBetween(height: 10));
  }
}
