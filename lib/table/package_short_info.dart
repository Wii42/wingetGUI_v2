import 'package:fluent_ui/fluent_ui.dart';

class PackageShortInfo extends StatelessWidget {
  final Map<String, String> infos;
  const PackageShortInfo(this.infos, {super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: FluentTheme.of(context).cardColor),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  infos['Name']!,
                  style: const TextStyle(fontSize: 20),
                ),
                Text(infos['ID']!),
                if (_hasEntry('Quelle'))
                  Text(
                    "from ${infos['Quelle']!}",
                    style:
                    TextStyle(color: FluentTheme.of(context).disabledColor),
                  )
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_hasEntry('Version')) Text("Version: ${infos['Version']!}"),
                if (_hasEntry('Verfügbar'))
                  Text("Verfügbar: ${infos['Verfügbar']!}")
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _hasEntry(String key) {
    return (infos.containsKey(key) && infos[key]!.isNotEmpty);
  }
}