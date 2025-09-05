import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_core/winget_core.dart';
import 'package:winget_gui/helpers/route_parameter.dart';
import 'package:winget_gui/l10n/generated/app_localizations.dart';
import 'package:winget_gui/winget_client/winget_command.dart';
import 'package:winget_gui/winget_process/output_page.dart';

enum Winget {
  updates('upgrade', options: ['--include-unknown'], aliases: ['update']),
  installed('list', aliases: ['ls']),
  about('--info'),
  help('--help', aliases: ['-?']),
  search('search', options: ["-n", '200'], aliases: ['find']),
  availablePackages('search', options: [''], aliases: ['find']),
  settings('settings', aliases: ['config']),
  sources('source', options: ['list']),
  install(
    'install',
    options: [
      '--disable-interactivity',
      '--accept-source-agreements',
      '--accept-package-agreements',
    ],
    aliases: ['add'],
    icon: FluentIcons.installation,
  ),
  upgrade(
    'upgrade',
    options: [
      '--include-unknown',
      '--disable-interactivity',
      '--accept-source-agreements',
      '--accept-package-agreements',
    ],
    aliases: ['update'],
    icon: FluentIcons.substitutions_in,
  ),
  upgradeAll('upgrade', options: ['--all'], aliases: ['update']),
  uninstall('uninstall', aliases: ['remove', 'rm'], icon: FluentIcons.delete),
  show('show', aliases: ['view']);

  final String baseCommand;
  final List<String> options;
  final List<String> aliases;
  final IconData? icon;

  const Winget(
    this.baseCommand, {
    this.options = const [],
    this.aliases = const [],
    this.icon,
  });

  String title(AppLocalizations local) {
    String title = local.wingetTitle(name);
    if (title == notFoundError) {
      throw Exception("$title: $name in Winget.title");
    }
    return title;
  }

  String titleWithInput(
    String input, {
    required AppLocalizations localization,
  }) {
    String titlePrefix = localization.wingetTitlePrefix(name);
    String prefix;
    if (titlePrefix != notFoundError) {
      prefix = titlePrefix;
    } else {
      prefix = title(localization);
    }
    return "$prefix $input".trim();
  }

  List<String> get fullCommand => [baseCommand, ...options];

  Widget processPage(RouteParameter? parameters) {
    //TODO: add parameters to command
    return Builder(
      builder: (context) {
        return OutputPage.fromWinget(
          this,
          parameters: [],
          titleInput: parameters?.titleAddon,
        );
      },
    );
  }

  List<String> get allNames => [baseCommand, ...aliases];

  static Winget? typeFromCmd(WingetCommand cmd){
    switch(cmd){
      case CmdInstall():
        return Winget.install;
      case CmdAbout():
        return Winget.about;
      case CmdHelp():
        return Winget.help;
      case CmdSettings():
        return Winget.settings;
      case CmdUpdate():
        return Winget.upgrade;
      case CmdShow():
        return Winget.show;
      case CmdCustom():
        return null;
      case CmdRunningCommands():
        return null;
      case CmdUpdates():
        return Winget.updates;
      case CmdInstalled():
        return Winget.installed;
      case CmdSearch():
        return Winget.search;
      case CmdAvailablePackages():
        return Winget.availablePackages;
      case CmdUninstall():
        return Winget.uninstall;
    }
  }
}
