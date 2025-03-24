// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get runCommand => 'Führe Befehl aus';

  @override
  String wingetTitle(String command) {
    String _temp0 = intl.Intl.selectLogic(
      command,
      {
        'updates': 'Aktualisierungen',
        'updatesPage': 'Aktualisierungen',
        'installed': 'Installiert',
        'installedPage': 'Installiert',
        'about': 'Über Winget',
        'help': 'Hilfe',
        'search': 'Suche Apps',
        'settings': 'Winget-Einstellungen',
        'sources': 'Quellen',
        'install': 'Installieren',
        'upgrade': 'Aktualisieren',
        'uninstall': 'Deinstallieren',
        'show': 'Anzeigen',
        'searchPage': 'Apps entdecken',
        'commandPromptPage': 'Befehl Ausführen',
        'upgradeAll': 'Alle Aktualisieren',
        'advancedOptions': 'Erweitert',
        'settingsPage': 'Einstellungen',
        'logsPage': 'Logs',
        'logDetailsPage': 'Log Details',
        'availablePackages': 'Verfügbare Apps',
        'tinkeringSection': 'Bastelbereich',
        'other': 'NotFoundError',
      },
    );
    return '$_temp0';
  }

  @override
  String wingetTitlePrefix(String command) {
    String _temp0 = intl.Intl.selectLogic(
      command,
      {
        'search': 'Suche nach',
        'install': 'Installiere',
        'upgrade': 'Aktualisiere',
        'uninstall': 'Deinstalliere',
        'show': '',
        'other': 'NotFoundError',
      },
    );
    return '$_temp0';
  }

  @override
  String get history => 'Verlauf';

  @override
  String infoKey(String info) {
    String _temp0 = intl.Intl.selectLogic(
      info,
      {
        'id': 'ID',
        'description': 'Beschreibung',
        'name': 'Name',
        'publisher': 'Herausgeber',
        'publisherUrl': 'Herausgeber-URL',
        'publisherSupportUrl': 'Herausgeber-Support-URL',
        'version': 'Version',
        'availableVersion': 'Verfügbar',
        'tags': 'Markierungen',
        'releaseNotes': 'Versionshinweise',
        'releaseNotesUrl': 'URL der Versionshinweise',
        'installer': 'Installationsprogramm',
        'source': 'Quelle',
        'website': 'Startseite',
        'license': 'Lizenz',
        'licenseUrl': 'Lizenz-URL',
        'copyright': 'Copyright',
        'copyrightUrl': 'Copyright-URL',
        'privacyUrl': 'Datenschutz-URL',
        'buyUrl': 'Kauf-URL',
        'termsOfTransaction': 'Terms of Transaction',
        'seizureWarning': 'Seizure Warning',
        'storeLicenseTerms': 'Store License Terms',
        'author': 'Autor',
        'moniker': 'Moniker',
        'documentation': 'Dokumentation',
        'agreement': 'Vereinbarungen',
        'category': 'Category',
        'pricing': 'Pricing',
        'freeTrial': 'Free Trial',
        'ageRating': 'Age Ratings',
        'installerType': 'Installertyp',
        'storeProductID': 'Store-Produkt-ID',
        'installerURL': 'Installer-URL',
        'sha256Installer': 'Sha256-Installer',
        'installerLocale': 'Installer-Gebietsschema',
        'releaseDate': 'Freigabedatum',
        'match': 'Übereinstimmung',
        'other': 'NotFoundError',
      },
    );
    return '$_temp0';
  }

  @override
  String infoTitle(String info) {
    String _temp0 = intl.Intl.selectLogic(
      info,
      {
        'id': 'App-ID',
        'description': 'Beschreibung',
        'name': 'Name',
        'publisher': 'Herausgeber',
        'publisherUrl': 'Herausgeber-URL',
        'publisherSupportUrl': 'Support',
        'version': 'Version',
        'availableVersion': 'Verfügbar',
        'tags': 'Markierungen',
        'releaseNotes': 'Versionshinweise',
        'releaseNotesUrl': 'online anzeigen',
        'installer': 'Installationsprogramm',
        'source': 'Quelle',
        'website': 'Webseite',
        'license': 'Lizenz',
        'licenseUrl': 'Lizenz',
        'copyright': 'Copyright',
        'copyrightUrl': 'Copyright',
        'privacyUrl': 'Datenschutz',
        'buyUrl': 'Kaufen',
        'termsOfTransaction': 'Geschäftsbedingungen',
        'seizureWarning': 'Anfallswarnung',
        'storeLicenseTerms': 'Store-Lizenzbedingungen',
        'author': 'Autor',
        'moniker': 'Moniker',
        'documentation': 'Dokumentation',
        'agreement': 'Vereinbarungen',
        'category': 'Kategorie',
        'pricing': 'Preis',
        'freeTrial': 'Testphase',
        'ageRating': 'Altersfreigabe',
        'installerType': 'Installertyp',
        'storeProductID': 'Store-Produkt-ID',
        'installerURL': 'Installer manuell herunterladen',
        'sha256Installer': 'SHA256-Hash',
        'installerLocale': 'Installer-Gebietsschema',
        'releaseDate': 'Veröffentlichungsdatum',
        'match': 'Übereinstimmung',
        'manifest': 'Manifest',
        'installers': 'Verfügbare Installer',
        'upgradeBehavior': 'Update-Verhalten',
        'fileExtensions': 'Unterstützte Dateiformate',
        'packageLocale': 'Gebietsschema',
        'platform': 'Plattform',
        'architecture': 'Architektur',
        'minimumOSVersion': 'Minimale OS-Version',
        'installScope': 'Installationsbereich',
        'signatureSha256': 'Signatur-Hash',
        'elevationRequirement': 'Update-Voraussetzung',
        'productCode': 'Produkt-Code',
        'appsAndFeaturesEntries': '\'Apps und Features\'-Einträge',
        'installerSwitches': 'Installer Switches',
        'installModes': 'Installationsmodi',
        'shortDescription': 'Kurzbeschreibung',
        'nestedInstallerType': 'Typ des eingebetteten Installers',
        'availableCommands': 'Verfügbare Befehle',
        'dependencies': 'Paketabhängigkeiten',
        'protocols': 'Unterstützte Protokolle',
        'auto': 'Auto',
        'random': 'Zufällig',
        'packageFamilyName': 'Paketfamilienname',
        'markets': 'Märkte',
        'expectedReturnCodes': 'Erwartete Return-Codes',
        'installerSuccessCodes': 'Installer Success-Codes',
        'installationNotes': 'Installationshinweise',
        'other': 'NotFoundError',
      },
    );
    return '$_temp0';
  }

  @override
  String get details => 'Details';

  @override
  String fromSource(Object source) {
    return 'via $source';
  }

  @override
  String get found => 'Gefunden';

  @override
  String get agreementsFor => 'Vereinbarungen für';

  @override
  String get showInStore => 'Im Store anzeigen';

  @override
  String get showMore => 'mehr anzeigen';

  @override
  String get showLess => 'weniger anzeigen';

  @override
  String get endProcess => 'Laufenden Prozess beenden';

  @override
  String get showInSeparatePage => 'In separatem Fenster öffen';

  @override
  String get waitOnData => 'auf Daten warten...';

  @override
  String get showOnlyClickablePackages => 'nur anwählbare Apps anzeigen';

  @override
  String get showOnlyPackagesWithSpecificVersion => 'nur Apps mit genau bekannter Version anzeigen';

  @override
  String nrOfPackagesShown(Object number, Object total) {
    return '$number von $total Apps werden angezeigt';
  }

  @override
  String nrOfPackages(Object total) {
    return '$total Apps';
  }

  @override
  String get chooseDisplayMode => 'Modus auswählen';

  @override
  String get chooseLanguage => 'Sprache wählen';

  @override
  String get chooseWingetLanguage => 'Sprache von Winget wählen';

  @override
  String get openWingetSettingsFile => 'Öffne Winget-Einstellungen-Dokument';

  @override
  String themeMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'system': 'System',
        'light': 'Hell',
        'dark': 'Dunkel',
        'other': 'NotFoundError',
      },
    );
    return '$_temp0';
  }

  @override
  String get autoLanguage => 'auto';

  @override
  String get error => 'Fehler';

  @override
  String get unexpectedError => 'Unerwarteter Fehler';

  @override
  String get installed => 'Installiert';

  @override
  String get installSuccessful => 'Erfolgreich installiert';

  @override
  String get uninstallSuccessful => 'Erfolgreich deinstalliert';

  @override
  String get userScope => 'User';

  @override
  String get machineScope => 'Machine-Wide';

  @override
  String installMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'interactive': 'interaktiv',
        'silent': 'still',
        'silentWithProgress': 'still mit Fortschritt',
        'other': 'NotFoundError',
      },
    );
    return '$_temp0';
  }

  @override
  String upgradeBehavior(String behavior) {
    String _temp0 = intl.Intl.selectLogic(
      behavior,
      {
        'install': 'Installieren',
        'uninstallPrevious': 'Bisherige Version deinstallieren',
        'deny': 'Verweigern',
        'custom': '<Benutzerdefiniert>',
        'other': 'NotFoundError',
      },
    );
    return '$_temp0';
  }

  @override
  String get cantLoadDetails => 'Details konnten nicht geladen werden';

  @override
  String get noInternetConnection => 'Keine Internetverbindung';

  @override
  String get reason => 'Grund';

  @override
  String moreFromPublisher(Object publisher) {
    return 'Mehr von $publisher';
  }

  @override
  String downloadManually(Object installerDescription) {
    return '$installerDescription manuell herunterladen';
  }

  @override
  String installer(Object description) {
    return '$description Installer';
  }

  @override
  String multipleInstallersFound(Object nrOfInstallers) {
    return '$nrOfInstallers Installer gefunden für diese App. Wählen sie denjenigen aus, den Sie sehen möchten:';
  }

  @override
  String multipleFittingInstallersFound(Object nrOfInstallers) {
    return '$nrOfInstallers Installer gefunden für gewählte Optionen. Wählen sie einen:';
  }

  @override
  String get noInstallerFound => 'Kein Installer gefunden für die gewählten Optionen';

  @override
  String get close => 'Schliessen';

  @override
  String get localPC => 'lokaler PC';

  @override
  String get noAppsFound => 'Keine Apps gefunden';

  @override
  String get noFittingAppsFound => 'Keine passenden Apps gefunden';

  @override
  String get onlyAppsWithSource => 'Nur Apps mit Quelle';

  @override
  String get onlyAppsWithExactVersion => 'Nur Apps mit exakter Version';

  @override
  String get sortBy => 'Sortieren nach';

  @override
  String get extendedSearch => 'Erweiterte Suche';

  @override
  String get searchFor => 'Suche nach';

  @override
  String get waiting => 'wartend...';

  @override
  String returnResponse(String response) {
    String _temp0 = intl.Intl.selectLogic(
      response,
      {
        'packageInUse': 'Package in Benutzung',
        'packageInUseByApplication': 'Package wird von Applikation benutzt',
        'installInProgress': 'Installation im Gang',
        'fileInUse': 'Datei in Benutzung',
        'missingDependency': 'Fehlende Abhängigkeit',
        'diskFull': 'Festplatte voll',
        'insufficientMemory': 'Nicht genügend Arbeitsspeicher',
        'invalidParameter': 'Invalider Parameter',
        'noNetwork': 'Kein Netzwerk',
        'contactSupport': 'Kontaktieren Sie den Support',
        'rebootRequiredToFinish': 'Neustart zum Abschluss erforderlich',
        'rebootRequiredForInstall': 'Neustart erforderlich für Installation',
        'rebootInitiated': 'Neustart eingeleitet',
        'cancelledByUser': 'Vom Benutzer abgebrochen',
        'alreadyInstalled': 'Bereits installiert',
        'downgrade': 'Downgrade',
        'blockedByPolicy': 'Durch Richtlinien blockiert',
        'systemNotSupported': 'System nicht unterstützt',
        'custom': 'Benutzerdefinierte Antwort',
        'other': 'NotFoundError',
      },
    );
    return '$_temp0';
  }

  @override
  String get copyToClipboardTooltip => 'In Zwischenablage kopieren';

  @override
  String get openMSStorePageTooltip => 'Öffne Microsoft Store-Seite für diese App';

  @override
  String get openHelpTooltip => 'Öffne Hilfe auf neuer Seite';

  @override
  String get viewLogDetailsTooltip => 'Zeige Log-Details';

  @override
  String get moreFromPublisherTooltip => 'Zeige alle Apps von diesem Herausgeber';

  @override
  String get packagePeekTooltip => 'Zeige App-Details';

  @override
  String runCommandTooltip(Object command) {
    return 'Führe Befehl \'$command\' aus';
  }

  @override
  String readOutputOfCommand(Object command) {
    return 'Ausgabe von \'$command\' wird gelesen...';
  }

  @override
  String get loading => 'Wird geladen...';

  @override
  String get output => 'Ausgabe';

  @override
  String parsingContent(Object content) {
    return '$content wird analysiert...';
  }

  @override
  String get apps => 'Apps';

  @override
  String get checkingWingetAvailability => 'Überprüfe Verfügbarkeit von winget...';

  @override
  String get errorWingetNotAvailable => 'Winget ist nicht verfügbar\nBitte installieren Sie winget und starten Sie die App erneut.';

  @override
  String get errorOccurred => 'Ein Fehler ist aufgetreten';

  @override
  String get warning => 'Warnung';

  @override
  String processesQueued(Object nrOfProcesses) {
    return '$nrOfProcesses Prozesse in Warteschlange';
  }

  @override
  String get onlyAppsWithSourceTooltip => 'Nur Apps anzeigen, die von einer bekannten Paketquelle stammen';

  @override
  String get onlyAppsWithExactVersionTooltip => 'Nur Apps anzeigen, die eine bekannte exakte Version haben';

  @override
  String actionOnAll(Object action) {
    return 'Alle $action';
  }

  @override
  String get ok => 'Ok';
}
