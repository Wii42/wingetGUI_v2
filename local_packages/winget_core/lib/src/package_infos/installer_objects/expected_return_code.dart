

import 'package:winget_core/src/package_localizer.dart';

class ExpectedReturnCode {
  final ReturnResponse response;
  final int? returnCode;
  final Uri? returnResponseUrl;

  ExpectedReturnCode(
      {this.response = ReturnResponse.custom,
      this.returnCode,
      this.returnResponseUrl});

  factory ExpectedReturnCode.fromMap(dynamic json) {
    String? uri = json['ReturnResponseUrl'];
    return ExpectedReturnCode(
      response: ReturnResponse.fromString(json['ReturnResponse']),
      returnCode: json['InstallerReturnCode'],
      returnResponseUrl: uri != null ? Uri.parse(uri) : null,
    );
  }
}

enum ReturnResponse {
  packageInUse,
  packageInUseByApplication,
  installInProgress,
  fileInUse,
  missingDependency,
  diskFull,
  insufficientMemory,
  invalidParameter,
  noNetwork,
  contactSupport,
  rebootRequiredToFinish,
  rebootRequiredForInstall,
  rebootInitiated,
  cancelledByUser,
  alreadyInstalled,
  downgrade,
  blockedByPolicy,
  systemNotSupported,
  custom;

  String title(PackageLocalizer locale) {
    String title = locale.returnResponse(name);
    if (title == "NotFoundError") {
      return name;
    }
    return title;
  }

  factory ReturnResponse.fromString(String string) {
    return ReturnResponse.values
        .firstWhere((element) => element.name == string, orElse: () => custom);
  }
}
