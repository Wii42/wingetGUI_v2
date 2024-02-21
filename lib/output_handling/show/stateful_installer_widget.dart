import 'package:collection/collection.dart';
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
import 'installer_differences.dart';
import 'package:winget_gui/helpers/extensions/best_fitting_locale.dart';

class StatefulInstallerWidget extends StatefulWidget {
  late final _InstallerCompartmentStub _template;
  final InstallerInfos infos;
  final Locale? guiLocale, defaultLocale;
  StatefulInstallerWidget(
      {required this.infos, super.key, this.guiLocale, this.defaultLocale})
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
    selectedInstaller = getBestFittingLocaleInstaller();
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
      installer?.storeProductID ?? infos.storeProductID,
      installer?.sha256Hash ?? infos.sha256Hash,
      installer?.elevationRequirement ?? infos.elevationRequirement,
      installer?.productCode ?? infos.productCode,
      infos.dependencies?.toStringInfo(),
      installer?.signatureSha256,
      installer?.markets,
      installer?.packageFamilyName,
      (installer?.expectedReturnCodes ?? infos.expectedReturnCodes)
          ?.toStringInfo(localization),
      (installer?.successCodes ?? infos.successCodes)
          ?.toStringInfoFromList((e) => e.toString()),
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
              selectedInstaller?.url?.copyWith(
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
    print(Installer.equivalenceClasses(infos.installers!.value));
    AppLocalizations localizations = AppLocalizations.of(context)!;
    LocaleNames localeNames = LocaleNames.of(context)!;
    InstallerDifferences differences =
        InstallerDifferences.fromList(infos.installers!.value, context);
    int possibleCombinations = differences.architectures.length *
        differences.types.length *
        differences.locales.length *
        differences.scopes.length;
    bool hasAllPossibleCombinations =
        possibleCombinations == infos.installers?.value.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (infos.installers != null && infos.installers!.value.length > 1)
          Text(
            localizations.multipleInstallersFound(
                infos.installers?.value.length ?? '<?>'),
          ),
        if (infos.installers!.value.length == 2)
          boxSelectInstaller<Installer>(
              categoryName: Installer.uniquePropertyNames(
                  infos.installers!.value, context),
              options: infos.installers!.value,
              title: (item) =>
                  item.uniqueProperties(infos.installers!.value, context, longNames: true),
              value: selectedInstaller,
              onChanged: (value) {
                setState(() => selectedInstaller = value);
              })
        else
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
                  matchAll: !hasAllPossibleCombinations
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
                  matchAll: !hasAllPossibleCombinations
                      ? InstallerType.matchAll
                      : null,
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
                  matchAll: !hasAllPossibleCombinations ? matchAllLocale : null,
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
                  matchAll: !hasAllPossibleCombinations
                      ? InstallScope.matchAll
                      : null,
                ),
              if (infos.installers != null && fittingInstallers.length >= 2)
                boxSelectInstaller<Installer>(
                    categoryName: localizations.multipleFittingInstallersFound(
                        fittingInstallers.length),
                    options: fittingInstallers,
                    title: (item) =>
                        item.uniqueProperties(fittingInstallers, context),
                    value: selectedInstaller,
                    onChanged: (value) {
                      setState(() => selectedInstaller = value);
                    }),
              if (infos.installers != null && fittingInstallers.isEmpty)
                Text(
                  localizations.noInstallerFound,
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
        if (categoryName.isNotEmpty) Text(categoryName, style: FluentTheme.of(context).typography.caption),
        ComboBox<T>(
          items: [
            for (T item in options)
              ComboBoxItem(
                  value: item,
                  child: Text(title(item), overflow: TextOverflow.ellipsis)),
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

  Installer? getBestFittingLocaleInstaller() {
    if (widget.guiLocale != null) {
      List<Locale> installerLocales = infos.installers?.value
              .map((e) => e.locale?.value)
              .nonNulls
              .toList() ??
          [];
      if (installerLocales.length <= 1) {
        return infos.installers?.value.firstOrNull;
      }
      Locale? bestFitting = getBestFittingLocale(installerLocales);
      if (bestFitting != null) {
        return infos.installers?.value
            .firstWhereOrNull((e) => e.locale?.value == bestFitting);
      }
    }
    return widget.infos.installers?.value.firstOrNull;
  }

  Locale? getBestFittingLocale(List<Locale> installerLocales) {
    if (widget.guiLocale != null) {
      Locale? bestFitting =
          widget.guiLocale?.bestFittingLocale(installerLocales);
      if (bestFitting != null) {
        return bestFitting;
      }
    }
    if (widget.defaultLocale != null) {
      return widget.defaultLocale?.bestFittingLocale(installerLocales);
    }
    return null;
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
