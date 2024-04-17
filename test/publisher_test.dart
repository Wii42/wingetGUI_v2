import 'package:flutter_test/flutter_test.dart';
import 'package:winget_gui/package_infos/publisher.dart';

void main(){
  test('test publisher canonicalize', () {
    String string = 'Cap’n Proto';
    expect(Publisher.canonicalize(string), 'capnproto');
  });
}