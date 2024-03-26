import 'dart:io';

void main() async {
  ProcessResult p = await Process.run('powershell', ['Get-AppxPackage']);
  print(p.stdout);
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
