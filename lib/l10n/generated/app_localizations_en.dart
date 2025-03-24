// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get runCommand => 'Run Command';

  @override
  String wingetTitle(String command) {
    String _temp0 = intl.Intl.selectLogic(
      command,
      {
        'updates': 'Updates',
        'updatesPage': 'Updates',
        'installed': 'Installed',
        'installedPage': 'Installed',
        'about': 'About Winget',
        'help': 'Help',
        'search': 'Search Apps',
        'settings': 'Winget Settings',
        'sources': 'Sources',
        'install': 'Install',
        'upgrade': 'Upgrade',
        'uninstall': 'Uninstall',
        'show': 'Show',
        'searchPage': 'Explore Apps',
        'commandPromptPage': 'Run Command',
        'upgradeAll': 'Upgrade All',
        'advancedOptions': 'Advanced',
        'settingsPage': 'Settings',
        'logsPage': 'Logs',
        'logDetailsPage': 'Log Details',
        'availablePackages': 'Available Apps',
        'tinkeringSection': 'Tinkering Section',
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
        'search': 'Search',
        'show': '',
        'other': 'NotFoundError',
      },
    );
    return '$_temp0';
  }

  @override
  String get history => 'History';

  @override
  String infoKey(String info) {
    String _temp0 = intl.Intl.selectLogic(
      info,
      {
        'id': 'ID',
        'description': 'Description',
        'name': 'Name',
        'publisher': 'Publisher',
        'publisherUrl': 'PublisherUrl',
        'publisherSupportUrl': 'PublisherSupportUrl',
        'version': 'Version',
        'availableVersion': 'Available',
        'tags': 'Tags',
        'releaseNotes': 'ReleaseNotes',
        'releaseNotesUrl': 'ReleaseNotesUrl',
        'installer': 'Installationsprogramm',
        'source': 'Source',
        'website': 'Homepage',
        'license': 'License',
        'licenseUrl': 'LicenseUrl',
        'copyright': 'Copyright',
        'copyrightUrl': 'CopyrightUrl',
        'privacyUrl': 'PrivacyUrl',
        'buyUrl': 'BuyUrl',
        'termsOfTransaction': 'Terms of Transaction',
        'seizureWarning': 'Seizure Warning',
        'storeLicenseTerms': 'Store License Terms',
        'author': 'Author',
        'moniker': 'AppMoniker',
        'documentation': 'Documentation',
        'agreement': 'Agreement',
        'category': 'Category',
        'pricing': 'Pricing',
        'freeTrial': 'Free Trial',
        'ageRating': 'Age Ratings',
        'installerType': 'Type',
        'storeProductID': 'Store Product ID',
        'installerURL': 'Download Url',
        'sha256Installer': 'SHA256',
        'installerLocale': 'Language',
        'releaseDate': 'Freigabedatum',
        'match': 'Match',
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
        'id': 'App ID',
        'description': 'About',
        'name': 'Name',
        'publisher': 'Publisher',
        'publisherUrl': 'Publisher URL',
        'publisherSupportUrl': 'Support',
        'version': 'Version',
        'availableVersion': 'Available',
        'tags': 'Tags',
        'releaseNotes': 'Release Notes',
        'releaseNotesUrl': 'Show Online',
        'installer': 'Installer',
        'source': 'Source',
        'website': 'Website',
        'license': 'License',
        'licenseUrl': 'License',
        'copyright': 'Copyright',
        'copyrightUrl': 'Copyright',
        'privacyUrl': 'Privacy',
        'buyUrl': 'Buy',
        'termsOfTransaction': 'Terms of Transaction',
        'seizureWarning': 'Seizure Warning',
        'storeLicenseTerms': 'Store License Terms',
        'author': 'Author',
        'moniker': 'Moniker',
        'documentation': 'Documentation',
        'agreement': 'Agreement',
        'category': 'Category',
        'pricing': 'Pricing',
        'freeTrial': 'Free Trial',
        'ageRating': 'Age Rating',
        'installerType': 'Installer Type',
        'storeProductID': 'Store Product ID',
        'installerURL': 'Download Installer Manually',
        'sha256Installer': 'SHA256 Hash',
        'installerLocale': 'Locale',
        'releaseDate': 'Release Date',
        'manifest': 'Manifest',
        'match': 'Match',
        'installers': 'Available Installers',
        'upgradeBehavior': 'Upgrade Behavior',
        'fileExtensions': 'Supported File Types',
        'packageLocale': 'Locale',
        'platform': 'Plattform',
        'architecture': 'Architecture',
        'minimumOSVersion': 'Minimal OS Version',
        'installScope': 'Installation Scope',
        'signatureSha256': 'Signature Hash',
        'elevationRequirement': 'Elevation requirement',
        'productCode': 'Product Code',
        'appsAndFeaturesEntries': '\'Apps and Features\' Entries',
        'installerSwitches': 'Installer Switches',
        'installModes': 'Install Modes',
        'shortDescription': 'Short Description',
        'nestedInstallerType': 'Typ of the Nested Installer',
        'availableCommands': 'Available Commands',
        'dependencies': 'Package Dependencies',
        'protocols': 'Supported Protocols',
        'auto': 'Auto',
        'random': 'Random',
        'packageFamilyName': 'Package Family Name',
        'markets': 'Markets',
        'expectedReturnCodes': 'Expected Response Codes',
        'installerSuccessCodes': 'Installer Success Codes',
        'installationNotes': 'Installation Notes',
        'other': 'NotFoundError',
      },
    );
    return '$_temp0';
  }

  @override
  String get details => 'Details';

  @override
  String fromSource(Object source) {
    return 'from $source';
  }

  @override
  String get found => 'Found';

  @override
  String get agreementsFor => 'Agreements for';

  @override
  String get showInStore => 'Show in Store';

  @override
  String get showMore => 'show more';

  @override
  String get showLess => 'show less';

  @override
  String get endProcess => 'End Current Process';

  @override
  String get showInSeparatePage => 'Open in separate window';

  @override
  String get waitOnData => 'waiting on data...';

  @override
  String get showOnlyClickablePackages => 'show only selectable apps';

  @override
  String get showOnlyPackagesWithSpecificVersion => 'show only apps with known specific version';

  @override
  String nrOfPackagesShown(Object number, Object total) {
    return '$number of $total apps are displayed';
  }

  @override
  String nrOfPackages(Object total) {
    return '$total apps';
  }

  @override
  String get chooseDisplayMode => 'Choose mode';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get chooseWingetLanguage => 'Choose language of Winget';

  @override
  String get openWingetSettingsFile => 'Open Winget settings file';

  @override
  String themeMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'system': 'System',
        'light': 'Light',
        'dark': 'Dark',
        'other': 'NotFoundError',
      },
    );
    return '$_temp0';
  }

  @override
  String get autoLanguage => 'auto';

  @override
  String get error => 'Error';

  @override
  String get unexpectedError => 'Unexpected error';

  @override
  String get installed => 'Installed';

  @override
  String get installSuccessful => 'Installation successful';

  @override
  String get uninstallSuccessful => 'Uninstall successful';

  @override
  String get userScope => 'User';

  @override
  String get machineScope => 'Machine Wide';

  @override
  String installMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'interactive': 'interactive',
        'silent': 'silent',
        'silentWithProgress': 'silent with progress',
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
        'install': 'Install',
        'uninstallPrevious': 'Uninstall previous version',
        'deny': 'Deny',
        'custom': '<Custom>',
        'other': 'NotFoundError',
      },
    );
    return '$_temp0';
  }

  @override
  String get cantLoadDetails => 'Can\'t load details';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get reason => 'Reason';

  @override
  String moreFromPublisher(Object publisher) {
    return 'More from $publisher';
  }

  @override
  String downloadManually(Object installerDescription) {
    return 'Download $installerDescription manually';
  }

  @override
  String installer(Object description) {
    return '$description installer';
  }

  @override
  String multipleInstallersFound(Object nrOfInstallers) {
    return '$nrOfInstallers installers found for this app. Select the one you want to see:';
  }

  @override
  String multipleFittingInstallersFound(Object nrOfInstallers) {
    return '$nrOfInstallers installers found for the selected options. Select one:';
  }

  @override
  String get noInstallerFound => 'No installer found for the selected options';

  @override
  String get close => 'Close';

  @override
  String get localPC => 'local PC';

  @override
  String get noAppsFound => 'No apps found';

  @override
  String get noFittingAppsFound => 'No fitting apps found';

  @override
  String get onlyAppsWithSource => 'Only apps with source';

  @override
  String get onlyAppsWithExactVersion => 'Only apps with exact version';

  @override
  String get sortBy => 'Sort by';

  @override
  String get extendedSearch => 'Extended search';

  @override
  String get searchFor => 'Search for';

  @override
  String get waiting => 'waiting...';

  @override
  String returnResponse(String response) {
    String _temp0 = intl.Intl.selectLogic(
      response,
      {
        'packageInUse': 'Package in Use',
        'packageInUseByApplication': 'Package in Use by Application',
        'installInProgress': 'Install in Progress',
        'fileInUse': 'File in Use',
        'missingDependency': 'Missing Dependency',
        'diskFull': 'Disk Full',
        'insufficientMemory': 'Insufficient Memory',
        'invalidParameter': 'Invalid Parameter',
        'noNetwork': 'No Network',
        'contactSupport': 'Contact Support',
        'rebootRequiredToFinish': 'Reboot Required to Finish',
        'rebootRequiredForInstall': 'Reboot Required for Install',
        'rebootInitiated': 'Reboot Initiated',
        'cancelledByUser': 'Cancelled by User',
        'alreadyInstalled': 'Already Installed',
        'downgrade': 'Downgrade',
        'blockedByPolicy': 'Blocked by Policy',
        'systemNotSupported': 'System Not Supported',
        'custom': 'Custom Response',
        'other': 'NotFoundError',
      },
    );
    return '$_temp0';
  }

  @override
  String get copyToClipboardTooltip => 'Copy to clipboard';

  @override
  String get openMSStorePageTooltip => 'Open the Microsoft Store page for this app';

  @override
  String get openHelpTooltip => 'Open help in a new page';

  @override
  String get viewLogDetailsTooltip => 'View log details';

  @override
  String get moreFromPublisherTooltip => 'Show all Apps from this Publisher';

  @override
  String get packagePeekTooltip => 'Show app details';

  @override
  String runCommandTooltip(Object command) {
    return 'Run command \'$command\'';
  }

  @override
  String readOutputOfCommand(Object command) {
    return 'Reading output of \'$command\'...';
  }

  @override
  String get loading => 'Loading...';

  @override
  String get output => 'Output';

  @override
  String parsingContent(Object content) {
    return 'Parsing $content...';
  }

  @override
  String get apps => 'Apps';

  @override
  String get checkingWingetAvailability => 'Checking winget availability...';

  @override
  String get errorWingetNotAvailable => 'Winget is not available\nPlease install the winget command line tool and restart the app.';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get warning => 'Warning';

  @override
  String processesQueued(Object nrOfProcesses) {
    return '$nrOfProcesses processes are in queue for execution';
  }

  @override
  String get onlyAppsWithSourceTooltip => 'Show only apps from a known package source';

  @override
  String get onlyAppsWithExactVersionTooltip => 'Show only apps with a known specific version';

  @override
  String actionOnAll(Object action) {
    return '$action all';
  }

  @override
  String get ok => 'Ok';
}
