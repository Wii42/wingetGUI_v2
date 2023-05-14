extension ContainsExtentsion on String {
  static final List<int> _loadingSymbols = [8, 45, 47, 92, 124];

  bool isLoadingSymbols() {
    if (isEmpty) {
      return false;
    }

    String bs = String.fromCharCode(8);
    List<String> spinning = ['$bs-', '$bs\\', '$bs/', '$bs|', bs];

    return (spinning.contains(trim()));
  }
}
