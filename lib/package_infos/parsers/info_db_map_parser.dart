import '../info.dart';
import '../info_with_link.dart';
import '../installer_objects/dependencies.dart';
import '../installer_objects/installer.dart';
import '../package_attribute.dart';
import 'info_abstract_map_parser.dart';

class InfoDBMapParser extends InfoAbstractMapParser<String, dynamic> {
  InfoDBMapParser({required super.map});

  @override
  Info<Dependencies>? maybeDependenciesFromMap(PackageAttribute dependencies) {
    throw UnimplementedError();
  }

  @override
  Info<List<InfoWithLink>>? maybeDocumentationsFromMap(
      PackageAttribute attribute) {
    throw UnimplementedError();
  }

  @override
  InfoWithLink? maybeInfoWithLinkFromMap(
      {required PackageAttribute textInfo, required PackageAttribute urlInfo}) {
    throw UnimplementedError();
  }

  @override
  Info<List<Installer>>? maybeInstallersFromMap(PackageAttribute installers) {
    throw UnimplementedError();
  }

  @override
  Info<List<T>>? maybeListFromMap<T>(PackageAttribute attribute,
      {required T Function(dynamic p1) parser}) {
    throw UnimplementedError();
  }

  @override
  Info<String>? maybeStringFromMap(PackageAttribute attribute) {
    String? value = map[attribute.name];
    if (value == 'null') {
      value = null;
    }
    if (value == null) {
      return null;
    }
    return Info.fromAttribute(attribute, value: value);
  }

  @override
  List<String>? maybeTagsFromMap() {
    throw UnimplementedError();
  }
}
