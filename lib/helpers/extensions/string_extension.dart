import 'package:string_validator/string_validator.dart' as validator;
import 'package:winget_gui/helpers/extensions/int_extension.dart';

extension ContainsExtentsion on String {
  bool isLoadingSymbols() {
    if (isEmpty) {
      return false;
    }

    String bs = String.fromCharCode(32);
    String bs2 = String.fromCharCode(8);

    return (contains(RegExp('^[$bs$bs2-\\/|]+\$')) ||
            (contains('\\') && !contains(RegExp(r'[a-zA-Z0-9]')))) &&
        !contains(RegExp(r'-{2,}'));
  }

  bool containsNonWesternGlyphs() {
    if (isEmpty) {
      return false;
    }
    List<int> codePoints = codeUnits;
    for (int codePoint in codePoints) {
      if (codePoint >= 1329 &&
          String.fromCharCode(codePoint) != '…' &&
          String.fromCharCode(codePoint) != r'\') {
        return true;
      }
    }
    return false;
  }

  bool isProgressBar() {
    if (!(contains('█') || contains('░') || contains('▒'))) {
      return false;
    }
    String trimmed = trim();
    int end = trimmed.indexOf(' ');
    String progressBarPart = (end >= 0) ? trimmed.substring(0, end) : trimmed;
    return progressBarPart.containsOnlyProgressBarSymbols();
  }

  bool containsOnlyProgressBarSymbols() {
    RegExp onlyProgressBarSymbols = RegExp(r'^[█░▒]*$');
    return contains(onlyProgressBarSymbols);
  }

  bool containsCaseInsensitive(String other, [int startIndex = 0]) {
    return toLowerCase().contains(other.toLowerCase(), startIndex);
  }

  bool containsCjkIdeograph() {
    List<int> codePoints = codeUnits;
    return codePoints.any((codePoint) => isCjkIdeograph(codePoint));
  }

  int countCjkIdeographs() {
    List<int> codePoints = codeUnits;
    return codePoints.where((codePoint) => isCjkIdeograph(codePoint)).length;
  }

  String charAt(int index) {
    return String.fromCharCode(codeUnitAt(index));
  }

  String firstChar() {
    return String.fromCharCode(codeUnits.first);
  }

  String lastChar() {
    return String.fromCharCode(codeUnits.last);
  }
}

bool isCjkIdeograph(int codePoint) {
  return (codePoint.isBetween(0x4E00, 0x62FF) ||
      codePoint.isBetween(0x6300, 0x77FF) ||
      codePoint.isBetween(0x7800, 0x8CFF) ||
      codePoint.isBetween(0x8D00, 0x9FFF));
}

bool isLink(String? text) {
  if (text == null) {
    return false;
  }
  return (validator.isURL(text) ||
      (text.startsWith('ms-windows-store://') && !text.trim().contains(' ')) ||
      (text.startsWith('mailto:') && !text.contains(' ')) &&
          text.contains('@'));
}
