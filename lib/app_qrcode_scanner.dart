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

abstract class AppQRCodeScanner {
  Color themeColor;
  String camtPgTitle;
  IconData imgPickerIcon;
  IconData flashOnIcon;
  String flashOnText;
  IconData flashOffIcon;
  String flashOffText;
  CustomModal cameraPermModal;
  CustomModal photoPermModal;

  Future<String> tryOpenScanner(BuildContext _) async {
    var hvCamPerm = await ckCameraPermission();
    var hvPhotoPerm = await ckPhotoPermission();

    if (hvCamPerm == false) {
      // No permission and has to be done in system setting
      var result = Navigator.of(_).push(
        cameraPermModal ??
            CameraPermModal(
              disabled: true,
              openPhotoAction: hvPhotoPerm != false
                  ? _imgPickerbtn(
                      _,
                      hvPhotoPerm,
                      photoPermModal,
                      themeColor: themeColor,
                    )
                  : null,
              themeColor: themeColor,
            ),
      );
      return result is String ? result : '';
    } else if (hvCamPerm == true) {
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
                  ? _imgPickerbtn(
                      _,
                      hvPhotoPerm,
                      photoPermModal,
                      themeColor: themeColor,
                    )
                  : null,
              themeColor: themeColor,
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

  /// Return permission status of resourses
  ///
  /// null:   Have to ask for permission
  /// true:   Already granted permission
  /// false:  Permission denied
  Future<bool> ckCameraPermission();
  Future<bool> ckPhotoPermission();
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
  CustomModal photoPermModal, {
  Color themeColor,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text('-- Or --'),
      FlatButton(
        onPressed: () async {
          var result = await _tryOpenImgPicker(_, hvPhotoPerm, photoPermModal,
              themeColor: themeColor);
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
  CustomModal photoPermModal, {
  Color themeColor,
}) async {
  if (hvPhotoPerm == false) {
    /// Advice user to enable this function in setting if no permission
    await Navigator.of(_).push(photoPermModal ??
        PhotoLibraryPermModal(disabled: true, themeColor: themeColor));
    return '';
  } else if (hvPhotoPerm == true) {
    return _openImgPicker();

    /// Open image picker if permission is already granted
  } else {
    /// Ask user to grant permission
    var allow = await Navigator.of(_)
        .push(photoPermModal ?? PhotoLibraryPermModal(themeColor: themeColor));
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
