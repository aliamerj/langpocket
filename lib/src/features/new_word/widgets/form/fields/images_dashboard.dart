import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:langpocket/src/common_widgets/async_value_widget.dart';
import 'package:langpocket/src/features/new_word/controller/new_word_controller.dart';

class ImagesDashboard extends ConsumerStatefulWidget {
  final List<String>? currentImg;

  const ImagesDashboard({Key? key, this.currentImg}) : super(key: key);

  @override
  ConsumerState<ImagesDashboard> createState() => _ImagePreviewerState();
}

class _ImagePreviewerState extends ConsumerState<ImagesDashboard> {
  late List<String> wordImages;

  @override
  void initState() {
    if (widget.currentImg != null) {
      wordImages = widget.currentImg!;
      wordImages.map((img) {
        Future.delayed(Duration.zero, () {
          ref.read(newWordControllerProvider.notifier).saveWordImage(img);
        });
      }).toList();
    } else {
      wordImages = [];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AsyncValueWidget(
      value: ref.watch(newWordControllerProvider),
      child: (word) {
        final wordImages = word.wordImages;
        return Column(
          children: [
            if (wordImages.isNotEmpty)
              ImageListView(
                wordImages: wordImages,
                removeImage: (index) => ref
                    .read(newWordControllerProvider.notifier)
                    .removeImage(index),
              ),
            const SizedBox(
              height: 15,
            ),
            ImageAddButton(wordImages: wordImages),
          ],
        );
      },
    );
  }
}

class ImageListView extends StatelessWidget {
  final List<String> wordImages;
  final Function(int) removeImage;

  const ImageListView({
    super.key,
    required this.wordImages,
    required this.removeImage,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 170,
      child: ListView.builder(
        itemCount: wordImages.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Container(
                width: 130,
                height: 140,
                margin: const EdgeInsets.all(10.0),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(20)),
                child: Image(
                    image: FileImage(File(wordImages[index])),
                    fit: BoxFit.cover),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  onPressed: () => removeImage(index),
                  icon: const Icon(
                    Icons.close_outlined,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ImageAddButton extends StatelessWidget {
  final List<String> wordImages;

  const ImageAddButton({super.key, required this.wordImages});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
            disabledBackgroundColor: Theme.of(context).colorScheme.onBackground,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            backgroundColor: wordImages.length < 5
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onBackground,
            textStyle: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: Colors.white)),
        onPressed: wordImages.length < 5
            ? () async {
                try {
                  final image = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (image == null) return;
                  ref
                      .read(newWordControllerProvider.notifier)
                      .saveWordImage(image.path);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Oops! Something went wrong. Please try again.',
                        style: TextStyle(color: Colors.red[300]),
                      ),
                    ),
                  );
                }
              }
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Icon(
                Icons.add_a_photo_outlined,
                color: Colors.white,
              ),
            ),
            Text(
              'Add descriptive image',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: Colors.white),
            ),
          ],
        ),
      );
    });
  }
}
