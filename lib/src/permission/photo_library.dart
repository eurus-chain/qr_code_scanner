import 'package:flutter/material.dart';

import '../template/prem_template.dart';

class PhotoLibraryPermModal extends PermModalTemplate {
  PhotoLibraryPermModal({this.disabled})
      : super(
          title: 'Photo Library',
          desc: disabled == true
              ? 'Please allow us to access your Photo Library in System Setting'
              : 'Get Started by allowing us to access your Photo Library',
          icon: disabled == true
              ? Icons.image_not_supported_rounded
              : Icons.image_rounded,
          iconColor: disabled == true ? Colors.grey : null,
          hideDecline: disabled ?? false,
          acceptText: disabled == true ? 'Dismiss' : null,
        );

  final bool disabled;
}
