import 'package:fluent_ui/fluent_ui.dart';

enum Winget {
  updates(
      name: 'Updates',
      command: ['upgrade'],
      icon: FluentIcons.substitutions_in),
  installed(name: 'Installed', command: ['list'], icon: FluentIcons.library),
  about(
      name: "About Winget", command: ['--info'], icon: FluentIcons.info),
  help(
      name: "Help", command: ['--help'], icon: FluentIcons.help),
  search(name: "Search Packages", command:  ['search'], icon: FluentIcons.search),
  settings(name: "Winget Settings", command: ['settings'], icon: FluentIcons.settings),
sources(name: 'Sources', command: ['source'], icon: FluentIcons.database_source)
  ;

  final String name;
  final List<String> command;
  final IconData? icon;

  const Winget({required this.name, required this.command, this.icon});
}
