enum Info {
  description(key: 'Beschreibung'),
  name(key: 'Name'),
  publisher(key: 'Herausgeber'),
  publisherUrl(key: 'Herausgeber-URL'),
  version(key: 'Version'),
  availableVersion(key: 'Verfügbar'),
  tags(key: 'Markierungen'),
  releaseNotes(key: 'Versionshinweise'),
  installer(key: 'Installationsprogramm'),
  id(key: 'ID'),
  source(key: 'Quelle');

  final String key;

  const Info({required this.key});
}
