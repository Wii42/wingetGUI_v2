import 'package:winget_gui/output_handling/package_infos/package_infos.dart';

extension PackageScreenshotIdentifiers on PackageInfos {
  String? get nameWithoutVersion {
    if (name == null) {
      return null;
    }
    String nameWithoutVersion = name!.value;
    if (hasVersion()) {
      nameWithoutVersion = name!.value.replaceFirst(' ${version!.value}', '');
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

  String? get nameWithoutPublisherIDAndVersion {
    if (name == null) {
      return null;
    }
    String nameWithoutVersion = name!.value;
    if (hasVersion()) {
      nameWithoutVersion = name!.value.replaceFirst(' ${version!.value}', '');
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
    return id!.value
        .replaceFirst('$publisherID.', '')
        .replaceAll('.', '')
        .toLowerCase();
  }

  String? get idWithoutPublisherIDAndHyphen {
    if (id == null) {
      return null;
    }
    return id!.value
        .replaceFirst('$publisherID.', '')
        .replaceAll('.', '-')
        .toLowerCase();
  }
}
