enum InstallerType {
  msix(key: 'msix', shortTitle: 'MSIX'),
  msi(key: 'msi', shortTitle: 'MSI'),
  appx(key: 'appx', shortTitle: 'APPX'),
  exe(key: 'exe', shortTitle: 'EXE'),
  inno(key: 'inno', shortTitle: 'Inno Setup'),
  nullsoft(
      key: 'nullsoft',
      shortTitle: 'NSIS',
      longTitle: 'Nullsoft Scriptable Install System'),
  wix(key: 'wix', shortTitle: 'WiX', longTitle: 'Windows Installer XML'),
  burn(key: 'burn', shortTitle: 'Burn'),
  pwa(key: 'pwa', shortTitle: 'Progressive Web App (PWA)'),
  portable(key: 'portable', shortTitle: 'Portable'),
  zip(key: 'zip', shortTitle: 'ZIP'),
  msstore(key: 'msstore', shortTitle: 'Microsoft Store'),
  ;

  final String key;
  final String shortTitle;
  final String? longTitle;
  const InstallerType(
      {required this.key, required this.shortTitle, this.longTitle});


  static InstallerType parse(String string) {
    return maybeParse(string)!;
  }

  static InstallerType? maybeParse(String? string) {
    if (string == null) {
      return null;
    }
    for (InstallerType type in InstallerType.values) {
      if (type.key == string) {
        return type;
      }
    }
    throw ArgumentError('Unknown installer type: $string');
  }

  String get fullTitle {
    if (longTitle != null) {
      return "$longTitle ($shortTitle)";
    }
    return shortTitle;
  }
}
