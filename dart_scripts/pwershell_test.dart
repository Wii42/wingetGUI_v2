import 'dart:io';

void main()async{
  ProcessResult p = await Process.run('powershell', ['Get-AppxPackage']);
  print(p.stdout);

}