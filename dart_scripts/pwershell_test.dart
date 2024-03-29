import 'dart:io';

import 'package:winget_gui/helpers/log_stream.dart';

void main() async {
  Logger log = Logger('Powershell Test');
  ProcessResult p = await Process.run('powershell', ['Get-AppxPackage']);
  log.info(p.stdout);
}

class AddressBook {
  final String name;
  final String email;
  final PhoneNumber phone;

  const AddressBook({
    required this.name,
    required this.email,
    required this.phone,
  });
}

class AddressBookBuilder {
  String? name;
  String? email;
  PhoneNumber? phone;

  AddressBookBuilder();
  AddressBook build() {
    return AddressBook(
      name: name!,
      email: email!,
      phone: phone!,
    );
  }
}

class PhoneNumber {
  final String number;
  final String label;
  const PhoneNumber({
    required this.number,
    required this.label,
  });
}

class PhoneNumberBuilder {
  String? number;
  String? label;
  PhoneNumberBuilder();
  PhoneNumber build() {
    return PhoneNumber(
      number: number!,
      label: label!,
    );
  }
}
