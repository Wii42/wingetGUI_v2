import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/package_infos/parsers/info_abstract_map_parser.dart';
import 'package:winget_gui/output_handling/package_infos/info_extensions.dart';

import '../info.dart';
import '../info_with_link.dart';
import '../installer_objects/computer_architecture.dart';
import '../installer_objects/dependencies.dart';
import '../installer_objects/installer.dart';
import '../package_attribute.dart';

class InfoMapParser extends InfoAbstractMapParser<String, String> {
  AppLocalizations locale;
  InfoMapParser({required super.map, required this.locale});

  @override
  Info<String>? maybeStringFromMap(PackageAttribute attribute) {
    String key = attribute.key(locale);
    String? detail = map[key];
    map.remove(key);
    return (detail != null)
        ? Info<String>.fromAttribute(attribute, value: detail)
        : null;
  }

  Info<List<InfoWithLink>>? maybeListWithLinksFromMap(
      PackageAttribute attribute) {
    return maybeListFromMap(attribute,
        parser: (e) => InfoWithLink(title: attribute.title, text: e));
  }

  @override
  InfoWithLink? maybeInfoWithLinkFromMap(
      {required PackageAttribute textInfo, required PackageAttribute urlInfo}) {
    return InfoWithLink.maybeFromMap(
      map: map,
      textInfo: textInfo,
      urlInfo: urlInfo,
      locale: locale,
    );
  }

  @override
  List<String>? maybeTagsFromMap() {
    String key = PackageAttribute.tags.key(locale);
    String? tagString = map[key];
    if (tagString != null) {
      List<String> tags = _extractTags(tagString);
      map.remove(key);
      return tags;
    }
    return null;
  }

  List<String> _extractTags(String tagString) {
    List<String> split = tagString.split('\n');
    return [
      for (String s in split)
        if (s.isNotEmpty) s.trim()
    ];
  }

  @override
  Info<List<T>>? maybeListFromMap<T>(PackageAttribute attribute,
      {required T Function(dynamic p1) parser}) {
    Info<String>? list = maybeStringFromMap(attribute);
    if (list == null) {
      return null;
    }
    return list.copyAs<List<T>>(
        parser: (e) => e.split('\n').map(parser).toList());
  }

  @override
  Info<List<InfoWithLink>>? maybeDocumentationsFromMap(
      PackageAttribute attribute) {
    return maybeListFromMap(attribute,
        parser: (p0) => InfoWithLink(
            title: (locale) => p0.toString(), text: p0.toString()));
  }

  @override
  Info<List<Installer>>? maybeInstallersFromMap(PackageAttribute installers) {
    return maybeListFromMap<Installer>(PackageAttribute.installers,
        parser: (map) {
      return Installer(
          architecture: Info<ComputerArchitecture>.fromAttribute(
              PackageAttribute.architecture,
              value: ComputerArchitecture.matchAll),
          url: null,
          sha256Hash: null);
    });
  }

  @override
  Info<Dependencies>? maybeDependenciesFromMap(PackageAttribute dependencies) {
    return maybeValueFromMap<Dependencies>(dependencies, (e) => Dependencies());
  }
}
