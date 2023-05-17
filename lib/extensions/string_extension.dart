extension ContainsExtentsion on String {

  bool isLoadingSymbols() {
    if (isEmpty) {
      return false;
    }

    String bs = String.fromCharCode(8);
    List<String> spinning = ['$bs-', '$bs\\', '$bs/', '$bs|', bs];

    return (spinning.contains(trim()));
  }

  bool containsNonWesternGlyphs() {
    if (isEmpty) {
      return false;
    }
    List<int> codePoints = codeUnits;
    for (int codePoint in codePoints) {
      if (codePoint >= 1329 && String.fromCharCode(codePoint) != '…') {
        return true;
      }
    }
    return false;
  }
}
