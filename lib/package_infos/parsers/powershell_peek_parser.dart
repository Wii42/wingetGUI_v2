import 'package:winget_core/winget_core.dart';
import 'package:winget_core/winget_parsers.dart';

class PowershellPeekParser extends PeekAbstractMapParser<String, dynamic>{
  PowershellPeekParser(super.details);

  @override
  Map<String, dynamic> flattenedDetailsMap() => details;

  @override
  InfoAbstractMapParser<String, dynamic> getParser(Map<String, dynamic> map) {
    return InfoPowershellParser(map: map);
  }

}

class InfoPowershellParser extends InfoAbstractMapParser<String, dynamic>{
  InfoPowershellParser({required super.map});

  String keyForAttribute(PackageAttribute attribute) {
    switch(attribute) {
      case PackageAttribute.name:
        return "Name";
      case PackageAttribute.id:
        return "Id";
      case PackageAttribute.version:
        return "InstalledVersion";
      case PackageAttribute.source:
        return "Source";
      case PackageAttribute.availableVersion:
        return "AvailableVersions";
      case PackageAttribute.match: return "Match"; // Not used in Powershell
      default:
        throw ArgumentError("Attribute $attribute not supported in Powershell parser");
    }
  }

  @override
  Info<Dependencies>? maybeDependenciesFromMap(PackageAttribute dependencies) {
    throw UnimplementedError();
  }

  @override
  Info<List<InfoWithLink>>? maybeDocumentationsFromMap(PackageAttribute attribute) {
    throw UnimplementedError();
  }

  @override
  Info<List<Installer>>? maybeInstallersFromMap(PackageAttribute installers) {
    throw UnimplementedError();
  }

  @override
  Info<List<T>>? maybeListFromMap<T>(PackageAttribute attribute, {required T Function(dynamic p1) parser}) {
    dynamic node = map[keyForAttribute(attribute)];
    if (node == null || node is! List) {
      return null;
    }
    map.remove(keyForAttribute(attribute));
    return Info<List<T>>.fromAttribute(
      attribute,
      value: node.map<T>(parser).toList(),
    );
  }

  @override
  List<String>? maybeTagsFromMap() {
    throw UnimplementedError();
  }

  @override
  InfoWithLink? maybeInfoWithLinkFromMap({required PackageAttribute textInfo, required PackageAttribute urlInfo}) {
    throw UnimplementedError();
  }

  @override
  Info<String>? maybeStringFromMap(PackageAttribute attribute) {
    dynamic node = map[keyForAttribute(attribute)];
    String? detail = (node != null) ? node.toString() : null;
    map.remove(keyForAttribute(attribute));
    return (detail != null)
        ? Info<String>.fromAttribute(attribute, value: detail)
        : null;
  }

  @override
  Info<List<VersionOrString>>? maybeVersionOrStringListFromMap(PackageAttribute attribute) {
    return maybeListFromMap<VersionOrString>(
      attribute,
      parser: (dynamic p1) => VersionOrString.parse(p1.toString()));
  }
}