import 'package:expandable_text/expandable_text.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/content_place.dart';
import 'package:winget_gui/extensions/string_map_extension.dart';
import 'package:winget_gui/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/show/agreement_widget.dart';
import 'package:winget_gui/output_handling/show/details_widget.dart';
import 'package:winget_gui/output_handling/show/package_name_widget.dart';

import '../info_enum.dart';
import 'expandable_widget.dart';
import 'link_button.dart';

class PackageLongInfo extends StatelessWidget {
  static final List<Info> manuallyHandledKeys = [
    Info.description,
    Info.name,
    Info.publisher,
    Info.publisherUrl,
    Info.version,
    Info.tags,
    Info.releaseNotes,
    Info.installer,
    Info.website,
    Info.releaseNotesUrl,
    Info.moniker,
  ];
  final Map<String, String> infos;
  const PackageLongInfo(this.infos, {super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _wrapInDecoratedBox(PackageNameWidget(infos), context),
        if (infos.hasEntry(Info.tags.key)) _tags(context),
        if (infos.hasEntry(Info.description.key))
          _wrapInDecoratedBox(
              _expandableCompartment(Info.description), context),
        if (infos.hasEntry(Info.releaseNotes.key))
          _wrapInDecoratedBox(_releaseNotes(), context),
        _wrapInDecoratedBox(DetailsWidget(infos: infos), context),
        if (AgreementWidget.containsData(infos))
          _wrapInDecoratedBox(AgreementWidget(infos: infos), context),
        if (infos.hasEntry(Info.installer.key))
          _wrapInDecoratedBox(_expandableCompartment(Info.installer), context),
      ].withSpaceBetween(height: 10),
    );
  }

  Widget _wrapInDecoratedBox(Widget widget, BuildContext context) {
    return DecoratedBox(
        decoration: BoxDecoration(
          color: FluentTheme.of(context).cardColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: widget);
  }

  Widget _expandableCompartment(Info info) {
    return ExpandableWidget(title: info.title, text: infos[info.key]!);
  }

  Widget _releaseNotes() {
    LinkButton? linkButton;
    if (infos.hasEntry(Info.releaseNotesUrl.key)) {
      linkButton = LinkButton(
          url: infos[Info.releaseNotesUrl.key]!,
          text: const Text('show online'));
    }
    return ExpandableWidget(
        title: Info.releaseNotes.title,
        text: infos[Info.releaseNotes.key]!,
        linkButton: linkButton);
  }

  Widget _displayRest() {
    List<String> rest = [];
    for (String key in infos.keys) {
      if (!isManuallyHandled(key)) {
        rest.add("$key: ${infos[key]}");
      }
    }
    return ExpandableWidget(title: 'Rest', text: rest.join('\n'));
  }

  Widget _tags(BuildContext context) {
    List<String> split = infos[Info.tags.key]!.split('\n');
    List<String> tags = [];
    for (String s in split) {
      if (s.isNotEmpty) {
        tags.add(s.trim());
      }
    }
    return Wrap(
      runSpacing: 5,
      spacing: 5,
      alignment: WrapAlignment.center,
      children: [
        if (infos.hasEntry(Info.moniker.key))
          Button(
              onPressed: () {
                ContentPlace.maybeOf(context)
                    ?.content
                    .showResultOfCommand(['search', infos[Info.moniker.key]!]);
              },
              child: Text(infos[Info.moniker.key]!)),
        for (String tag in tags)
          Button(
              onPressed: () {
                ContentPlace.maybeOf(context)
                    ?.content
                    .showResultOfCommand(['search', tag]);
              },
              child: Text(tag))
      ],
    );
  }

  static Iterable<String> manuallyHandledStringKeys() =>
      manuallyHandledKeys.map<String>((Info info) => info.key);

  static bool isManuallyHandled(String key) {
    return (manuallyHandledStringKeys().contains(key) ||
        AgreementWidget.manuallyHandledStringKeys().contains(key) ||
        DetailsWidget.manuallyHandledStringKeys().contains(key));
  }

  bool existUnhandledKeys(){
    for (String key in infos.keys){
      if(!isManuallyHandled(key)){
        return true;
      }
    }
    return false;
  }
}
