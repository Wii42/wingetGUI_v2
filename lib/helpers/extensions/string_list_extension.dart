extension StringListExtension on List<String> {
  List<String> trimLeading() {
    bool foundNotEmpty = false;
    while (!foundNotEmpty && isNotEmpty) {
      String line = first;
      if (line.trim().isEmpty) {
        removeAt(0);
      } else {
        foundNotEmpty = true;
      }
    }
    return this;
  }

  List<String> trimTrailing() {
    bool foundNotEmpty = false;
    while (!foundNotEmpty && isNotEmpty) {
      String line = last;
      if (line.trim().isEmpty) {
        removeLast();
      } else {
        foundNotEmpty = true;
      }
    }
    return this;
  }

  List<String> trim() {
    trimLeading();
    trimTrailing();
    return this;
  }
}
