enum Info {
  description(key: 'Beschreibung'),
  name(key: 'Name'),
  publisher(key: 'Herausgeber'),
  publisherUrl(key: 'Herausgeber-URL'),
  version(key: 'Version'),
  availableVersion(key: 'Verfügbar'),
  tags(key: 'Markierungen'),
  releaseNotes(key: 'Versionshinweise'),
  releaseNotesUrl(key: 'URL der Versionshinweise'),
  installer(key: 'Installationsprogramm'),
  id(key: 'ID'),
  source(key: 'Quelle'),
  website(key: 'Startseite'),
  license(key: 'Lizenz'),
  licenseUrl(key: 'Lizenz-URL'),
  copyright(key: 'Copyright'),
  copyrightUrl(key: 'Copyright-URL'),
  privacyUrl(key: 'Datenschutz-URL'),
  buyUrl(key: 'Kauf-URL'),
  termsOfTransaction(key: 'Terms of Transaction'),
  seizureWarning(key: 'Seizure Warning'),
  storeLicenseTerms(key: 'Store License Terms');

  final String key;

  const Info({required this.key});
}
