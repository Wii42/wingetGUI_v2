import 'package:expandable_text/expandable_text.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/content_place.dart';
import 'package:winget_gui/extensions/string_map_extension.dart';
import 'package:winget_gui/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/show/package_name_widget.dart';

class PackageLongInfo extends StatelessWidget {
  static final List<String> manuallyHandledKeys = [
    'Beschreibung',
    'Name',
    'Herausgeber',
    'Herausgeber-URL',
    'Version',
    'Markierungen',
    'Versionshinweise',
  ];
  final Map<String, String> infos;
  const PackageLongInfo(this.infos, {super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _wrapInDecoratedBox(PackageNameWidget(infos), context),
        if (infos.hasEntry('Beschreibung'))
          _wrapInDecoratedBox(_description(context), context),
        if (infos.hasEntry('Versionshinweise'))
          _wrapInDecoratedBox(_releaseNotes(context), context),
        if (infos.hasEntry('Markierungen')) _tags(context),
        _displayRest(),
      ].withSpaceBetween(height: 10),
    );
  }

  Widget _wrapInDecoratedBox(Widget widget, BuildContext context) {
    return DecoratedBox(
        decoration: BoxDecoration(
            color: FluentTheme.of(context).cardColor,
            borderRadius: BorderRadius.circular(5)),
        child: widget);
  }

  Widget _description(BuildContext context) {
    return _expandableWidget(
        context: context, title: 'About', text: infos['Beschreibung']!);
  }

  Widget _releaseNotes(BuildContext context) {
    return _expandableWidget(
        context: context,
        title: 'Release notes',
        text: infos['Versionshinweise']!);
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

  Widget _displayRest() {
    List<String> rest = [];
    for (String key in infos.keys) {
      if (!manuallyHandledKeys.contains(key)) {
        rest.add("$key: ${infos[key]}");
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [for (String info in rest) Text(info)],
    );
  }

  Widget _tags(BuildContext context) {
    List<String> split = infos['Markierungen']!.split('\n');
    List<String> tags = [];
    for (String s in split) {
      if (s.isNotEmpty) {
        tags.add(s.trim());
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (String tag in tags)
          Button(
              onPressed: () {
                ContentPlace.maybeOf(context)
                    ?.content
                    .showResultOfCommand(['search', tag]);
              },
              child: Text(tag))
      ].withSpaceBetween(width: 5),
    );
  }
}
