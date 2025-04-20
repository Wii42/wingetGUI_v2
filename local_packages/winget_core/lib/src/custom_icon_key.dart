/// A class to store the custom keys for icons.
class CustomIconKey {
  final String oldKey;
  final String? newKey;
  final List<String> otherKeys;

  CustomIconKey({required this.oldKey, this.newKey, this.otherKeys = const []});

  factory CustomIconKey.fromJson(Map<String, dynamic> json, String key) {
    List<dynamic> otherKeys = json['other_keys'] ?? const [];
    return CustomIconKey(
      oldKey: key,
      newKey: json['new_key'],
      otherKeys: otherKeys.cast<String>(),
    );
  }

  @override
  String toString() {
    return 'CustomIconKey{oldKey: $oldKey, newKey: $newKey, otherKeys: $otherKeys}';
  }
}