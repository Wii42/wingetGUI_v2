import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/string_extension.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/table/apps_table/package_short_info.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../routes.dart';
import '../../../winget_commands.dart';

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

  bool hasUnClickablePackages() {
    for (PackageShortInfo package in packages) {
      if (!package.isClickable()) {
        return true;
      }
    }
    return false;
  }
}

class _PackageListState extends State<PackageList> {
  late bool onlyClickablePackages;
  late List<PackageShortInfo> searchablePackages;
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
          ...listWithNrOfPackagesInfo(filteredPackages()),
        ].withSpaceBetween(height: 10));
  }

  List<PackageShortInfo> selectedPackages() {
    if (onlyClickablePackages) {
      return [
        for (PackageShortInfo package in widget.packages)
          if (package.isClickable()) package
      ];
    }
    return widget.packages;
  }

  List<PackageShortInfo> filteredPackages() {
    if (filter.isEmpty) {
      searchablePackages;
    }
    return [
      for (PackageShortInfo package in searchablePackages)
        if ((package.name() != null &&
                package.name()!.containsCaseInsensitive(filter)) ||
            (package.id() != null &&
                package.id()!.containsCaseInsensitive(filter)))
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
              shownPackages.length, widget.packages.length),
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

  bool isUpdatesList() => (widget.command[0] == Winget.updates.command[0]);

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