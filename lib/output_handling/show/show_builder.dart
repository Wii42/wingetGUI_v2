import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/output_handling/show/compartments/title_widget.dart';
import 'package:winget_gui/output_handling/show/package_long_info.dart';

import '../../winget_commands.dart';
import '../package_infos/package_infos_full.dart';

class ShowBuilder extends StatelessWidget {
  final PackageInfosFull infos;
  final List<String> command;
  const ShowBuilder({super.key, required this.infos, required this.command});

  @override
  Widget build(BuildContext context) {
    if (Winget.show.allNames.contains(command[0])) {
      return PackageLongInfo(infos);
    }
    return PackageInfoSliver(infos: infos);
  }
}

class PackageInfoSliver extends TitleWidget {
  const PackageInfoSliver({required super.infos, super.key});

  @override
  TextStyle? titleStyle(Typography typography) {
    return typography.title;
  }

  @override
  TextStyle? versionStyle(Typography typography) {
    return compartmentTitleStyle(typography);
  }

  @override
  Widget buildRightSide() {
    if (infos.id != null) {
      return Text(infos.id!.value);
    }
    return const SizedBox();
  }
}
