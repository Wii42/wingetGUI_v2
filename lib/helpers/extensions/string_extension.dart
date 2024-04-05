import 'package:string_validator/string_validator.dart' as validator;

import 'int_extension.dart';

extension StringHelper on String {
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

  String firstChar() {
    return this[0];
  }

  String lastChar() {
    return this[length - 1];
  }

  /// Returns a new string containing the substring of this string up to to [count], exclusive.
  String take(int count) {
    if (count > length) {
      return this;
    }
    return substring(0, count);
  }

  bool isDigits() {
    return RegExp(r'^[0-9]+$').hasMatch(this);
  }

  static bool isCjkIdeograph(int codePoint) {
    return codePoint.isBetween(0x4E00, 0x9FFF) ||
        codePoint.isBetween(0x20000, 0x2A6DF) ||
        codePoint.isBetween(0xAC00, 0xD7AF);
    //return (codePoint.isBetween(0x4E00, 0x62FF) ||
    //    codePoint.isBetween(0x6300, 0x77FF) ||
    //    codePoint.isBetween(0x7800, 0x8CFF) ||
    //    codePoint.isBetween(0x8D00, 0x9FFF));
  }

  static bool isLink(String? text) {
    if (text == null) {
      return false;
    }
    return (validator.isURL(text) ||
        (text.startsWith('ms-windows-store://') &&
            !text.trim().contains(' ')) ||
        (text.startsWith('mailto:') && !text.contains(' ')) &&
            text.contains('@'));
  }

  String? get(int index) {
    if (index < 0 || index >= length) {
      return null;
    }
    return this[index];
  }
}
