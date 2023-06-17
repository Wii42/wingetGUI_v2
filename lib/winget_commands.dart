import 'package:fluent_ui/fluent_ui.dart';

enum Winget {
  updates(
      name: 'Updates',
      command: ['upgrade'],
      icon: FluentIcons.substitutions_in),
  installed(name: 'Installed', command: ['list'], icon: FluentIcons.library),
  about(name: "About Winget", command: ['--info'], icon: FluentIcons.info),
  help(name: "Help", command: ['--help'], icon: FluentIcons.help),
  search(
      name: "Search Packages",
      command: ['search', "-n", '200'],
      icon: FluentIcons.search,
  titlePrefix: 'Search'),
  settings(
      name: "Winget Settings",
      command: ['settings'],
      icon: FluentIcons.settings),
  sources(
      name: 'Sources', command: ['source'], icon: FluentIcons.database_source),
  install(
      name: 'Install', command: ['install'], icon: FluentIcons.installation),
  upgrade(
      name: 'Upgrade',
      command: ['upgrade'],
      icon: FluentIcons.substitutions_in),
  uninstall(
      name: 'Uninstall', command: ['uninstall'], icon: FluentIcons.delete),
  ;

  final String name;
  final List<String> command;
  final IconData? icon;
  final String? titlePrefix;

  const Winget(
      {required this.name, required this.command, this.icon, this.titlePrefix});

  String titleWithInput(String input){
    String prefix = titlePrefix ?? name;
    return "$prefix '$input'";
  }
}
