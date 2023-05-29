extension HasEntryExtension<T> on Map<T, String> {
  bool hasEntry(T key) {
    return (containsKey(key) && this[key]!.isNotEmpty);
  }
}
