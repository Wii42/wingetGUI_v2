# winget_gui

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## TO-DO:
- handle emails properly
- fix to many links found in expandable text

- fix sources page
- weird bux with Canon PCL6 Driver
- fix correct dbtables are reloaded on package action

## How to sef sign the MSIX installer of the app

1. Create a self-signed certificate and add it to "Local Machine Trusted People".
   See https://learn.microsoft.com/en-us/windows/msix/package/create-certificate-package-signing#use-new-selfsignedcertificate-to-create-a-certificate for reference.
2. Set the path to the .pfx file created in step 1 and the password to the msix config in the pubspec.yaml file, see https://pub.dev/packages/msix#-signing-options for reference.
3. Run `dart run msix:create` to create the msix package.




