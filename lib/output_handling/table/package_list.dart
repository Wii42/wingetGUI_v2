import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/table/package_short_info.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../routes.dart';
import '../../winget_commands.dart';

class PackageList extends StatefulWidget {
  final List<PackageShortInfo> packages;
  final List<String> command;
  final bool initialOnlyClickablePackages;

  const PackageList(this.packages,
      {super.key,
      required this.command,
      this.initialOnlyClickablePackages = false});

  @override
  State<StatefulWidget> createState() => _PackageListState();

  bool hasUnClickablePackages(AppLocalizations locale) {
    for (PackageShortInfo package in packages) {
      if (!package.isClickable(locale)) {
        return true;
      }
    }
    return false;
  }
}

class _PackageListState extends State<PackageList> {
  late bool onlyClickablePackages;

  @override
  void initState() {
    super.initState();
    onlyClickablePackages = widget.initialOnlyClickablePackages;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.hasUnClickablePackages(locale))
            Wrap(
              spacing: 10,
              children: [
                Checkbox(
                  checked: onlyClickablePackages,
                  onChanged: (value) {
                    if (value != null) {
                      setState(
                        () {
                          onlyClickablePackages = value;
                        },
                      );
                    }
                  },
                ),
                Text(locale.showOnlyClickablePackages),
              ],
            ),
          if (widget.command[0] == Winget.updates.command[0])
            Button(
              onPressed: () {
                NavigatorState navigator = Navigator.of(context);
                navigator.pushNamed(Routes.upgradeAll.route);
              },
              child: Text(Winget.upgradeAll.title(locale)),
            ),
          ...selectedPackages(locale),
        ].withSpaceBetween(height: 10));
  }

  List<Widget> selectedPackages(AppLocalizations locale) {
    if (onlyClickablePackages) {
      return [
        for (PackageShortInfo package in widget.packages)
          if (package.isClickable(locale)) package
      ];
    }

    return widget.packages;
  }
}
