import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum Winget {
  updates(
    name: _updatesLoc,
    command: ['upgrade'],
    icon: FluentIcons.substitutions_in,
  ),
  installed(name: _installedLoc, command: ['list'], icon: FluentIcons.library),
  about(name: _aboutLoc, command: ['--info'], icon: FluentIcons.info),
  help(name: _helpLoc, command: ['--help'], icon: FluentIcons.help),
  search(
      name: _searchLoc,
      command: ['search', "-n", '200'],
      icon: FluentIcons.search,
      titlePrefix: _searchTitlePrefixLoc),
  settings(
      name: _settingsLoc, command: ['settings'], icon: FluentIcons.settings),
  sources(
      name: _sourcesLoc,
      command: ['source'],
      icon: FluentIcons.database_source),
  install(
      name: _installLoc, command: ['install'], icon: FluentIcons.installation),
  upgrade(
      name: _upgradeLoc,
      command: ['upgrade'],
      icon: FluentIcons.substitutions_in),
  uninstall(
      name: _uninstallLoc, command: ['uninstall'], icon: FluentIcons.delete),
  ;

  final List<String> command;
  final IconData? icon;
  final String Function(AppLocalizations)? titlePrefix;
  final String Function(AppLocalizations) name;

  const Winget(
      {required this.command, required this.name, this.icon, this.titlePrefix});

  String titleWithInput(String input,
      {required AppLocalizations localization}) {
    String prefix;
    if (titlePrefix != null) {
      prefix = titlePrefix!(localization);
    } else {
      prefix = name(localization);
    }
    return "$prefix '$input'";
  }

  static String _updatesLoc(AppLocalizations local) => local.updates;
  static String _installedLoc(AppLocalizations local) => local.installed;
  static String _aboutLoc(AppLocalizations local) => local.about;
  static String _helpLoc(AppLocalizations local) => local.help;
  static String _searchLoc(AppLocalizations local) => local.search;
  static String _settingsLoc(AppLocalizations local) => local.settings;
  static String _sourcesLoc(AppLocalizations local) => local.sources;
  static String _installLoc(AppLocalizations local) => local.install;
  static String _upgradeLoc(AppLocalizations local) => local.upgrade;
  static String _uninstallLoc(AppLocalizations local) => local.uninstall;

  static String _searchTitlePrefixLoc(AppLocalizations local) =>
      local.searchTitlePrefix;
}
