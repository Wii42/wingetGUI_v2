import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/string_extension.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/table/apps_table/package_peek.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../routes.dart';
import '../../../winget_commands.dart';
import '../../package_infos/package_infos_peek.dart';

class PackageList extends StatefulWidget {
  final List<PackageInfosPeek> packagesInfos;
  final List<String> command;
  final bool initialOnlyClickablePackages;

  const PackageList(this.packagesInfos,
      {super.key,
      required this.command,
      this.initialOnlyClickablePackages = false});

  @override
  State<StatefulWidget> createState() => _PackageListState();

  bool hasUnClickablePackages() {
    for (PackageInfosPeek package in packagesInfos) {
      if (!package.hasInfosFull()) {
        return true;
      }
    }
    return false;
  }
}

class _PackageListState extends State<PackageList> {
  late bool onlyClickablePackages;
  late List<PackageInfosPeek> searchablePackages;
  TextEditingController filterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    onlyClickablePackages = widget.initialOnlyClickablePackages;
    searchablePackages = selectedPackages();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          settings(),
          ...listWithNrOfPackagesInfo(filteredPackages()
              .map((e) => PackagePeek(e, command: widget.command))
              .toList()),
        ].withSpaceBetween(height: 10));
  }

  List<PackageInfosPeek> selectedPackages() {
    if (onlyClickablePackages) {
      return [
        for (PackageInfosPeek package in widget.packagesInfos)
          if (package.hasInfosFull()) package
      ];
    }
    return widget.packagesInfos;
  }

  List<PackageInfosPeek> filteredPackages() {
    if (filter.isEmpty) {
      searchablePackages;
    }
    return [
      for (PackageInfosPeek package in searchablePackages)
        if ((package.name != null &&
                package.name!.value.containsCaseInsensitive(filter)) ||
            (package.id != null &&
                package.id!.value.containsCaseInsensitive(filter)))
          package
    ];
  }

  List<Widget> listWithNrOfPackagesInfo(List<Widget> shownPackages) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return [
      ...shownPackages,
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Text(
          locale.nrOfPackagesShown(
              shownPackages.length, widget.packagesInfos.length),
          style: FluentTheme.of(context).typography.caption,
        ),
      ),
    ];
  }

  Widget settings() {
    return Wrap(
      spacing: 50,
      runSpacing: 10,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (widget.hasUnClickablePackages()) onlyClickableCheckbox(),
        if (isUpdatesList()) updateAllButton(),
        if (searchablePackages.length >= 5) filterField(),
      ],
    );
  }

  Widget onlyClickableCheckbox() {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 10,
      children: [
        Checkbox(
          checked: onlyClickablePackages,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                onlyClickablePackages = value;
                searchablePackages = selectedPackages();
              });
            }
          },
        ),
        Text(locale.showOnlyClickablePackages),
      ],
    );
  }

  bool isUpdatesList() => (Winget.updates.allNames.contains(widget.command[0]));

  Button updateAllButton() {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Button(
      onPressed: () {
        NavigatorState navigator = Navigator.of(context);
        navigator.pushNamed(Routes.upgradeAll.route);
      },
      child: Text(Winget.upgradeAll.title(locale)),
    );
  }

  Widget filterField() {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: TextFormBox(
          controller: filterController,
          prefix: Padding(
            padding: const EdgeInsets.only(
              left: 10,
            ),
            child: Text(locale.filterFor),
          ),
          onChanged: (_) {
            setState(() {});
          }),
    );
  }

  String get filter => filterController.text;
}
