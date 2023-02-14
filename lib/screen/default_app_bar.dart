import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Create an [AppBar] with the text "Musician's toolbox" as title
  /// that features a button for opening an about dialog, that displays
  /// [helpText] and general information about the app.
  const DefaultAppBar({super.key, this.helpText})
      : preferredSize = const Size.fromHeight(kToolbarHeight);

  /// A short text explaining how to use the screen. Displayed in the about dialog.
  final String? helpText;

  @override
  final Size preferredSize; // default is 56.0

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Musician's toolbox"),
      actions: [InfoButton(child: (helpText == null) ? null : Text(helpText!))],
    );
  }
}

class InfoButton extends StatelessWidget {
  /// A button that opens an about dialog when pressed.
  ///
  /// The dialog shows info about the app and allows the user to view licenses.
  /// It also shows [child].
  const InfoButton({
    super.key,
    this.child,
  });

  /// Additional widget shown in the about dialog
  final Widget? child;

  static PackageInfo? packageInfo;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () async {
          packageInfo ??= await PackageInfo.fromPlatform();

          showAboutDialog(
            context: context,
            applicationIcon: const ImageIcon(
              AssetImage("assets/icon/musbx.png"),
            ),
            applicationVersion: "Version ${packageInfo?.version}",
            children: (child == null) ? null : [child!],
          );
        },
        icon: const Icon(Icons.info_outline_rounded));
  }
}