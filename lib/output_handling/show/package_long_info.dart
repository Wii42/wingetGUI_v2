import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/show/compartments/details_widget.dart';
import 'package:winget_gui/output_handling/show/compartments/expandable_text_compartment.dart';
import 'package:winget_gui/output_handling/show/compartments/screenshots_widget.dart';
import 'package:winget_gui/output_handling/show/compartments/tags_widget.dart';
import 'package:winget_gui/output_handling/show/compartments/title_widget.dart';
import 'package:winget_gui/output_handling/show/stateful_installer_widget.dart';
import 'package:winget_gui/widget_assets/app_locale.dart';

import '../../helpers/log_stream.dart';
import '../package_infos/package_infos_full.dart';
import 'compartments/agreement_widget.dart';

class PackageLongInfo extends StatelessWidget {
  late final Logger log;
  final PackageInfosFull infos;

  PackageLongInfo(this.infos, {super.key}) {
    log = Logger(this);
  }

  @override
  Widget build(BuildContext context) {
    Locale? guiLocale = AppLocale.of(context).guiLocale;
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
