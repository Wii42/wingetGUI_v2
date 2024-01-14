import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:winget_gui/helpers/extensions/app_localizations_extension.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/package_infos/installer_infos.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/package_infos/to_string_info_extensions.dart';

import '../../widget_assets/app_locale.dart';
import '../package_infos/info.dart';
import '../package_infos/installer_objects/computer_architecture.dart';
import '../package_infos/installer_objects/install_scope.dart';
import '../package_infos/installer_objects/installer.dart';
import '../package_infos/installer_objects/installer_type.dart';
import '../package_infos/package_attribute.dart';
import 'compartments/expander_compartment.dart';
import 'compartments/installer_details.dart';
import 'installer_differences.dart';

class StatefulInstallerWidget extends StatefulWidget {
  late final _InstallerCompartmentStub _template;
  final InstallerInfos infos;
  StatefulInstallerWidget({required this.infos, super.key})
      : _template = _InstallerCompartmentStub(infos: infos);

  @override
  State<StatefulWidget> createState() => _StatefulInstallerWidgetState();
}

class _StatefulInstallerWidgetState extends State<StatefulInstallerWidget> {
  final Locale matchAllLocale = const Locale('<match all>');

  ComputerArchitecture? installerArchitecture;
  InstallerType? installerType;
  Locale? installerLocale;
  InstallScope? installerScope;

  Installer? selectedInstaller;

  @override
  void initState() {
    super.initState();
    selectedInstaller = infos.installers?.value.first;
    installerArchitecture = selectedInstaller?.architecture.value;
    installerType = selectedInstaller?.type?.value;
    installerLocale = selectedInstaller?.locale?.value;
    installerScope = selectedInstaller?.scope?.value;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations localization = AppLocalizations.of(context)!;
    Locale? locale = AppLocale.of(context).guiLocale;

    Installer? installer = selectedInstaller;

    List<Info<String>?> details = [
      installer?.architecture.toStringInfo(),
      (installer?.type ?? infos.type)?.toStringInfo(),
      (installer?.locale ?? infos.locale)?.toStringInfo(context),
      infos.releaseDate?.toStringInfo(locale),
      (installer?.scope ?? infos.scope)?.toStringInfo(context),
      installer?.minimumOSVersion ?? infos.minimumOSVersion,
      (installer?.platform ?? infos.platform)?.toStringInfo(),
      selectedInstaller?.availableCommands?.toStringInfo(),
      (installer?.nestedInstallerType ?? infos.nestedInstallerType)
          ?.toStringInfo(),
      (installer?.upgradeBehavior ?? infos.upgradeBehavior)
          ?.toStringInfo(context),
      (installer?.modes ?? infos.installModes)?.toStringInfo(localization),
      infos.storeProductID,
      installer?.sha256Hash ?? infos.sha256Hash,
      //infos.installerSwitches,
      installer?.elevationRequirement ?? infos.elevationRequirement,
      installer?.productCode ?? infos.productCode,
      infos.dependencies?.toStringInfo(),
      installer?.signatureSha256,
    ];

    Widget content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: template.fullCompartment(
            title: template.compartmentTitle(localization),
            mainColumn: [
              if (infos.installers != null) selectInstallerWidget(context),
              if (infos.installers != null &&
                  infos.installers!.value.length > 1)
                template.divider(),
              ...template.detailsList(details, context),
              ...template.displayRest(infos.otherInfos, context),
              ...template.displayRest(selectedInstaller?.other, context)
            ],
            buttonRow: template.buttonRow([
              infos.url,
              selectedInstaller?.url.copyWith(
                  customTitle: localization.downloadInstallerManually(
                      selectedInstaller?.uniqueProperties(
                          infos.installers!.value, context)))
            ], context),
            context: context));
    return widget._template.buildWithoutContent(context, content);
  }

  InstallerInfos get infos => widget.infos;
  ExpanderCompartment get template => widget._template;

  Widget selectInstallerWidget(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    LocaleNames localeNames = LocaleNames.of(context)!;
    InstallerDifferences differences =
        InstallerDifferences.fromList(infos.installers!.value, context);
    bool onlyArchitectureOption = differences.types.length <= 1 &&
        differences.locales.length <= 1 &&
        differences.scopes.length <= 1;
    bool onlyTypeOption = differences.architectures.length <= 1 &&
        differences.locales.length <= 1 &&
        differences.scopes.length <= 1;
    bool onlyLocaleOption = differences.architectures.length <= 1 &&
        differences.types.length <= 1 &&
        differences.scopes.length <= 1;
    bool onlyScopeOption = differences.architectures.length <= 1 &&
        differences.types.length <= 1 &&
        differences.locales.length <= 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (infos.installers != null && infos.installers!.value.length > 1)
          Text(
            '${infos.installers?.value.length} installers found for this package. Select the one you want to see:',
          ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            if (differences.architectures.length > 1)
              boxSelectInstaller<ComputerArchitecture>(
                categoryName: differences.architectureTitle,
                options: differences.architectures,
                title: (item) => item.title,
                value: installerArchitecture,
                onChanged: (value) {
                  if (value != null) {
                    setState(
                      () {
                        installerArchitecture = value;
                        selectedInstaller = fittingInstallers.firstOrNull;
                      },
                    );
                  }
                },
                matchAll: !onlyArchitectureOption
                    ? ComputerArchitecture.matchAll
                    : null,
              ),
            if (differences.types.length > 1)
              boxSelectInstaller<InstallerType?>(
                categoryName: differences.typeTitle,
                options: differences.types,
                title: (item) => item?.fullTitle ?? 'null',
                value: installerType,
                onChanged: (value) {
                  setState(
                    () {
                      installerType = value;
                      selectedInstaller = fittingInstallers.firstOrNull;
                    },
                  );
                },
                matchAll: !onlyTypeOption ? InstallerType.matchAll : null,
              ),
            if (differences.locales.length > 1)
              boxSelectInstaller<Locale?>(
                categoryName: differences.localeTitle,
                options: differences.locales,
                title: (item) =>
                    localeNames.nameOf(item.toString()) ??
                    item?.toLanguageTag() ??
                    'null',
                value: installerLocale,
                onChanged: (value) {
                  setState(
                    () {
                      installerLocale = value;
                      selectedInstaller = fittingInstallers.firstOrNull;
                    },
                  );
                },
                matchAll: !onlyLocaleOption ? matchAllLocale : null,
              ),
            if (differences.scopes.length > 1)
              boxSelectInstaller<InstallScope?>(
                categoryName: differences.scopeTitle,
                options: differences.scopes,
                title: (item) => item?.title(localizations) ?? 'null',
                value: installerScope,
                onChanged: (value) {
                  setState(
                    () {
                      installerScope = value;
                      selectedInstaller = fittingInstallers.firstOrNull;
                    },
                  );
                },
                matchAll: !onlyScopeOption ? InstallScope.matchAll : null,
              ),
            if (infos.installers != null && fittingInstallers.length >= 2)
              boxSelectInstaller<Installer>(
                  categoryName:
                      '${fittingInstallers.length} installer found for the selected options. Select one:',
                  options: fittingInstallers,
                  title: (item) =>
                      item.uniqueProperties(fittingInstallers, context),
                  value: selectedInstaller,
                  onChanged: (value) {
                    setState(() => selectedInstaller = value);
                  }),
            if (infos.installers != null && fittingInstallers.isEmpty)
              Text(
                'No installer found for the selected options.',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ].withSpaceBetween(height: 20),
    );
  }

  Widget boxSelectInstaller<T>(
      {required String categoryName,
      required List<T> options,
      required String Function(T) title,
      T? value,
      void Function(T?)? onChanged,
      T? matchAll}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(categoryName),
        ComboBox<T>(
          items: [
            for (T item in options)
              ComboBoxItem(value: item, child: Text(title(item))),
            if (matchAll != null)
              ComboBoxItem(value: matchAll, child: Text(title(matchAll))),
          ],
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  List<Installer> get fittingInstallers {
    return infos.installers?.value
            .where((installer) =>
                (installer.architecture.value == installerArchitecture ||
                    installerArchitecture == ComputerArchitecture.matchAll) &&
                (installer.type?.value == installerType ||
                    installerType == InstallerType.matchAll) &&
                (installer.locale?.value == installerLocale ||
                    installerLocale == matchAllLocale) &&
                (installer.scope?.value == installerScope ||
                    installerScope == InstallScope.matchAll))
            .toList() ??
        [];
  }
}

class _InstallerCompartmentStub extends ExpanderCompartment {
  final InstallerInfos infos;

  const _InstallerCompartmentStub({required this.infos});

  @override
  List<Widget> buildCompartment(BuildContext context) {
    throw UnimplementedError();
  }

  @override
  String compartmentTitle(AppLocalizations locale) {
    return PackageAttribute.installer.title(locale);
  }

  @override
  final IconData titleIcon = FluentIcons.install_to_drive;

  @override
  bool get initiallyExpanded => false;
}
