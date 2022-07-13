import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'src/permission/camera.dart';
import 'src/permission/photo_library.dart';
import 'src/qr_code_modal.dart';
import 'src/template/cus_modal.dart';

export 'src/permission/camera.dart';
export 'src/permission/photo_library.dart';
export 'src/qr_code_modal.dart';

export 'src/qr_scanner_overlay_shape.dart';
export 'src/template/cus_modal.dart';
export 'src/template/prem_template.dart';

export 'src/types/camera.dart';
export 'src/types/camera_exception.dart';
export 'src/types/features.dart';

abstract class AppQRCodeScanner {
  Color? themeColor;
  String? camtPgTitle;
  IconData? imgPickerIcon;
  IconData? flashOnIcon;
  String? flashOnText;
  IconData? flashOffIcon;
  String? flashOffText;
  String? scanningText;

  Future<String> tryOpenScanner(BuildContext _) async {
    var hvCamPerm = await ckCameraPermission();
    var hvPhotoPerm = await ckPhotoPermission();

    if (hvCamPerm == false) {
      // No permission and has to be done in system setting
      var result = Navigator.of(_).push(
        genCameraPermModal(
            true,
            imgPickerBtn(
              _,
              hvPhotoPerm,
              genPhotoPermModal(hvPhotoPerm == false, themeColor: themeColor),
              themeColor: themeColor,
            ),
            themeColor: themeColor),
      );
      return result is String ? result as String : '';
    } else if (hvCamPerm == true) {
      // Already hv permission
      return _openScanner(
        _,
        hvPhotoPerm: hvPhotoPerm,
        photoPermModal:
            genPhotoPermModal(hvPhotoPerm == false, themeColor: themeColor),
        photoDisabledPermModal: genPhotoPermModal(true, themeColor: themeColor),
        pgTitle: camtPgTitle,
        imgPickerIcon: imgPickerIcon,
        flashOnIcon: flashOnIcon,
        flashOnText: flashOnText,
        flashOffIcon: flashOffIcon,
        flashOffText: flashOffText,
        scanningText: scanningText,
        themeColor: themeColor,
      );
    } else {
      // Ask permission
      var result = await Navigator.of(_).push(
        genCameraPermModal(
            hvCamPerm,
            imgPickerBtn(
              _,
              hvPhotoPerm,
              genPhotoPermModal(hvPhotoPerm == false, themeColor: themeColor),
              themeColor: themeColor,
            ),
            themeColor: themeColor),
      );
      // Open Camera modal to scan QRCode
      if (result == true) {
        return _openScanner(
          _,
          hvPhotoPerm: hvPhotoPerm,
          photoPermModal:
              genPhotoPermModal(hvPhotoPerm == false, themeColor: themeColor),
          photoDisabledPermModal:
              genPhotoPermModal(true, themeColor: themeColor),
          pgTitle: camtPgTitle,
          imgPickerIcon: imgPickerIcon,
          flashOnIcon: flashOnIcon,
          flashOnText: flashOnText,
          flashOffIcon: flashOffIcon,
          flashOffText: flashOffText,
          scanningText: scanningText,
          themeColor: themeColor,
        );
      }
      // Return result from Image QRCode
      if (result is String) {
        return result;
      }
    }

    return '';
  }

  Widget? imgPickerBtn(
    BuildContext _,
    bool? hvPhotoPerm,
    CustomModal photoPermModal, {
    Color? themeColor,
  }) {
    return hvPhotoPerm != false
        ? _imgPickerbtn(
            _,
            hvPhotoPerm,
            photoPermModal,
            themeColor: themeColor,
          )
        : null;
  }

  /// Return permission status of resourses
  ///
  /// null:   Have to ask for permission
  /// true:   Already granted permission
  /// false:  Permission denied
  Future<bool?> ckCameraPermission();
  Future<bool?> ckPhotoPermission();

  CustomModal genCameraPermModal(
    bool? disabled,
    Widget? openPhotoAction, {
    Color? themeColor,
  }) {
    return CameraPermModal(
      disabled: disabled,
      openPhotoAction: openPhotoAction,
      themeColor: themeColor,
    );
  }

  CustomModal genPhotoPermModal(bool? disabled, {Color? themeColor}) {
    return PhotoLibraryPermModal(disabled: disabled, themeColor: themeColor);
  }
}

Future<String> _openScanner(
  BuildContext _, {
  bool? hvPhotoPerm,
  CustomModal? photoPermModal,
  CustomModal? photoDisabledPermModal,
  String? pgTitle,
  IconData? imgPickerIcon,
  IconData? flashOnIcon,
  String? flashOnText,
  IconData? flashOffIcon,
  String? flashOffText,
  String? scanningText,
  Color? themeColor,
}) async {
  var result = await Navigator.push(
    _,
    QRCodeModal(
      hvPhotoPerm: hvPhotoPerm,
      photoPermModal: photoPermModal,
      photoDisabledPermModal: photoDisabledPermModal,
      pgTitle: pgTitle,
      imgPickerIcon: imgPickerIcon,
      flashOnIcon: flashOnIcon,
      flashOnText: flashOnText,
      flashOffIcon: flashOffIcon,
      flashOffText: flashOffText,
      scanningText: scanningText,
      themeColor: themeColor,
    ),
  );

  if (result is String) return result;

  return '';
}

Widget _imgPickerbtn(
  BuildContext _,
  bool? hvPhotoPerm,
  CustomModal photoPermModal, {
  Color? themeColor,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const Text('-- Or --'),
      TextButton(
        onPressed: () {
          tryOpenImgPicker(
            _,
            hvPhotoPerm,
            photoPermModal,
            themeColor: themeColor,
            barcodeHandler: (result) => Navigator.of(_).pop(result),
          );
        },
        child: const Text('Scan QRCode from Image'),
      )
    ],
  );
}

void tryOpenImgPicker(
  BuildContext _,
  bool? hvPhotoPerm,
  CustomModal? photoPermModal, {
  Color? themeColor,
  required Function(String?) barcodeHandler,
}) async {
  if (hvPhotoPerm == false) {
    /// Advice user to enable this function in setting if no permission
    await Navigator.of(_).push(photoPermModal ??
        PhotoLibraryPermModal(disabled: true, themeColor: themeColor));
    barcodeHandler('');
  } else if (hvPhotoPerm == true) {
    _openImgPicker(barcodeHandler: barcodeHandler);

    /// Open image picker if permission is already granted
  } else {
    /// Ask user to grant permission
    var allow = await Navigator.of(_)
        .push(photoPermModal ?? PhotoLibraryPermModal(themeColor: themeColor));
    if (allow == true) {
      _openImgPicker(barcodeHandler: barcodeHandler);
    }
  }

  barcodeHandler('');
}

void _openImgPicker({required Function(String?) barcodeHandler}) async {
  try {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, maxWidth: 500);

    if (pickedFile != null) {
      MobileScannerController cameraController = MobileScannerController();
      late StreamSubscription sub;
      sub = cameraController.barcodesController.stream.listen((barcode) {
        barcodeHandler(barcode.rawValue);
        sub.cancel();
      });

      await cameraController.analyzeImage(pickedFile.path);
    }
  } catch (e) {
    barcodeHandler('');
  }
  barcodeHandler('');
}
