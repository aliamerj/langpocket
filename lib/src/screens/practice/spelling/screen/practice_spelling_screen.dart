import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:langpocket/src/common_widgets/async_value_widget.dart';
import 'package:langpocket/src/common_widgets/responsive_center.dart';
import 'package:langpocket/src/common_widgets/views/image_view/image_view.dart';
import 'package:langpocket/src/common_widgets/views/word_view/word_view.dart';
import 'package:langpocket/src/common_widgets/custom_dialog_practice.dart';
import 'package:langpocket/src/screens/practice/spelling/app_bar/spelling_appbar.dart';
import 'package:langpocket/src/screens/practice/spelling/controller/spelling_word_controller.dart';
import 'package:langpocket/src/screens/practice/spelling/controller/spelling_controller.dart';
import 'package:langpocket/src/utils/constants/messages.dart';
import 'package:ionicons/ionicons.dart';
import 'package:langpocket/src/utils/routes/app_routes.dart';

class PracticeSpellingScreen extends ConsumerStatefulWidget {
  final int wordId;

  const PracticeSpellingScreen({
    super.key,
    required this.wordId,
  });

  @override
  ConsumerState<PracticeSpellingScreen> createState() =>
      PracticeSpellingScreenState();
}

class PracticeSpellingScreenState
    extends ConsumerState<PracticeSpellingScreen> {
  late TextEditingController inputController;
  late TextEditingController exampleInputController;
  bool readOnlyWord = false;
  bool readOnlyExample = false;
  late bool isDialogShowing;
  late SpellingController<SpellingStateBase> spellingController;

  @override
  void initState() {
    inputController = TextEditingController();
    exampleInputController = TextEditingController();
    isDialogShowing = false;
    spellingController =
        ref.read(spellingWordControllerProvider(widget.wordId).notifier);

    spellingController.setWordRecords();

    super.initState();
  }

  @override
  void dispose() {
    inputController.dispose();
    exampleInputController.dispose();

    super.dispose();
  }

  void setReadOnlyWord(({bool status, String text}) record) {
    readOnlyWord = record.status;
    record.status
        ? inputController.text = record.text
        : inputController.text = '';
  }

  void setReadOnlyExample(({bool status, String text}) record) {
    readOnlyExample = record.status;
    record.status
        ? exampleInputController.text = record.text
        : exampleInputController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    final spellingState =
        ref.watch(spellingWordControllerProvider(widget.wordId));

    final myMessage = MyMessages();
    final ThemeData(:textTheme, :colorScheme) = Theme.of(context);
    if (spellingState.hasValue) {
      final SpellingWordState(
        :activateExample,
        :wordRecord,
        :countSpelling,
        :examplePinter
      ) = spellingState.value!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        popUpDialogSingle(
            context,
            myMessage,
            wordRecord.foreignWord,
            wordRecord.wordExamples,
            countSpelling,
            activateExample,
            examplePinter,
            spellingController);
      });
      setStyleForCorrectness(spellingState.value!);
    }

    return ResponsiveCenter(
        child: Scaffold(
      appBar: spellingState.hasValue
          ? SpellingAppBar(
              spellingController: spellingController,
            )
          : null,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
          child: AsyncValueWidget(
            value: spellingState,
            child: (spellingWordState) {
              final WordRecord(
                :foreignWord,
                :wordImages,
                :wordExamples,
                :wordMeans
              ) = spellingWordState.wordRecord;
              final SpellingWordState(
                :countSpelling,
                :activateExample,
                :correctness,
                :examplePinter
              ) = spellingWordState;
              return Column(
                children: [
                  ImageView(imageList: wordImages),
                  const SizedBox(
                    height: 15,
                  ),
                  countSpelling > 3 || activateExample
                      ? WordView(
                          foreignWord: foreignWord,
                          means: wordMeans,
                          noVoiceIcon: true,
                        )
                      : Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          margin: const EdgeInsets.all(10),
                          child: const SizedBox(
                              width: double.infinity,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Icon(
                                  Ionicons.eye_off,
                                  size: 40,
                                ),
                              )),
                        ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            flex: 6,
                            child: TextField(
                              enableIMEPersonalizedLearning: false,
                              enableSuggestions: false,
                              autocorrect: false,
                              readOnly: readOnlyWord,
                              controller: inputController,
                              onChanged: (value) {
                                spellingController.comparingTexts(
                                    value, spellingWordState);
                              },
                              style: textTheme.headlineMedium
                                  ?.copyWith(color: colorScheme.outline),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: correctness || activateExample
                                    ? const Color.fromARGB(255, 104, 198, 107)
                                    : null,
                                labelStyle: textTheme.bodyLarge
                                    ?.copyWith(color: colorScheme.outline),
                                label: const Text('Write it down'),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2, color: colorScheme.onSurface),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              // The validator receives the text that the user has entered.
                            )),
                        Card(
                            elevation: 5,
                            margin: const EdgeInsets.all(10),
                            shape: const CircleBorder(),
                            color: Colors.indigo[400],
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: !activateExample
                                  ? Text(
                                      countSpelling.toString(),
                                      style: textTheme.labelLarge
                                          ?.copyWith(color: Colors.white),
                                    )
                                  : Text(
                                      0.toString(),
                                      style: textTheme.labelLarge
                                          ?.copyWith(color: Colors.white),
                                    ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  activateExample
                      ? Column(children: [
                          countSpelling < 2
                              ? Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  margin: const EdgeInsets.all(10),
                                  child: const SizedBox(
                                      width: double.infinity,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 10),
                                        child: Icon(
                                          Ionicons.eye_off,
                                          size: 40,
                                        ),
                                      )),
                                )
                              : Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  margin: const EdgeInsets.all(10),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 5),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            wordExamples[examplePinter],
                                            style: textTheme.headlineLarge
                                                ?.copyWith(
                                                    color: colorScheme.outline),
                                            softWrap: true,
                                            maxLines: 3,
                                            overflow: TextOverflow.fade,
                                          ),
                                        ]),
                                  ),
                                ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    flex: 6,
                                    child: TextField(
                                      enableSuggestions: false,
                                      autocorrect: false,
                                      readOnly: readOnlyExample,
                                      controller: exampleInputController,
                                      onChanged: (value) =>
                                          spellingController.comparingTexts(
                                              value, spellingWordState),
                                      style: textTheme.headlineMedium?.copyWith(
                                          color: colorScheme.outline),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: correctness
                                            ? const Color.fromARGB(
                                                255, 104, 198, 107)
                                            : null,
                                        labelStyle: textTheme.bodyMedium
                                            ?.copyWith(
                                                color: colorScheme.onSurface),
                                        label: const Text('Write it down'),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 2,
                                              color: colorScheme.onSurface),
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                      ),
                                      // The validator receives the text that the user has entered.
                                    )),
                                Card(
                                    elevation: 5,
                                    margin: const EdgeInsets.all(10),
                                    shape: const CircleBorder(),
                                    color: Colors.indigo[400],
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Text(
                                        countSpelling.toString(),
                                        style: textTheme.labelLarge
                                            ?.copyWith(color: Colors.white),
                                      ),
                                    )),
                              ],
                            ),
                          )
                        ])
                      : Container()
                ],
              );
            },
          ),
        ),
      ),
    ));
  }

  void setStyleForCorrectness(SpellingWordState spellingWordState) {
    final SpellingWordState(
      :wordRecord,
      :activateExample,
      :correctness,
      :examplePinter
    ) = spellingWordState;
    if (mounted) {
      // the open case for word ok

      if (!activateExample && correctness) {
        setReadOnlyWord((status: true, text: wordRecord.foreignWord));

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            spellingController.setCorrectness(false);
            setReadOnlyWord((status: false, text: ''));
          }
        });
      } else if (activateExample &&
          wordRecord.foreignWord != inputController.text) {
        setReadOnlyWord((status: true, text: wordRecord.foreignWord));
      }
      if (activateExample && correctness) {
        setReadOnlyExample(
            (status: true, text: wordRecord.wordExamples[examplePinter]));

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            spellingController.setCorrectness(false);
            setReadOnlyExample((status: false, text: ''));
          }
        });
      }
      // // the close case for word
      // if (inputController.text != wordRecord.foreignWord && activateExample ||
      //     correctness) {

      // } else if (!correctness) {
      //   setReadOnlyWord((status: false, text: ''));
      // }

      // Future.delayed(const Duration(seconds: 2), () {
      //   if (mounted && correctness) {
      //     spellingController.resetTextFieldsAfterDelay(
      //         setReadOnlyWord, setReadOnlyExample, spellingWordState);
      //   }
      // });

      // spellingController.updateTextFields(
      //     setReadOnlyWord, setReadOnlyExample, spellingWordState);
    }
  }

  void popUpDialogSingle(
    BuildContext context,
    MyMessages myMessage,
    String foreignWord,
    List<String> examplesList,
    int countSpelling,
    bool activateExample,
    int pointer,
    SpellingController<SpellingStateBase> spellingController,
  ) {
    if (!isDialogShowing) {
      if (countSpelling == 0 && !activateExample) {
        isDialogShowing = true;

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return CustomDialogPractice(
                messages: myMessage.getPracticeMessage(
                  PracticeMessagesType.practiceSpelling,
                  foreignWord,
                ),
                reload: spellingController.startOver,
                activateExamples: spellingController.exampleActivation,
              );
            }).then((value) => isDialogShowing = false);
      } else if (countSpelling == 0 && activateExample) {
        if (pointer < examplesList.length - 1) {
          spellingController.moveToNextExamples(pointer);
        } else {
          isDialogShowing = true;
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return CustomDialogPractice(
                  messages: myMessage.getPracticeMessage(
                    PracticeMessagesType.practiceSpellingExampleComplete,
                    foreignWord,
                  ),
                  reload: spellingController.startOver,
                  activateExamples: spellingController.exampleActivation,
                );
              }).then((value) {
            setReadOnlyExample((status: false, text: ''));
            setReadOnlyWord((status: false, text: ''));
            return isDialogShowing = false;
          });
        }
      }
    }
  }

  // void popUpDialogGroup(BuildContext context, MyMessages myMessage,
  //     String foreignWord, List<String> examplesList) {
  //   if (!isDialogShowing) {
  //     if (countSpelling == 0) {
  //       if (activateExample && pointer < examplesList.length - 1) {
  //         spellingController.moveToNextExamples();
  //       } else if (!activateExample) {
  //         isDialogShowing = true;
  //         showDialog(
  //           context: context,
  //           barrierDismissible: false,
  //           builder: (BuildContext context) {
  //             return CustomDialogPractice(
  //               messages: myMessage.getPracticeMessage(
  //                 PracticeMessagesType.practiceSpellingGroup,
  //                 foreignWord,
  //               ),
  //               reload: spellingController.isThereNextWord
  //                   ? spellingController.moveToNextWord
  //                   : null,
  //               activateExamples: spellingController.examplesActivation,
  //             );
  //           },
  //         ).then((value) => isDialogShowing = false);
  //       } else if (countSpelling == 0 &&
  //           activateExample &&
  //           spellingController.isThereNextWord) {
  //         spellingController.moveToNextWord();
  //         return;
  //       } else if (countSpelling == 0 && activateExample) {
  //         isDialogShowing = true;
  //         showDialog(
  //           context: context,
  //           barrierDismissible: false,
  //           builder: (BuildContext context) {
  //             return CustomDialogPractice(
  //               messages: myMessage.getPracticeMessage(
  //                 PracticeMessagesType.practiceSpellingExampleCompleteGroup,
  //                 foreignWord,
  //               ),
  //               reload: spellingController.resetting,
  //               activateExamples: spellingController.examplesActivation,
  //             );
  //           },
  //         ).then((value) => isDialogShowing = false);
  //       }
  //     }
  //   }
  // }
}
