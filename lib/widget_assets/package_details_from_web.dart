import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:winget_gui/global_app_data.dart';
import 'package:winget_gui/helpers/log_stream.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_full.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_peek.dart';
import 'package:winget_gui/output_handling/show/package_long_info.dart';
import 'package:winget_gui/package_sources/github_api/github_rate_limit_exception.dart';
import 'package:winget_gui/package_sources/no_internet_exception.dart';
import 'package:winget_gui/package_sources/package_source.dart';
import 'package:winget_gui/winget_commands.dart';

import 'link_text.dart';
import 'pane_item_body.dart';
import 'scroll_list_widget.dart';

class PackageDetailsFromWeb extends StatelessWidget {
  late final Logger log;
  final PackageInfosPeek package;
  final String? titleInput;
  PackageDetailsFromWeb({super.key, required this.package, this.titleInput}) {
    log = Logger(this);
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations localization = AppLocalizations.of(context)!;
    return PaneItemBody(
      title: titleInput != null
          ? Winget.show.titleWithInput(titleInput!, localization: localization)
          : Winget.show.title(localization),
      child: body(context),
    );
  }

  Widget body(BuildContext context) {
    Widget putInfo(String text) => Center(
            child: InfoBar(
          title: Text(text),
          severity: InfoBarSeverity.error,
        ));

    if (package.packageSource == null) {
      return putInfo('package is not from known source');
    }
    return _buildFromWeb(context);
  }

  Widget putInfo(String title, {String? content, bool isLong = false}) =>
      Center(
        child: InfoBar(
            title: Text(title),
            content: content != null ? LinkText(line: content) : null,
            severity: InfoBarSeverity.error,
            isLong: isLong),
      );

  Widget _buildFromWeb(BuildContext context) {
    Locale? locale = AppLocales.of(context).guiLocale;
    AppLocalizations localization = AppLocalizations.of(context)!;
    return FutureBuilder<PackageInfosFull>(
      future: getInfos(locale),
      builder:
          (BuildContext context, AsyncSnapshot<PackageInfosFull> snapshot) {
        if (snapshot.hasData) {
          return ScrollListWidget(
            listElements: [PackageLongInfo(snapshot.data!)],
          );
        }
        if (snapshot.hasError) {
          log.error(snapshot.error.runtimeType.toString(),
              message: '${snapshot.error}\n${snapshot.stackTrace}');
          Widget errorMessage = errorWidget(snapshot, localization);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: errorMessage,
            ),
          );
        }
        return const Center(
            child: ProgressRing(
          backgroundColor: Colors.transparent,
        ));
      },
    );
  }

  Widget errorWidget(AsyncSnapshot snapshot, AppLocalizations localization) {
    Object? error = snapshot.error;
    if (error.runtimeType == NoInternetException) {
      return putInfo(localization.cantLoadDetails,
          content:
              '${localization.reason}: ${localization.noInternetConnection}',
          isLong: true);
    }
    if (error.runtimeType == GithubRateLimitException) {
      GithubRateLimitException e = error as GithubRateLimitException;
      List<String> messageWithoutDocumentation =
          e.message.split('documentation');
      return Center(
        child: InfoBar(
            title: const Text('Too much requests to Github API'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(TextSpan(children: [
                  for (int i = 0;
                      i < messageWithoutDocumentation.length;
                      i++) ...[
                    if (i > 0)
                      TextSpan(
                        text: 'documentation',
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(e.documentationUrl);
                          },
                      ),
                    TextSpan(text: messageWithoutDocumentation[i]),
                  ],
                ])),
                for (MapEntry<String, String> entry
                    in e.responseBodyRest.entries)
                  Text('${entry.key}: ${entry.value}'),
              ],
            ),
            severity: InfoBarSeverity.error,
            isLong: true),
      );
    }

    return putInfo(error.runtimeType.toString(),
        content: '$error\n${snapshot.stackTrace}', isLong: true);
  }

  Future<PackageInfosFull> getInfos(Locale? guiLocale) async {
    PackageSource source = package.packageSource!;
    return source.fetchInfos(guiLocale);
  }
}
