import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:winget_gui/global_app_data.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/helpers/log_stream.dart';
import 'package:winget_gui/package_infos/package_infos_full.dart';

import 'agreement_widget.dart';
import 'details_widget.dart';
import 'expandable_text_compartment.dart';
import 'screenshots_widget.dart';
import 'stateful_installer_widget.dart';
import 'tags_widget.dart';
import 'title_widget.dart';

class PackageLongInfo extends StatelessWidget {
  late final Logger log;
  final PackageInfosFull infos;

  PackageLongInfo(this.infos, {super.key}) {
    log = Logger(this);
  }

  @override
  Widget build(BuildContext context) {
    Locale? guiLocale = AppLocales.of(context).guiLocale;
    return Column(
      children: [
        TitleWidget(infos: infos),
        if (infos.screenshots?.screenshots != null &&
            infos.screenshots!.screenshots!.isNotEmpty)
          ScreenshotsWidget(infos.screenshots!),
        if (infos.hasDescription())
          ExpandableTextCompartment(
            text: infos.additionalDescription ??
                infos.description ??
                infos.shortDescription!,
            title: (infos.description != null &&
                    infos.additionalDescription != null)
                ? infos.shortDescription
                : null,
            titleIcon: FluentIcons.edit,
          ),
        if (infos.hasReleaseNotes()) releaseNotesCompartment(),
        DetailsWidget(infos: infos),
        if (infos.agreement != null) AgreementWidget(infos: infos.agreement!),
        if (infos.hasTags())
          TagsWidget(
            tags: infos.tags!,
            moniker: infos.moniker,
          ),
        if (infos.installer != null)
          StatefulInstallerWidget(
            infos: infos.installer!,
            guiLocale: guiLocale,
            defaultLocale: infos.packageLocale?.value,
          ),
      ].withSpaceBetween(height: 10),
    );
  }

  ExpandableTextCompartment releaseNotesCompartment() {
    Uri? releaseNotesUrl = infos.releaseNotes?.url;
    Uri? websiteUrl = infos.website?.value;
    void Function(String)? launchMention;
    if (releaseNotesUrl != null && releaseNotesUrl.host == 'github.com') {
      launchMention = (String mention) {
        log.info('Mention tapped: $mention');
        launchUrl(Uri.parse("https://github.com/$mention"));
      };
    }

    void Function(String)? launchHashtag;
    if (websiteUrl != null && websiteUrl.host == 'github.com') {
      launchHashtag = (String tag) {
        log.info('Hashtag tapped: $tag');
        launchUrl(Uri.parse("$websiteUrl/pull/$tag"));
      };
    }
    if (releaseNotesUrl != null && releaseNotesUrl.host == 'github.com') {
      launchHashtag = (String tag) {
        log.info('Mention tapped: $tag');
        launchUrl(Uri.parse(
            "https://github.com/${releaseNotesUrl.pathSegments.take(2).join('/')}/pull/$tag"));
      };
    }

    return ExpandableTextCompartment(
      text: infos.releaseNotes!.toStringInfo(),
      buttonInfos: [infos.releaseNotes?.toUriInfoIfHasUrl()],
      titleIcon: FluentIcons.product_release,
      onMentionTap: launchMention,
      onHashtagTap: launchHashtag,
    );
  }
}
