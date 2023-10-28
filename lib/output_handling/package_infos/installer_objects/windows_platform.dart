enum WindowsPlatform {
  universal('Windows Universal'),
  desktop('Windows Desktop'),
  ;

  final String title;
  const WindowsPlatform(this.title);

  static WindowsPlatform fromYaml(dynamic platform) {
    switch (platform) {
      case 'Windows.Universal':
        return WindowsPlatform.universal;
      case 'Windows.Desktop':
        return WindowsPlatform.desktop;
      default:
        throw ArgumentError('Unknown Windows platform: $platform');
    }
  }
}
