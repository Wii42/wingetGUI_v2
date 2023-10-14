import 'info.dart';

abstract class PackageInfos {
  final Info<String>? name, id, version;

  final Map<String, String>? otherInfos;

  PackageInfos({
    this.name,
    this.id,
    this.version,
    this.otherInfos,
  });

  bool hasVersion() => (version != null && version?.value != 'Unknown');
  bool hasSpecificVersion() => (version != null &&
      version?.value != 'Unknown' &&
      !version!.value.contains('<'));

  String? get nameWithoutVersion {
    if (name == null) {
      return null;
    }
    String nameWithoutVersion = name!.value;
    if (hasVersion()) {
      nameWithoutVersion =  name!.value.replaceFirst(' ${version!.value}', '');
    }
    String string = nameWithoutVersion.replaceAll(' ', '').toLowerCase();
    return string;
  }

  String? get publisherID {
    if (id == null) {
      return null;
    }
    return id!.value.split('.').firstOrNull;
  }

  String? get nameWithoutPublisherIDAndVersion{
    if (name == null) {
      return null;
    }
    String nameWithoutVersion = name!.value;
    if (hasVersion()) {
      nameWithoutVersion =  name!.value.replaceFirst(' ${version!.value}', '');
    }
    if (publisherID != null) {
      nameWithoutVersion = nameWithoutVersion.replaceFirst('$publisherID', '');
    }
    String string = nameWithoutVersion.replaceAll(' ', '').toLowerCase();
    return string;
  }

  String? get idWithHyphen {
    if (id == null) {
      return null;
    }
    return id!.value.replaceAll('.', '-').toLowerCase();
  }

  String? get idWithoutPublisherID {
    if (id == null) {
      return null;
    }
    return id!.value.replaceFirst('$publisherID.', '').replaceAll('.', '').toLowerCase();
  }
}
