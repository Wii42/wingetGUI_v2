class Infos{
  final Map<String, String> details;
  final Map<String, String>? installerDetails;
  final List<String>? tags;

  Infos({required this.details, this.installerDetails, this.tags});

  bool hasInstallerDetails() => installerDetails != null;

  bool hasTags() => tags != null;
}