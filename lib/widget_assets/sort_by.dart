import '../output_handling/package_infos/info.dart';
import '../output_handling/package_infos/package_infos_peek.dart';
import '../winget_commands.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum SortBy {
  name(sort: sortName),
  id(sort: sortId),
  version(sort: sortVersion),
  source(sort: sortSource),
  match(sort: sortMatch),
  publisher(sort: sortPublisher),
  auto(sort: sortAuto),
  random(sort: randomize);

  final List<PackageInfosPeek> Function(List<PackageInfosPeek>) sort;

  const SortBy({required this.sort});

  String title(AppLocalizations locale) {
    String title = locale.infoTitle(this.name);
    if (title == notFoundError) {
      throw Exception("$title: ${this.name} in SortBy.title");
    }
    return title;
  }

  static int sortNull(String? a, String? b) {
    if (a == null || b == null) {
      if (a == null && b == null) {
        return 0;
      }
      if (a == null) {
        return 1;
      } else {
        return -1;
      }
    }
    return a.compareTo(b);
  }

  static int sortInfo(Info<String>? a, Info<String>? b) {
    return sortNull(a?.value, b?.value);
  }

  static List<PackageInfosPeek> sortName(List<PackageInfosPeek> packages) {
    return packages..sort((a, b) => sortInfo(a.name, b.name));
  }

  static List<PackageInfosPeek> sortId(List<PackageInfosPeek> packages) {
    return packages..sort((a, b) => sortInfo(a.id, b.id));
  }

  static List<PackageInfosPeek> sortVersion(List<PackageInfosPeek> packages) {
    return packages..sort((a, b) => sortInfo(a.version, b.version));
  }

  static List<PackageInfosPeek> sortSource(List<PackageInfosPeek> packages) {
    return packages
      ..sort((a, b) => sortNull(a.source.value.title, b.source.value.title));
  }

  static List<PackageInfosPeek> sortMatch(List<PackageInfosPeek> packages) {
    return packages..sort((a, b) => sortInfo(a.match, b.match));
  }

  static List<PackageInfosPeek> sortPublisher(List<PackageInfosPeek> packages) {
    return packages
      ..sort((a, b) => sortNull(
          a.publisherName ?? a.publisherID, b.publisherName ?? b.publisherID));
  }

  static List<PackageInfosPeek> sortAuto(List<PackageInfosPeek> packages) {
    return packages;
  }

  static List<PackageInfosPeek> randomize(List<PackageInfosPeek> packages) {
    return packages..shuffle();
  }
}
