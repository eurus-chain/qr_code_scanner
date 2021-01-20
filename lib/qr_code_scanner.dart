import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_tools/qr_code_tools.dart';

import 'src/permission/camera.dart';
import 'src/permission/photo_library.dart';
import 'src/qr_code_modal.dart';
import 'src/template/cus_modal.dart';

export 'src/qr_code_modal.dart';
export 'src/qr_code_scanner.dart';
export 'src/qr_scanner_overlay_shape.dart';
export 'src/types/barcode.dart';
export 'src/types/barcode_format.dart';
export 'src/types/camera.dart';
export 'src/types/camera_exception.dart';
export 'src/types/features.dart';

Future<String> tryOpenScanner(
  BuildContext _, {
  bool hvCameraPerm,
  bool hvPhotoPerm,
  CustomModal cameraPermModal,
  CustomModal photoPermModal,
  String camtPgTitle,
  IconData imgPickerIcon,
  IconData flashOnIcon,
  String flashOnText,
  IconData flashOffIcon,
  String flashOffText,
}) async {
  if (hvCameraPerm == false) {
    // No permission and has to be done in system setting
    var result = Navigator.of(_).push(
      cameraPermModal ??
          CameraPermModal(
            disabled: true,
            openPhotoAction: hvPhotoPerm != false
                ? _imgPickerbtn(_, hvPhotoPerm, photoPermModal)
                : null,
          ),
    );
    return result is String ? result : '';
  } else if (hvCameraPerm == true) {
    // Already hv permission
    return _openScanner(
      _,
      hvPhotoPerm: hvPhotoPerm,
      photoPermModal: photoPermModal,
      pgTitle: camtPgTitle,
      imgPickerIcon: imgPickerIcon,
      flashOnIcon: flashOnIcon,
      flashOnText: flashOnText,
      flashOffIcon: flashOffIcon,
      flashOffText: flashOffText,
    );
  } else {
    // Ask permission
    var result = await Navigator.of(_).push(
      cameraPermModal ??
          CameraPermModal(
            openPhotoAction: hvPhotoPerm != false
                ? _imgPickerbtn(_, hvPhotoPerm, photoPermModal)
                : null,
          ),
    );
    // Open Camera modal to scan QRCode
    if (result == true) {
      return _openScanner(
        _,
        hvPhotoPerm: hvPhotoPerm,
        photoPermModal: photoPermModal,
        pgTitle: camtPgTitle,
        imgPickerIcon: imgPickerIcon,
        flashOnIcon: flashOnIcon,
        flashOnText: flashOnText,
        flashOffIcon: flashOffIcon,
        flashOffText: flashOffText,
      );
    }
    // Return result from Image QRCode
    if (result is String) {
      return result;
    }
  }

  return '';
}

Future<String> _openScanner(
  BuildContext _, {
  bool hvPhotoPerm,
  CustomModal photoPermModal,
  String pgTitle,
  IconData imgPickerIcon,
  IconData flashOnIcon,
  String flashOnText,
  IconData flashOffIcon,
  String flashOffText,
}) async {
  var result = await Navigator.of(_).push(
    QRCodeModal(
      hvPhotoPerm: hvPhotoPerm,
      photoPermModal: photoPermModal,
      pgTitle: pgTitle,
      imgPickerIcon: imgPickerIcon,
      flashOnIcon: flashOnIcon,
      flashOnText: flashOnText,
      flashOffIcon: flashOffIcon,
      flashOffText: flashOffText,
    ),
  );

  if (result is String) return result;

  return '';
}

Widget _imgPickerbtn(
  BuildContext _,
  bool hvPhotoPerm,
  CustomModal photoPermModal,
) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text('-- Or --'),
      Padding(
        padding: EdgeInsets.only(bottom: 10),
      ),
      FlatButton(
        onPressed: () async {
          var result = await _tryOpenImgPicker(_, hvPhotoPerm, photoPermModal);
          Navigator.of(_).pop(result);
        },
        child: Text('Scan QRCode from Image'),
      )
    ],
  );
}

Future<String> _tryOpenImgPicker(
  BuildContext _,
  bool hvPhotoPerm,
  CustomModal photoPermModal,
) async {
  if (hvPhotoPerm == false) {
    /// Advice user to enable this function in setting if no permission
    await Navigator.of(_)
        .push(photoPermModal ?? PhotoLibraryPermModal(disabled: true));
    return '';
  } else if (hvPhotoPerm == true) {
    return _openImgPicker();

    /// Open image picker if permission is already granted
  } else {
    /// Ask user to grant permission
    var allow =
        await Navigator.of(_).push(photoPermModal ?? PhotoLibraryPermModal());
    if (allow == true) {
      return _openImgPicker();
    }
  }

  return '';
}

Future<String> _openImgPicker() async {
  try {
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      return QrCodeToolsPlugin.decodeFrom(pickedFile.path);
    }
  } catch (e) {
    return '';
  }
  return '';
}
