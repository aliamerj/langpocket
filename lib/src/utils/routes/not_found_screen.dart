import 'package:flutter/material.dart';
import 'package:langpocket/src/common_widgets/empty_placeholder_widget.dart';

// TODO: MAKE IT NICER::
/// Simple not found screen used for 404 errors (page not found on web)
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const EmptyPlaceholderWidget(
        message: '404 - Page not found!',
      ),
    );
  }
}
