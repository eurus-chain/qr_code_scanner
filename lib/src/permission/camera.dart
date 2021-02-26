import 'package:flutter/material.dart';

import '../template/prem_template.dart';

class CameraPermModal extends PermModalTemplate {
  CameraPermModal({
    this.disabled,
    this.openPhotoAction,
    this.themeColor,
  }) : super(
          title: 'Camera Usage',
          desc: disabled == true
              ? 'Please allow us to access your Camera in System Setting'
              : 'Get Started by allowing us to use your camera',
          color: themeColor,
          icon: Icons.camera_alt_rounded,
          iconColor: disabled == true ? Colors.grey : themeColor,
          hideDecline: disabled ?? false,
          acceptText: disabled == true ? 'Dismiss' : null,
          otherAction: openPhotoAction,
        );

  final bool disabled;
  final Widget openPhotoAction;
  final Color themeColor;
}
