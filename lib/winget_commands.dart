import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/route_parameter.dart';
import 'package:winget_gui/winget_process/output_page.dart';

const String notFoundError = "NotFoundError";

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
  upgrade('upgrade',
      options: [
        '--include-unknown',
        '--disable-interactivity',
        '--accept-source-agreements',
        '--accept-package-agreements',
      ],
      aliases: ['update'],
      icon: FluentIcons.substitutions_in),
  upgradeAll('upgrade', options: ['--all'], aliases: ['update']),
  uninstall('uninstall', aliases: ['remove', 'rm'], icon: FluentIcons.delete),
  show('show', aliases: ['view']);

  final String baseCommand;
  final List<String> options;
  final List<String> aliases;
  final IconData? icon;

  const Winget(this.baseCommand,
      {this.options = const [], this.aliases = const [], this.icon});

  String title(AppLocalizations local) {
    String title = local.wingetTitle(name);
    if (title == notFoundError) {
      throw Exception("$title: $name in Winget.title");
    }
    return title;
  }

  String titleWithInput(String input,
      {required AppLocalizations localization}) {
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
    return Builder(builder: (context) {
      return OutputPage.fromWinget(
        this,
        parameters: [...?parameters?.commandParameter],
        titleInput: parameters?.titleAddon,
      );
    });
  }

  List<String> get allNames => [baseCommand, ...aliases];
}
