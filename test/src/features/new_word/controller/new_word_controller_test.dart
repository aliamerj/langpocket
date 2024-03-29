import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langpocket/src/data/local/repository/drift_group_repository.dart';
import 'package:langpocket/src/data/modules/word_module.dart';
import 'package:langpocket/src/data/services/word_service.dart';
import 'package:langpocket/src/features/new_word/controller/new_word_controller.dart';
import 'package:mocktail/mocktail.dart';

//! 1- the initial state should be object with empty props
//! 2- saveNewWord =>
//!  2.1= validate all the values
//!  2.2= start with set state to login
//!  2.3= _checkTodayGroup and attached with correct group
//!  2.4= save the word in database
//!  2.5= clean the state

class MockWordServices extends Mock implements WordServices {}

class WordCompanionFake extends Fake implements WordCompanion {}

class GroupCompanionFake extends Fake implements GroupCompanion {}

void main() {
  late NewWordController controller;
  late MockWordServices mockWordServices;
  setUpAll(() {
    registerFallbackValue(WordCompanionFake());
    registerFallbackValue(GroupCompanionFake());
  });
  setUp(() {
    // Create the mock instance
    mockWordServices = MockWordServices();
    // Create the controller with the mock instance
    controller = NewWordController(wordsServices: mockWordServices);
  });
  tearDown(() {
    controller.dispose(); // Assuming NewWordController has a dispose method
  });

  var initialWord = WordRecord(
      foreignWord: '',
      wordMeans: List.filled(3, ''),
      wordImages: [],
      wordExamples: List.filled(5, ''),
      wordNote: '');

  group('NewWordController', () {
    test('initial state should be object with empty props  ', () {
      // Compare the actual initial state to the expected state
      expect(
          controller.debugState.toString(), AsyncData(initialWord).toString());
    });
  });

  group('save each value in state separately', () {
    test('save foreignWord in sate', () {
      // check before saving
      expect(
          controller.debugState.toString(), AsyncData(initialWord).toString());
      // save
      controller.saveForeignWord('test');
      expect(controller.debugState.value!.foreignWord, 'test');
    });
    test('save wordMeans in state', () {
      // check before saving
      expect(
          controller.debugState.toString(), AsyncData(initialWord).toString());
      //test
      controller.saveWordMeans('firstMeaning', 1);
      expect(controller.debugState.value!.wordMeans[1], 'firstMeaning');
    });
    test('save Examples', () {
      // check before saving
      expect(
        controller.debugState.toString(),
        AsyncData(initialWord).toString(),
      );
      // test
      controller.saveWordExample('this is example for test', 0);
      expect(controller.debugState.value!.wordExamples[0],
          'this is example for test');
    });
    test('save notes', () {
      // check before saving
      expect(
        controller.debugState.toString(),
        AsyncData(initialWord).toString(),
      );
      // test
      controller.saveWordNote('this is notes for test only');
      expect(
          controller.debugState.value!.wordNote, 'this is notes for test only');
    });
  });

  group('save all in one go', () {
    test('adding to existing group, with changing state ', () async {
      var word = WordRecord(
          foreignWord: 'test',
          wordMeans: ['mean1', 'mean2', ''],
          wordImages: [],
          wordExamples: ['example1', 'example2', '', '', ''],
          wordNote: '');
      // set up
      controller.saveForeignWord(word.foreignWord);
      controller.saveWordMeans(word.wordMeans[0], 0);
      controller.saveWordMeans(word.wordMeans[1], 1);
      controller.saveWordExample(word.wordExamples[0], 0);
      controller.saveWordExample(word.wordExamples[1], 1);

      // set up saving
      final now = DateTime.now();
      final group = GroupData(
          synced: false,
          level: 1,
          id: 1,
          groupName: 'test',
          creatingTime: now,
          studyTime: now);
      when(() => mockWordServices.fetchGroupByTime(now))
          .thenAnswer((_) => Future.value(group));
      when(() => mockWordServices.addNewWordInGroup(any()))
          .thenAnswer((_) => Future.value(null));

      expectLater(
          controller.stream,
          emitsInOrder([
            const AsyncLoading<WordRecord>(),
            predicate<AsyncData<WordRecord>>((word) {
              expect(word.value.foreignWord, initialWord.foreignWord);
              expect(word.value.wordMeans, initialWord.wordMeans);
              expect(word.value.wordExamples, initialWord.wordExamples);
              expect(word.value.wordImages, initialWord.wordImages);

              return true;
            })
          ]));
      // call the function
      await controller.saveNewWord(now);
      // add a delay to allow the state to update
    });
    test('adding word in new group , with changing state ', () async {
      var word = WordRecord(
          foreignWord: 'test',
          wordMeans: ['mean1', 'mean2', ''],
          wordImages: [],
          wordExamples: ['example1', 'example2', '', '', ''],
          wordNote: '');
      // set up
      controller.saveForeignWord(word.foreignWord);
      controller.saveWordMeans(word.wordMeans[0], 0);
      controller.saveWordMeans(word.wordMeans[1], 1);
      controller.saveWordExample(word.wordExamples[0], 0);
      controller.saveWordExample(word.wordExamples[1], 1);

      // set up saving
      final now = DateTime.now();
      final group = GroupData(
          synced: false,
          level: 1,
          id: 1,
          groupName: 'test',
          creatingTime: now,
          studyTime: now);

      when(() => mockWordServices.createGroup(any()))
          .thenAnswer((_) => Future.value(group));
      when(() => mockWordServices.addNewWordInGroup(any()))
          .thenAnswer((_) => Future.value(null));

      expectLater(
          controller.stream,
          emitsInOrder([
            const AsyncLoading<WordRecord>(),
            predicate<AsyncData<WordRecord>>((word) {
              expect(word.value.foreignWord, initialWord.foreignWord);
              expect(word.value.wordMeans, initialWord.wordMeans);
              expect(word.value.wordExamples, initialWord.wordExamples);
              expect(word.value.wordImages, initialWord.wordImages);

              return true;
            })
          ]));
      // call the function
      await controller.saveNewWord(now);
    });
  });

  group('save with invalid value', () {
    test('Foreign Word is invalid', () async {
      final now = DateTime.now();
      var word = WordRecord(
          foreignWord: '',
          wordMeans: ['mean1', 'mean2', ''],
          wordImages: [],
          wordExamples: ['example1', 'example2', '', '', ''],
          wordNote: '');
      // set up
      controller.saveForeignWord(word.foreignWord);
      controller.saveWordMeans(word.wordMeans[0], 0);
      controller.saveWordMeans(word.wordMeans[1], 1);
      controller.saveWordExample(word.wordExamples[0], 0);
      controller.saveWordExample(word.wordExamples[1], 1);

      await controller.saveNewWord(now);

      expect(controller.debugState.hasError, true);
    });
    test('Means Word is invalid', () async {
      final now = DateTime.now();
      var word = WordRecord(
          foreignWord: 'test',
          wordMeans: [],
          wordImages: [],
          wordExamples: ['example1', 'example2', '', '', ''],
          wordNote: '');
      // set up
      controller.saveForeignWord(word.foreignWord);
      controller.saveWordExample(word.wordExamples[0], 0);
      controller.saveWordExample(word.wordExamples[1], 1);

      await controller.saveNewWord(now);

      expect(controller.debugState.hasError, true);
    });
    test('Example Word is invalid', () async {
      final now = DateTime.now();
      var word = WordRecord(
          foreignWord: 'test',
          wordMeans: ['mean1', 'mean2', ''],
          wordImages: [],
          wordExamples: ['', '', '', '', ''],
          wordNote: '');
      // set up
      controller.saveForeignWord(word.foreignWord);
      controller.saveWordExample(word.wordExamples[0], 0);
      controller.saveWordExample(word.wordExamples[1], 1);

      await controller.saveNewWord(now);

      expect(controller.debugState.hasError, true);
    });
    test('note Word is invalid', () async {
      final now = DateTime.now();
      var word = WordRecord(
          foreignWord: 'test',
          wordMeans: ['mean1', 'mean2', ''],
          wordImages: [],
          wordExamples: ['tes', 'tes', 'dfs', '', ''],
          wordNote:
              'Officia irure laborum laborum sit id duis sunt ullamco. Qui ea officia tempor qui veniam aliqua aliquip magna eu culpa ex duis Lorem. Occaecat officia est do reprehenderit.Commodo ullamco est dolore anim. Duis ea Lorem cillum ullamco mollit occaecat veniam laborum est. Reprehenderit anim aliquip anim aliquip enim non mollit dolore nulla amet. Elit do cupidatat dolore ullamco ullamco velit aliquip adipisicing dolor eiusmod pariatur. Eu ut exercitation elit do elit nulla non ullamco adipisicing Lorem occaecat elit.');
      // set up
      controller.saveForeignWord(word.foreignWord);
      controller.saveWordExample(word.wordExamples[0], 0);
      controller.saveWordExample(word.wordExamples[1], 1);

      await controller.saveNewWord(now);

      expect(controller.debugState.hasError, true);
    });
  });
}
