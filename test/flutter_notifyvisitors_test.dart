import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_notifyvisitors/flutter_notifyvisitors.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_notifyvisitors');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterNotifyvisitors.platformVersion, '42');
  });
}
