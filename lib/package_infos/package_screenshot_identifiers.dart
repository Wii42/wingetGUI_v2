import 'package_infos.dart';

extension PackageScreenshotIdentifiers on PackageInfos {
  String? get nameWithoutVersion {
    if (name == null) {
      return null;
    }
    String nameWithoutVersion = name!.value;
    if (hasVersion()) {
      nameWithoutVersion =
          name!.value.replaceFirst(' ${version!.value.stringValue}', '');
    }
    String string = nameWithoutVersion.replaceAll(' ', '').toLowerCase();
    return string;
  }

  String? get nameWithoutPublisherIDAndVersion {
    if (name == null) {
      return null;
    }
    String nameWithoutVersion = name!.value;
    if (hasVersion()) {
      nameWithoutVersion = name!.value.replaceFirst(' ${version!.value}', '');
    }
    if (publisher?.id != null) {
      nameWithoutVersion =
          nameWithoutVersion.replaceFirst('${publisher?.id}', '');
    }
    String string = nameWithoutVersion.replaceAll(' ', '').toLowerCase();
    return string;
  }

  String? get idWithHyphen =>
      id?.value.copyWith(separator: '-').string.toLowerCase();

  String? get idWithoutPublisherID => id?.value.idParts.join('').toLowerCase();

  String? get idWithoutPublisherIDAndHyphen =>
      id?.value.idParts.join('').toLowerCase();

  String? get iconIdAsPerWingetUI {
    if (id == null) {
      return null;
    }
    String iconId = idWithoutPublisherIDAndHyphen!;
    return iconId
        .replaceAll(" ", "-")
        .replaceAll("_", "-")
        .replaceAll(".", "-");
  }

  String? get secondIdPartOnly => id?.value.idParts.firstOrNull?.toLowerCase();

  String? get idFirstTwoParts =>
      id?.value.idParts.take(2).join(id?.value.separator ?? '.').toLowerCase();

  List<String> get idWithWildcards {
    if (id == null) {
      return [];
    }
    List<String> idList = id!.value.allParts;
    List<String> idWithWildcards = [];
    String separator = id!.value.separator ?? '.';
    for (int i = 1; i < idList.length; i++) {
      idWithWildcards.add('${idList.sublist(0, i).join(separator)}$separator*');
    }
    return idWithWildcards.reversed.toList();
  }

  Set<String> get possibleScreenshotKeys => [
        id?.value.string,
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
