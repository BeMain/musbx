import 'package:flutter/material.dart';
import 'package:musbx/custom_icons.dart';
import 'package:musbx/music_player/music_player_screen.dart';

/// Show an exception dialog.
///
/// This is only dependent on [MusicPlayerScreen]'s context, and can thus be
/// used in places where no local context is available, such as button callbacks.
Future<void> showExceptionDialog(Widget dialog) async {
  if (musicPlayerScreenKey.currentContext == null ||
      !musicPlayerScreenKey.currentContext!.mounted) {
    return;
  }

  showDialog(
    context: musicPlayerScreenKey.currentContext!,
    builder: (context) => dialog,
  );
}

class UnsupportedFileExtensionDialog extends StatelessWidget {
  /// Creates an alert dialog with the message that the selected file type is not supported.
  const UnsupportedFileExtensionDialog({super.key, required this.extension});

  final String extension;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Unsupported file type"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.file_present_rounded, size: 128),
          const SizedBox(height: 15),
          Text(
              "The file type '.$extension' is not supported. Try loading a different file.")
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Dismiss"),
        )
      ],
    );
  }
}

class FileCouldNotBeLoadedDialog extends StatelessWidget {
  /// Creates an alert dialog with the message that the selected file could not be loaded.
  const FileCouldNotBeLoadedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("File could not be loaded"),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.file_present_rounded, size: 128),
          SizedBox(height: 15),
          Text(
              "An error occurred while loading the file. Please try again later, or try selecting a different file.")
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Dismiss"),
        )
      ],
    );
  }
}

class YoutubeUnavailableDialog extends StatelessWidget {
  /// Creates an alert dialog with the message that the Youtube service is unavailable.
  const YoutubeUnavailableDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("YouTube unavailable"),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CustomIcons.youtube, size: 128),
          SizedBox(height: 15),
          Text(
              "The YouTube service is currently unavailable. Please try again later.")
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Dismiss"),
        )
      ],
    );
  }
}
