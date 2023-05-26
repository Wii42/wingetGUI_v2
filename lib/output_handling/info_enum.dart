enum Info {
  id(key: 'ID', title: 'App ID'),
  description(key: 'Beschreibung', title: 'About'),
  name(key: 'Name', title: 'Name'),
  publisher(key: 'Herausgeber', title: 'Publisher'),
  publisherUrl(key: 'Herausgeber-URL', title: 'Publisher URL'),
  publisherSupportUrl(key: 'Herausgeber-Support-URL', title: 'Support'),
  version(key: 'Version', title: 'Version'),
  availableVersion(key: 'Verfügbar', title: 'Available'),
  tags(key: 'Markierungen', title: 'Tags'),
  releaseNotes(key: 'Versionshinweise', title: 'Release Notes'),
  releaseNotesUrl(
      key: 'URL der Versionshinweise', title: 'Show Online'),
  installer(key: 'Installationsprogramm', title: 'Installer'),
  source(key: 'Quelle', title: 'Source'),
  website(key: 'Startseite', title: 'Website'),

  license(key: 'Lizenz', title: 'License'),
  licenseUrl(key: 'Lizenz-URL', title: 'License Link'),
  copyright(key: 'Copyright', title: 'Copyright'),
  copyrightUrl(key: 'Copyright-URL', title: 'Copyright URL'),
  privacyUrl(key: 'Datenschutz-URL', title: 'Privacy'),
  buyUrl(key: 'Kauf-URL', title: 'Buy'),
  termsOfTransaction(
      key: 'Terms of Transaction', title: 'Terms of Transaction'),
  seizureWarning(key: 'Seizure Warning', title: 'Seizure Warning'),
  storeLicenseTerms(key: 'Store License Terms', title: 'Store License Terms'),

  author(key: 'Autor', title: 'Author'),
  moniker(key: 'Moniker', title: 'Moniker'),
  documentation(key: 'Dokumentation', title: 'Documentation'),

  agreement(key: 'Vereinbarungen', title: 'Agreement'),
  category(key: 'Category', title: 'Category'),
  pricing(key: 'Pricing', title: 'Pricing'),
  freeTrial(key: 'Free Trial', title: 'Free Trial'),
  ageRating(key: 'Age Ratings', title: 'Age Rating'),

  installerType(key: 'Installertyp', title: 'Installer Type'),
  storeProductID(key: 'Store-Produkt-ID', title: 'Store Product ID'),
  installerURL(key: 'Installer-URL', title: 'Download Installer Manually'),
  sha256Installer(key: 'Sha256-Installer', title: 'SHA256 Installer'),
  installerLocale(key: 'Installer-Gebietsschema', title: 'Locale'),
  releaseDate(key: 'Freigabedatum', title: 'Release Date'),
  ;

  final String key;
  final String title;

  const Info({required this.key, required this.title});
}
