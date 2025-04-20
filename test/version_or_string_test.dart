import 'package:flutter_test/flutter_test.dart';
import 'package:winget_core/winget_core.dart';

void main(){
  test('parse', () { VersionOrString vos = VersionOrString.parse('1.0.0');
  expect(vos.stringVersion, null);});

  test('compare', ()
  {
    VersionOrString vos = VersionOrString.parse('>1.0.0');
    VersionOrString vos2 = VersionOrString.parse('2.0.0');
    expect(vos.version!.compareTo(vos2.version!), -1);
  });
}