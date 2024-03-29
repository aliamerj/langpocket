import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:langpocket/src/data/local/repository/drift_group_repository.dart';
import 'package:langpocket/src/data/local/repository/local_group_repository.dart';
import 'package:langpocket/src/features/group/screen/group_screen.dart';
import 'package:langpocket/src/features/new_word/screen/new_word_screen.dart';
import 'package:langpocket/src/utils/routes/app_routes.dart';

class HomeRobot {
  final WidgetTester tester;
  HomeRobot(this.tester);
  Future<void> pumpHomeScreen([DriftGroupRepository? db]) async {
    final goRouter = GoRouter(routes: appRouting); // Define your GoRouter here

    if (db != null) {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          localGroupRepositoryProvider.overrideWithValue(db),
          goRouterProvider.overrideWithValue(goRouter)
        ],
        child: MaterialApp.router(
          routerDelegate: goRouter.routerDelegate,
          routeInformationParser: goRouter.routeInformationParser,
        ),
      ));
    } else {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerDelegate: goRouter.routerDelegate,
            routeInformationParser: goRouter.routeInformationParser,
          ),
        ),
      );
    }
    await tester.pump();
  }

  void hasIconNewWord() {
    final icon = find.byIcon(Icons.add);
    expect(icon, findsOneWidget);
  }

  void hasGroupTitle() {
    final title = find.text('Groups');
    expect(title, findsOneWidget);
  }

  void hasTodoButton() async {
    final btn = find.text('Todo');

    expect(btn, findsWidgets);
  }

  void hasNoGroup() async {
    final message = find.text('You don\'t have any group yet');
    expect(message, findsOneWidget);
  }

  void hasAllGroups(List<GroupData> groupList) {
    for (var group in groupList) {
      expect(find.text(group.groupName), findsOneWidget);
      expect(
          find.text(
              'Date: ${group.creatingTime.day}/${group.creatingTime.month}/${group.creatingTime.year}'),
          findsOneWidget);
    }
  }

  void hasAllWordsInGroups(int groupId, List<WordData> words) {
    for (var word in words) {
      expect(word.id, groupId);
      expect(find.text(word.foreignWord), findsOneWidget);
    }
  }

  void failedLoadingWords(String errorMessage) {
    expect(find.text(errorMessage), findsWidgets);
  }

  void failedLoadingGroups(String errorMessage) {
    expect(find.text(errorMessage), findsOneWidget);
  }

// actions
  Future<void> navToAddNewWord() async {
    final icon = find.byIcon(Icons.add);
    expect(icon, findsWidgets);
    await tester.tap(icon);
    await tester.pumpAndSettle();
    final newWordScreen = find.byType(NewWordScreen);
    expect(newWordScreen, findsOneWidget);
  }

  Future<void> navToGroupScreenByGivingId(int id) async {
    final firstGroup = find.byKey(Key('group-$id'));
    expect(firstGroup, findsOneWidget);
    await tester.tap(firstGroup);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    final groupscreen = find.byType(GroupScreen);
    expect(groupscreen, findsOneWidget);
  }
}
