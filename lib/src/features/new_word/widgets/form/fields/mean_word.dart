import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:langpocket/src/common_widgets/custom_text_form_field.dart';
import 'package:langpocket/src/features/new_word/controller/new_word_controller.dart';
import 'package:langpocket/src/features/new_word/controller/validation_input.dart';
import 'package:langpocket/src/utils/constants/breakpoints.dart';

class MeanWord extends ConsumerStatefulWidget {
  final List<String>? wordMeans;
  const MeanWord({Key? key, this.wordMeans}) : super(key: key);

  @override
  ConsumerState<MeanWord> createState() => _MeanWordState();
}

class _MeanWordState extends ConsumerState<MeanWord> {
  List<TextEditingController> meaningControllers = [TextEditingController()];

  @override
  void initState() {
    if (widget.wordMeans != null) {
      meaningControllers = [];
      int index = 0;
      widget.wordMeans?.map((mean) {
        meaningControllers.add(TextEditingController(text: mean));
        Future.delayed(Duration.zero, () {
          ref
              .read(newWordControllerProvider.notifier)
              .saveWordMeans(mean, index);
          index += 1;
        });
      }).toList();
    }
    super.initState();
  }

  void addMeaning() {
    setState(() {
      meaningControllers.add(TextEditingController());
    });
  }

  void removeMeaning(int index) {
    ref.read(newWordControllerProvider.notifier).saveWordMeans('', index);

    setState(() {
      meaningControllers[index].clear();
      meaningControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      for (int i = 0; i < meaningControllers.length; i++)
        MeaningInputField(
          isUpdating: widget.wordMeans != null,
          controller: meaningControllers[i],
          index: i,
          removeMeaning: removeMeaning,
        ),
      if (meaningControllers.length < 3)
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            shape: const CircleBorder(),
          ),
          onPressed: addMeaning,
          child: const Icon(
            Icons.add,
            size: 45,
            color: Colors.white,
          ),
        ),
    ]);
  }

  @override
  void dispose() {
    for (var controller in meaningControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

class MeaningInputField extends ConsumerWidget {
  final bool isUpdating;
  final TextEditingController controller;
  final int index;
  final Function(int) removeMeaning;

  const MeaningInputField({
    super.key,
    required this.isUpdating,
    required this.controller,
    required this.index,
    required this.removeMeaning,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final validate = ValidationInput();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 2),
      child: Consumer(builder: (context, watch, _) {
        final newWordController = ref.read(newWordControllerProvider.notifier);

        return CustomTextField(
          key: Key('MeanWord$index'),
          controller: controller,
          onChanged: (value) {
            if (isUpdating) {
              newWordController.saveWordMeans(value, index);
            }
          },
          style: headline3(primaryFontColor),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            suffixIcon: index > 0
                ? TextButton(
                    onPressed: () => removeMeaning(index),
                    child: Icon(
                      Icons.close_outlined,
                      color: primaryColor,
                    ),
                  )
                : Icon(
                    Icons.language_outlined,
                    color: primaryColor,
                  ),
            labelStyle: bodyLarge(primaryColor),
            label: const Text('Mean'),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 2, color: secondaryColor),
              borderRadius: BorderRadius.circular(20.0),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          validator: (value) {
            final (:status, :message) =
                validate.meaningWordsValidation([value ?? '']);
            if (!status) {
              return message;
            } else {
              newWordController.saveWordMeans(value!, index);
            }
            return null;
          },
        );
      }),
    );
  }
}
