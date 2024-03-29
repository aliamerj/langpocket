import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:langpocket/src/data/modules/extensions.dart';
import 'package:langpocket/src/data/modules/word_module.dart';
import 'package:langpocket/src/data/services/word_service.dart';
import 'package:langpocket/src/features/practice/pronunciation/controllers/mic_controller.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

const bool _activateExampleState = false;
const int _examplePinter = 0;
final micSingleControllerProvider = StateNotifierProvider.autoDispose<
    MicSingleController, AsyncValue<MicWordState>>((ref) {
  final services = ref.watch(wordsServicesProvider);
  return MicSingleController(services);
});

class MicSingleController extends StateNotifier<AsyncValue<MicWordState>>
    implements MicController {
  WordServices services;

  MicSingleController(this.services) : super(const AsyncValue.loading());
  int _countPron = 3;
  int _countExampleMic = 2;
  final speechToText = SpeechToText();
  String exampleMessage = 'Try to Pronounce the following sentence ';
  String initialMess = 'Hold to Start Recording ...';
  @override
  void setWordRecords({
    int? countPron,
    int? countExamplePron,
    String? exampleActivationMessage,
    required String initialMessage,
    required int id,
  }) async {
    state = const AsyncLoading();

    final word = await services.fetchWordById(id);

    _countExampleMic = countExamplePron ?? _countExampleMic;
    _countPron = countPron ?? _countPron;

    state = AsyncValue.data(MicWordState(
        isAnalyzing: false,
        wordRecord: word.decoding(),
        countPron: _countPron,
        activateExample: _activateExampleState,
        examplePinter: _examplePinter,
        micMessage: initialMessage));
  }

  @override
  void startRecording() async {
    if (speechToText.isNotListening && mounted) {
      await speechToText.listen(onResult: (speech) {
        if (mounted) {
          _resultListener(speech);
        }
      });
    }
    Future.delayed(const Duration(seconds: 5), () {
      if (speechToText.isListening && mounted) {
        speechToText.stop();
      }
    });
  }

  @override
  void stopRecording() async {
    if (speechToText.isListening) {
      await Future.delayed(
          const Duration(seconds: 2), () => speechToText.stop());
    }
  }

  @override
  void startOver() {
    state = state.whenData((word) => word.copyWith(
        isAnalyzing: false,
        countPron: _countPron,
        micMessage: initialMess,
        activateExample: _activateExampleState,
        examplePinter: _examplePinter));
  }

  @override
  void exampleActivation() {
    state = state.whenData((word) => word.copyWith(
        activateExample: true,
        isAnalyzing: false,
        examplePinter: _examplePinter,
        countPron: _countExampleMic,
        micMessage: exampleMessage));
  }

  @override
  void moveToNextExamples(int examplePinter) {
    state = state.whenData((word) => word.copyWith(
        isAnalyzing: false,
        countPron: _countExampleMic,
        examplePinter: examplePinter + 1,
        micMessage: exampleMessage));
  }

  /// * `listening` when speech recognition begins after calling the [listen]
  /// method.
  /// * `notListening` when speech recognition is no longer listening to the
  /// microphone after a timeout, [cancel] or [stop] call.
  /// * `done` when all results have been delivered.
  bool noVoice = true;
  @override
  void statusListener(String status) {
    if (status == 'listening') {
      if (mounted) {
        noVoice = true;
        state = state.whenData((pron) =>
            pron.copyWith(micMessage: "listening...", isAnalyzing: false));

        return;
      }
    }
    if (status == 'notListening') {
      if (mounted) {
        state = state.whenData((pron) => pron.copyWith(
            micMessage: "Analyzing your pronunciation...", isAnalyzing: true));
        return;
      }
    }
    if (status == 'done' && noVoice) {
      if (mounted) {
        state = state.whenData((pron) => pron.copyWith(
            micMessage: "No voice detected. Please try again.",
            isAnalyzing: false));
        return;
      }
    }
  }

  @override
  void errorListener(String errorMsg) {
    if (errorMsg == 'error_no_match') {
      state = state.whenData((pron) => pron.copyWith(
          micMessage: "No voice detected. Please try again.",
          isAnalyzing: false));
    } else {
      state = AsyncError(errorMsg, StackTrace.current);
    }
  }

  void _resultListener(SpeechRecognitionResult result) {
    noVoice = false;
    if (state.hasValue && result.finalResult) {
      if (state.value!.activateExample) {
        _comparingWords(result.recognizedWords,
            state.value!.wordRecord.wordExamples[state.value!.examplePinter]);
      } else {
        _comparingWords(
            result.recognizedWords, state.value!.wordRecord.foreignWord);
      }
    }
  }

  void _comparingWords(String recognizedText, String originText) {
    if (state.value!.countPron > 0) {
      if (recognizedText.toLowerCase().trim() ==
          originText.toLowerCase().trim()) {
        state = state.whenData((pron) => pron.copyWith(
            countPron: state.value!.countPron - 1,
            micMessage: "Great job! You got it right.",
            isAnalyzing: false));
      } else {
        if (recognizedText.isNotEmpty) {
          state = state.whenData((value) => value.copyWith(
              isAnalyzing: false,
              micMessage:
                  "Oops! \"$recognizedText\" doesn't match. Try again."));
        }
      }
    }
  }

  @override
  void moveToNextWord() {
    throw UnimplementedError();
  }

  @override
  get isThereNextWord => throw UnimplementedError();
}

class MicWordState implements MicStateBase {
  final WordRecord wordRecord;
  @override
  final int countPron;
  @override
  final bool activateExample;
  @override
  final int examplePinter;
  @override
  final String micMessage;
  @override
  final bool isAnalyzing;

  MicWordState(
      {required this.countPron,
      required this.wordRecord,
      required this.activateExample,
      required this.examplePinter,
      required this.isAnalyzing,
      required this.micMessage});

  @override
  MicWordState copyWith(
      {WordRecord? wordRecord,
      int? countPron,
      bool? activateExample,
      int? examplePinter,
      bool? isAnalyzing,
      String? micMessage}) {
    return MicWordState(
        wordRecord: wordRecord ?? this.wordRecord,
        countPron: countPron ?? this.countPron,
        activateExample: activateExample ?? this.activateExample,
        examplePinter: examplePinter ?? this.examplePinter,
        isAnalyzing: isAnalyzing ?? this.isAnalyzing,
        micMessage: micMessage ?? this.micMessage);
  }
}
