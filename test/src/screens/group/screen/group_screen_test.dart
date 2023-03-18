import 'package:flutter_test/flutter_test.dart';

import '../group_robot.dart';

void main() {
  group('existing', () {
    testWidgets('group screen has all necessary widgets', (tester) async {
      final r = GroupRobot(tester, 1);
      await tester.runAsync(() async {
        await r.pumpGroupScreen();
        r.hasGroupNameAndData();
        r.hasOnleyRelatedWord();
      });
    });
  });
  // group('Actions', () {
  //   testWidgets('Nav to the word screen when clicking on the word',
  //       (tester) async {
  //     final r = GroupRobot(tester, 1);
  //     await tester.runAsync(() async {
  //       await r.pumpGroupScreen();
  //       await r.navToWordScreen();
  //     });
  //   });
  //   testWidgets('remove the word when swiping to right', (tester) async {
  //     final r = GroupRobot(tester, 1);
  //     await tester.runAsync(() async {
  //       await r.pumpGroupScreen();
  //      // await r.navToWordScreen();
  //     });
  //   });
  // });
}