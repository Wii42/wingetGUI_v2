import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @runCommand.
  ///
  /// In en, this message translates to:
  /// **'Run Command'**
  String get runCommand;

  /// No description provided for @wingetTitle.
  ///
  /// In en, this message translates to:
  /// **'{command, select, updates{Updates}  updatesPage{Updates} installed{Installed}  installedPage{Installed} about{About Winget} help{Help} search{Search Apps} settings{Winget Settings} sources{Sources} install{Install} upgrade{Upgrade} uninstall{Uninstall}  show{Show}  searchPage{Explore Apps} commandPromptPage{Run Command} upgradeAll{Upgrade All} advancedOptions{Advanced} settingsPage{Settings} logsPage{Logs} logDetailsPage{Log Details} availablePackages{Available Apps} tinkeringSection{Tinkering Section} other{NotFoundError}}'**
  String wingetTitle(String command);

  /// No description provided for @wingetTitlePrefix.
  ///
  /// In en, this message translates to:
  /// **'{command, select, search{Search} show {} other{NotFoundError}}'**
  String wingetTitlePrefix(String command);

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @infoKey.
  ///
  /// In en, this message translates to:
  /// **'{info, select, id{ID} description{Description} name{Name} publisher{Publisher} publisherUrl{PublisherUrl} publisherSupportUrl{PublisherSupportUrl} version{Version}  availableVersion{Available} tags{Tags} releaseNotes{ReleaseNotes} releaseNotesUrl{ReleaseNotesUrl} installer{Installationsprogramm} source{Source} website{Homepage} license{License} licenseUrl{LicenseUrl} copyright{Copyright} copyrightUrl{CopyrightUrl} privacyUrl{PrivacyUrl} buyUrl{BuyUrl} termsOfTransaction{Terms of Transaction} seizureWarning{Seizure Warning} storeLicenseTerms{Store License Terms} author{Author} moniker{AppMoniker} documentation{Documentation} agreement{Agreement} category{Category} pricing{Pricing} freeTrial{Free Trial} ageRating{Age Ratings} installerType{Type} storeProductID{Store Product ID} installerURL{Download Url} sha256Installer{SHA256} installerLocale{Language} releaseDate{Freigabedatum}  match{Match} other{NotFoundError}}'**
  String infoKey(String info);

  /// No description provided for @infoTitle.
  ///
  /// In en, this message translates to:
  /// **'{info, select, id{App ID} description{About} name{Name} publisher{Publisher} publisherUrl{Publisher URL} publisherSupportUrl{Support} version{Version}  availableVersion{Available} tags{Tags} releaseNotes{Release Notes} releaseNotesUrl{Show Online} installer{Installer} source{Source} website{Website} license{License} licenseUrl{License} copyright{Copyright} copyrightUrl{Copyright} privacyUrl{Privacy} buyUrl{Buy} termsOfTransaction{Terms of Transaction} seizureWarning{Seizure Warning} storeLicenseTerms{Store License Terms} author{Author} moniker{Moniker} documentation{Documentation} agreement{Agreement} category{Category} pricing{Pricing} freeTrial{Free Trial} ageRating{Age Rating} installerType{Installer Type} storeProductID{Store Product ID} installerURL{Download Installer Manually} sha256Installer{SHA256 Hash} installerLocale{Locale} releaseDate{Release Date} manifest{Manifest} match{Match} installers{Available Installers} upgradeBehavior{Upgrade Behavior} fileExtensions{Supported File Types} packageLocale{Locale} platform{Plattform} architecture{Architecture} minimumOSVersion{Minimal OS Version} installScope{Installation Scope} signatureSha256{Signature Hash} elevationRequirement{Elevation requirement} productCode{Product Code} appsAndFeaturesEntries{\'Apps and Features\' Entries} installerSwitches{Installer Switches} installModes{Install Modes} shortDescription{Short Description} nestedInstallerType{Typ of the Nested Installer} availableCommands{Available Commands} dependencies{Package Dependencies} protocols{Supported Protocols}  auto{Auto} random{Random}  packageFamilyName{Package Family Name} markets{Markets} expectedReturnCodes{Expected Response Codes} installerSuccessCodes{Installer Success Codes} installationNotes{Installation Notes} other{NotFoundError}}'**
  String infoTitle(String info);

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @fromSource.
  ///
  /// In en, this message translates to:
  /// **'from {source}'**
  String fromSource(Object source);

  /// No description provided for @found.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get found;

  /// No description provided for @agreementsFor.
  ///
  /// In en, this message translates to:
  /// **'Agreements for'**
  String get agreementsFor;

  /// No description provided for @showInStore.
  ///
  /// In en, this message translates to:
  /// **'Show in Store'**
  String get showInStore;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'show more'**
  String get showMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'show less'**
  String get showLess;

  /// No description provided for @endProcess.
  ///
  /// In en, this message translates to:
  /// **'End Current Process'**
  String get endProcess;

  /// No description provided for @showInSeparatePage.
  ///
  /// In en, this message translates to:
  /// **'Open in separate window'**
  String get showInSeparatePage;

  /// No description provided for @waitOnData.
  ///
  /// In en, this message translates to:
  /// **'waiting on data...'**
  String get waitOnData;

  /// No description provided for @showOnlyClickablePackages.
  ///
  /// In en, this message translates to:
  /// **'show only selectable apps'**
  String get showOnlyClickablePackages;

  /// No description provided for @showOnlyPackagesWithSpecificVersion.
  ///
  /// In en, this message translates to:
  /// **'show only apps with known specific version'**
  String get showOnlyPackagesWithSpecificVersion;

  /// No description provided for @nrOfPackagesShown.
  ///
  /// In en, this message translates to:
  /// **'{number} of {total} apps are displayed'**
  String nrOfPackagesShown(Object number, Object total);

  /// No description provided for @nrOfPackages.
  ///
  /// In en, this message translates to:
  /// **'{total} apps'**
  String nrOfPackages(Object total);

  /// No description provided for @chooseDisplayMode.
  ///
  /// In en, this message translates to:
  /// **'Choose mode'**
  String get chooseDisplayMode;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @chooseWingetLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language of Winget'**
  String get chooseWingetLanguage;

  /// No description provided for @openWingetSettingsFile.
  ///
  /// In en, this message translates to:
  /// **'Open Winget settings file'**
  String get openWingetSettingsFile;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'{mode, select, system{System} light{Light} dark{Dark} other{NotFoundError}}'**
  String themeMode(String mode);

  /// No description provided for @autoLanguage.
  ///
  /// In en, this message translates to:
  /// **'auto'**
  String get autoLanguage;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error'**
  String get unexpectedError;

  /// No description provided for @installed.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get installed;

  /// No description provided for @installSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Installation successful'**
  String get installSuccessful;

  /// No description provided for @uninstallSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Uninstall successful'**
  String get uninstallSuccessful;

  /// No description provided for @userScope.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userScope;

  /// No description provided for @machineScope.
  ///
  /// In en, this message translates to:
  /// **'Machine Wide'**
  String get machineScope;

  /// No description provided for @installMode.
  ///
  /// In en, this message translates to:
  /// **'{mode, select, interactive{interactive} silent{silent} silentWithProgress{silent with progress} other{NotFoundError}}'**
  String installMode(String mode);

  /// No description provided for @upgradeBehavior.
  ///
  /// In en, this message translates to:
  /// **'{behavior, select, install{Install} uninstallPrevious{Uninstall previous version} deny{Deny} custom{<Custom>} other{NotFoundError}}'**
  String upgradeBehavior(String behavior);

  /// No description provided for @cantLoadDetails.
  ///
  /// In en, this message translates to:
  /// **'Can\'t load details'**
  String get cantLoadDetails;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @moreFromPublisher.
  ///
  /// In en, this message translates to:
  /// **'More from {publisher}'**
  String moreFromPublisher(Object publisher);

  /// No description provided for @downloadManually.
  ///
  /// In en, this message translates to:
  /// **'Download {installerDescription} manually'**
  String downloadManually(Object installerDescription);

  /// No description provided for @installer.
  ///
  /// In en, this message translates to:
  /// **'{description} installer'**
  String installer(Object description);

  /// No description provided for @multipleInstallersFound.
  ///
  /// In en, this message translates to:
  /// **'{nrOfInstallers} installers found for this app. Select the one you want to see:'**
  String multipleInstallersFound(Object nrOfInstallers);

  /// No description provided for @multipleFittingInstallersFound.
  ///
  /// In en, this message translates to:
  /// **'{nrOfInstallers} installers found for the selected options. Select one:'**
  String multipleFittingInstallersFound(Object nrOfInstallers);

  /// No description provided for @noInstallerFound.
  ///
  /// In en, this message translates to:
  /// **'No installer found for the selected options'**
  String get noInstallerFound;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @localPC.
  ///
  /// In en, this message translates to:
  /// **'local PC'**
  String get localPC;

  /// No description provided for @noAppsFound.
  ///
  /// In en, this message translates to:
  /// **'No apps found'**
  String get noAppsFound;

  /// No description provided for @noFittingAppsFound.
  ///
  /// In en, this message translates to:
  /// **'No fitting apps found'**
  String get noFittingAppsFound;

  /// No description provided for @onlyAppsWithSource.
  ///
  /// In en, this message translates to:
  /// **'Only apps with source'**
  String get onlyAppsWithSource;

  /// No description provided for @onlyAppsWithExactVersion.
  ///
  /// In en, this message translates to:
  /// **'Only apps with exact version'**
  String get onlyAppsWithExactVersion;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @extendedSearch.
  ///
  /// In en, this message translates to:
  /// **'Extended search'**
  String get extendedSearch;

  /// No description provided for @searchFor.
  ///
  /// In en, this message translates to:
  /// **'Search for'**
  String get searchFor;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'waiting...'**
  String get waiting;

  /// No description provided for @returnResponse.
  ///
  /// In en, this message translates to:
  /// **'{response, select, packageInUse{Package in Use} packageInUseByApplication{Package in Use by Application} installInProgress{Install in Progress} fileInUse{File in Use} missingDependency{Missing Dependency} diskFull{Disk Full}  insufficientMemory{Insufficient Memory} invalidParameter{Invalid Parameter} noNetwork{No Network} contactSupport{Contact Support} rebootRequiredToFinish{Reboot Required to Finish} rebootRequiredForInstall{Reboot Required for Install} rebootInitiated{Reboot Initiated} cancelledByUser{Cancelled by User} alreadyInstalled{Already Installed} downgrade{Downgrade} blockedByPolicy{Blocked by Policy} systemNotSupported{System Not Supported} custom{Custom Response} other{NotFoundError}}'**
  String returnResponse(String response);

  /// No description provided for @copyToClipboardTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get copyToClipboardTooltip;

  /// No description provided for @openMSStorePageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open the Microsoft Store page for this app'**
  String get openMSStorePageTooltip;

  /// No description provided for @openHelpTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open help in a new page'**
  String get openHelpTooltip;

  /// No description provided for @viewLogDetailsTooltip.
  ///
  /// In en, this message translates to:
  /// **'View log details'**
  String get viewLogDetailsTooltip;

  /// No description provided for @moreFromPublisherTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show all Apps from this Publisher'**
  String get moreFromPublisherTooltip;

  /// No description provided for @packagePeekTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show app details'**
  String get packagePeekTooltip;

  /// No description provided for @runCommandTooltip.
  ///
  /// In en, this message translates to:
  /// **'Run command \'{command}\''**
  String runCommandTooltip(Object command);

  /// No description provided for @readOutputOfCommand.
  ///
  /// In en, this message translates to:
  /// **'Reading output of \'{command}\'...'**
  String readOutputOfCommand(Object command);

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @output.
  ///
  /// In en, this message translates to:
  /// **'Output'**
  String get output;

  /// No description provided for @parsingContent.
  ///
  /// In en, this message translates to:
  /// **'Parsing {content}...'**
  String parsingContent(Object content);

  /// No description provided for @apps.
  ///
  /// In en, this message translates to:
  /// **'Apps'**
  String get apps;

  /// No description provided for @checkingWingetAvailability.
  ///
  /// In en, this message translates to:
  /// **'Checking winget availability...'**
  String get checkingWingetAvailability;

  /// No description provided for @errorWingetNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Winget is not available\nPlease install the winget command line tool and restart the app.'**
  String get errorWingetNotAvailable;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @processesQueued.
  ///
  /// In en, this message translates to:
  /// **'{nrOfProcesses} processes are in queue for execution'**
  String processesQueued(Object nrOfProcesses);

  /// No description provided for @onlyAppsWithSourceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show only apps from a known package source'**
  String get onlyAppsWithSourceTooltip;

  /// No description provided for @onlyAppsWithExactVersionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show only apps with a known specific version'**
  String get onlyAppsWithExactVersionTooltip;

  /// No description provided for @actionOnAll.
  ///
  /// In en, this message translates to:
  /// **'{action} all'**
  String actionOnAll(Object action);

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
