import 'info.dart';

abstract class PackageInfos {
  final Info<String>? name, id, version;

  final Map<String, String>? otherInfos;

  PackageInfos({
    this.name,
    this.id,
    this.version,
    this.otherInfos,
  });

  bool hasVersion() => (version != null && version?.value != 'Unknown');
}
