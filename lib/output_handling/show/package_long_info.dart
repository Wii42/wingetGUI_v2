import 'package:expandable_text/expandable_text.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/content_place.dart';
import 'package:winget_gui/extensions/string_map_extension.dart';
import 'package:winget_gui/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/show/package_name_widget.dart';

import '../info_enum.dart';

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
          _wrapInDecoratedBox(_description(context), context),
        if (infos.hasEntry(Info.releaseNotes.key))
          _wrapInDecoratedBox(_releaseNotes(context), context),
        _wrapInDecoratedBox(_displayRest(context), context),
        if (infos.hasEntry(Info.installer.key))
          _wrapInDecoratedBox(_installer(context), context),
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

  Widget _description(BuildContext context) {
    return _expandableWidget(
        context: context, title: 'About', text: infos[Info.description.key]!);
  }

  Widget _releaseNotes(BuildContext context) {
    return _expandableWidget(
        context: context,
        title: 'Release notes',
        text: infos[Info.releaseNotes.key]!);
  }

  Widget _expandableWidget(
      {required BuildContext context,
      required String title,
      required String text,
      int maxLines = 5}) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: FluentTheme.of(context).typography.title),
          ExpandableText(
            text,
            expandText: 'show more',
            collapseText: 'show less',
            maxLines: maxLines,
            linkColor: FluentTheme.of(context).accentColor,
          ),
        ],
      ),
    );
  }

  Widget _displayRest(BuildContext context) {
    List<String> rest = [];
    for (String key in infos.keys) {
      if (!manuallyHandledStringKeys().contains(key)) {
        rest.add("$key: ${infos[key]}");
      }
    }
    return _expandableWidget(
        context: context, title: 'Details', text: rest.join('\n'));
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

  Widget _installer(BuildContext context) {
    return _expandableWidget(
        context: context, title: 'Installer', text: infos[Info.installer.key]!);
  }

  static Iterable<String> manuallyHandledStringKeys() =>
      manuallyHandledKeys.map<String>((Info info) => info.key);
}
