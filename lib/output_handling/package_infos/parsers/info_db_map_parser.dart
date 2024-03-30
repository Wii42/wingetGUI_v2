import 'package:winget_gui/output_handling/package_infos/info.dart';

import 'package:winget_gui/output_handling/package_infos/info_with_link.dart';

import 'package:winget_gui/output_handling/package_infos/installer_objects/dependencies.dart';

import 'package:winget_gui/output_handling/package_infos/installer_objects/installer.dart';

import 'package:winget_gui/output_handling/package_infos/package_attribute.dart';

import 'info_abstract_map_parser.dart';

class InfoDBMapParser extends InfoAbstractMapParser<String, dynamic> {
  InfoDBMapParser({required super.map});

  @override
  Info<Dependencies>? maybeDependenciesFromMap(PackageAttribute dependencies) {
    throw UnimplementedError();
  }

  @override
  Info<List<InfoWithLink>>? maybeDocumentationsFromMap(PackageAttribute attribute) {
    throw UnimplementedError();
  }

  @override
  InfoWithLink? maybeInfoWithLinkFromMap({required PackageAttribute textInfo, required PackageAttribute urlInfo}) {
    throw UnimplementedError();
  }

  @override
  Info<List<Installer>>? maybeInstallersFromMap(PackageAttribute installers) {
    throw UnimplementedError();
  }

  @override
  Info<List<T>>? maybeListFromMap<T>(PackageAttribute attribute, {required T Function(dynamic p1) parser}) {
    throw UnimplementedError();
  }

  @override
  Info<String>? maybeStringFromMap(PackageAttribute attribute) {
    return Info.fromAttribute(attribute, value: map[attribute.name]);
  }

  @override
  List<String>? maybeTagsFromMap() {
    throw UnimplementedError();
  }


}