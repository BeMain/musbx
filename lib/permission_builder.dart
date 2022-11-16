import 'package:flutter/material.dart';
import 'package:musbx/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionBuilder extends StatefulWidget {
  /// Allow the user to grant or deny a [permission].
  /// If [permission] is granted, [onPermissionGranted] is called.
  const PermissionBuilder({
    super.key,
    required this.permission,
    required this.onPermissionGranted,
    this.permissionName,
    this.permissionText,
    this.permissionDeniedIcon,
  });

  /// The permission that needs to be granted before [onPermissionGranted] is called.
  final Permission permission;

  /// Called when [permission] has been granted.
  final void Function() onPermissionGranted;

  /// The name of this permission.
  final String? permissionName;

  /// Short text describing why this permission is required.
  final String? permissionText;

  final Widget? permissionDeniedIcon;

  @override
  State<StatefulWidget> createState() => PermissionBuilderState();
}

class PermissionBuilderState extends State<PermissionBuilder>
    with WidgetsBindingObserver {
  PermissionStatus? status;

  AppLifecycleState prevState = AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.permission.status.then((newStatus) {
      if (mounted) {
        setState(() {
          status = newStatus;
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed &&
        prevState == AppLifecycleState.paused) {
      requestPermission();
    }
    prevState = state;
  }

  @override
  Widget build(BuildContext context) {
    if (status == null) return const LoadingScreen(text: "");

    if (status == PermissionStatus.granted) {
      widget.onPermissionGranted();
      return const LoadingScreen(text: "Permission granted");
    }

    if (status == PermissionStatus.permanentlyDenied) {
      return buildPermissionDeniedScreen(
        additionalInfoText:
            "You need to give this permission from the System Settings.",
        buttonText: "Open Settings",
        onButtonPressed: openAppSettings,
      );
    }

    return buildPermissionDeniedScreen(
      buttonText: "Request permission",
      onButtonPressed: requestPermission,
    );
  }

  Future<void> requestPermission() async {
    widget.permission.request().then((newStatus) {
      if (mounted) {
        setState(() {
          status = newStatus;
        });
      }
    });
  }

  Widget buildPermissionDeniedScreen({
    String? additionalInfoText,
    required String buttonText,
    required void Function() onButtonPressed,
  }) {
    additionalInfoText =
        (additionalInfoText != null) ? "\n\n$additionalInfoText" : "";
    String permissionText =
        (widget.permissionText != null) ? "\n\n${widget.permissionText}" : "";
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (widget.permissionDeniedIcon != null)
              widget.permissionDeniedIcon!,
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Access to the ${widget.permissionName ?? widget.permission} denied. $permissionText $additionalInfoText",
                textAlign: TextAlign.center,
              ),
            ),
            OutlinedButton(
              onPressed: onButtonPressed,
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
