import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/string_extension.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/table/apps_table/package_peek.dart';

import '../../../routes.dart';
import '../../../winget_commands.dart';
import '../../package_infos/package_infos_peek.dart';

class PackageList extends StatefulWidget {
  final List<PackageInfosPeek> packagesInfos;
  final List<String> command;
  final bool initialOnlyClickablePackages;
  final bool initialOnlyWithSpecificVersion;

  const PackageList(this.packagesInfos,
      {super.key,
      required this.command,
      this.initialOnlyClickablePackages = false,
      this.initialOnlyWithSpecificVersion = true});

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

  bool hasPackagesWithoutSpecificVersion() {
    for (PackageInfosPeek package in packagesInfos) {
      if (!package.hasSpecificVersion()) {
        return true;
      }
    }
    return false;
  }
}

class _PackageListState extends State<PackageList> {
  late bool onlyClickablePackages;
  late bool onlyWithSpecificVersion;
  late List<PackageInfosPeek> searchablePackages;
  TextEditingController filterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    onlyClickablePackages = widget.initialOnlyClickablePackages;
    onlyWithSpecificVersion = widget.initialOnlyWithSpecificVersion;
    searchablePackages = selectedPackages();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          settings(),
          ...listWithNrOfPackagesInfo(filteredPackages()
              .map((e) => PackagePeek.fromCommand(e, command: widget.command))
              .toList()),
        ].withSpaceBetween(height: 10));
  }

  List<PackageInfosPeek> selectedPackages() {
    List<PackageInfosPeek> visiblePackages = [];
    if (onlyClickablePackages) {
      visiblePackages = widget.packagesInfos
          .where((element) => element.hasInfosFull())
          .toList();
    } else {
      visiblePackages = widget.packagesInfos;
    }

    if (onlyWithSpecificVersion) {
      visiblePackages = visiblePackages
          .where((element) => element.hasSpecificVersion())
          .toList();
    }
    return visiblePackages;
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
        if (widget.hasPackagesWithoutSpecificVersion())
          onlyWithSpecificVersionCheckbox(),
        if (isUpdatesList()) updateAllButton(),
        if (searchablePackages.length >= 5) filterField(),
      ],
    );
  }

  Widget onlyClickableCheckbox() {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Checkbox(
      checked: onlyClickablePackages,
      content: Text(locale.showOnlyClickablePackages),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            onlyClickablePackages = value;
            searchablePackages = selectedPackages();
          });
        }
      },
    );
  }

  Widget onlyWithSpecificVersionCheckbox() {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Checkbox(
      checked: onlyWithSpecificVersion,
      content: Text(locale.showOnlyPackagesWithSpecificVersion),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            onlyWithSpecificVersion = value;
            searchablePackages = selectedPackages();
          });
        }
      },
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
            child: Text(locale.searchFor),
          ),
          onChanged: (_) {
            setState(() {});
          }),
    );
  }

  String get filter => filterController.text;
}
