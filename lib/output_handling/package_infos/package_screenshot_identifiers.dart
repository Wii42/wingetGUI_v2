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

  String? get iconIdAsPerWingetUI {
    if (id == null) {
      return null;
    }
    String iconId = id!.value.toLowerCase();
    List<String> idList = iconId.split('.');
    idList.removeAt(0);
    iconId = idList.join('.');
    return iconId
        .replaceAll(" ", "-")
        .replaceAll("_", "-")
        .replaceAll(".", "-");
  }

  String? get secondIdPartOnly {
    if (id == null) {
      return null;
    }
    String iconId = id!.value.toLowerCase();
    List<String> idList = iconId.split('.');
    if (idList.length < 2) {
      return null;
    }
    return idList[1];
  }

  String? get idFirstTwoParts {
    if (id == null) {
      return null;
    }
    String iconId = id!.value;
    List<String> idList = iconId.split('.');
    if (idList.length <= 2) {
      return null;
    }
    return idList.take(2).join('.');
  }

  List<String> get idWithWildcards {
    if (id == null) {
      return [];
    }
    List<String> idList = id!.value.split('.');
    List<String> idWithWildcards = [];
    for (int i = 1; i < idList.length; i++) {
      idWithWildcards.add('${idList.sublist(0, i).join('.')}.*');
    }
    return idWithWildcards.reversed.toList();
  }

  Set<String> get possibleScreenshotKeys => [
        id?.value,
        iconIdAsPerWingetUI,
        nameWithoutVersion,
        nameWithoutPublisherIDAndVersion,
        idWithHyphen,
        idWithoutPublisherID,
        idWithoutPublisherIDAndHyphen,
        if (idWithoutPublisherIDAndHyphen != null &&
            idWithoutPublisherIDAndHyphen!.endsWith('-eap')) ...[
          '${idWithoutPublisherIDAndHyphen!.substring(0, idWithoutPublisherIDAndHyphen!.length - 4)}-earlyaccess',
          '${idWithoutPublisherIDAndHyphen!.substring(0, idWithoutPublisherIDAndHyphen!.length - 4)}-earlypreview',
        ],
        secondIdPartOnly,
        idFirstTwoParts,
      ].nonNulls.toSet();
}
