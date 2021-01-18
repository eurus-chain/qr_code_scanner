import 'package:flutter/material.dart';
import 'package:qr_code_scanner/src/qr_code_modal.dart';

export 'src/qr_code_modal.dart';
export 'src/qr_code_scanner.dart';
export 'src/qr_scanner_overlay_shape.dart';
export 'src/types/barcode.dart';
export 'src/types/barcode_format.dart';
export 'src/types/camera.dart';
export 'src/types/camera_exception.dart';
export 'src/types/features.dart';

Future<String> openScanner(BuildContext context) async {
  return Navigator.of(context).push(QRCodeModal());
}
