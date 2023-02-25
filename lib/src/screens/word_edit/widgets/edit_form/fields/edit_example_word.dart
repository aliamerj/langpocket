import 'package:flutter/material.dart';
import 'package:langpocket/src/screens/word_edit/screen/edit_mode_word_screen.dart';
import 'package:langpocket/src/utils/constants/breakpoints.dart';

class EditExampleWord extends StatefulWidget {
  final List<String> currentExamples;
  const EditExampleWord({super.key, required this.currentExamples});

  @override
  State<EditExampleWord> createState() => _EditExampleWordState();
}

class _EditExampleWordState extends State<EditExampleWord> {
  late List<TextEditingController> exampleControllers;
  @override
  void initState() {
    exampleControllers = [
      ...widget.currentExamples
          .map((text) => TextEditingController(text: text))
          .toList()
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final states = context.findAncestorStateOfType<EditModeWordScreenState>()!;

    return Column(children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 7),
          child: Text(
            '+ Add examples',
            style: headline2Bold(primaryFontColor),
          ),
        ),
      ),
      for (int i = 0; i < exampleControllers.length; i++)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: TextFormField(
            onChanged: (value) {
              states.updateWordExample(value, i);
            },
            controller: exampleControllers[i],
            style: headline3(primaryFontColor),
            decoration: InputDecoration(
              suffixIcon: i > 1
                  ? TextButton(
                      onPressed: () {
                        exampleControllers[i].clear();
                        states.updateWordExample('', i);
                        setState(() {
                          exampleControllers.removeAt(i);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Icon(
                          Icons.close_outlined,
                          color: primaryColor,
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Icon(
                        Icons.language_outlined,
                        color: primaryColor,
                      ),
                    ),
              labelStyle: bodyLarge(primaryColor),
              label: Text('example ${i + 1}'),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: secondaryColor),
                borderRadius: BorderRadius.circular(20.0),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            // The validator receives the text that the user has entered.
            validator: i < 2
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter one meaning for this word';
                    } else {
                      states.updateWordExample(value, i);
                    }
                    return null;
                  }
                : ((value) {
                    if (value != null) {
                      states.updateWordExample(value, i);
                    }
                    return null;
                  }),
          ),
        ),
      if (exampleControllers.length < 5)
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: buttonColor,
            shape: const CircleBorder(),
          ),
          onPressed: () {
            setState(() {
              exampleControllers.add(TextEditingController(text: ''));
            });
          },
          child: const Icon(
            Icons.add,
            size: 50,
            color: Colors.white,
          ),
        ),
    ]);
  }
}