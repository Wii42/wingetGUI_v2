import 'package:flutter_test/flutter_test.dart';
import 'package:winget_core/winget_core.dart';

void main(){
  test('test publisher canonicalize', () {
    String string = 'Cap’n Proto';
    expect(Publisher.canonicalize(string), 'capnproto');
  });
}