

import 'package:winget_core/src/localization_name.dart';
import 'package:winget_core/src/package_localizer.dart';

import 'identifying_property.dart';

enum InstallerType implements IdentifyingProperty {
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
  matchAll(key: '_', shortTitle: '<match all>');

  final String key;
  final String _shortTitle;
  final String? _longTitle;

  const InstallerType(
      {required this.key, required String shortTitle, String? longTitle})
      : _longTitle = longTitle,
        _shortTitle = shortTitle;

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

  @override
  String shortTitle([PackageLocalizer? _]) => _shortTitle;

  @override
  String? longTitle([PackageLocalizer? _, LocalizationName? __]) => _longTitle;

  @override
  bool get fullTitleHasShortAlways => true;
}
