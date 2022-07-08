import 'package:app_qrcode_scanner/app_qrcode_scanner.dart';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const MaterialApp(home: MyHome()));

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Demo Home Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const QRViewExample(),
            ));
          },
          child: const Text('qrView'),
        ),
      ),
    );
  }
}

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  String? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextButton(
              onPressed: () async {
                await scanQRCode(context);
              },
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Show QRCode Scanner'),
              ),
            ),
            Text(
              result ?? "",
              textAlign: TextAlign.center,
            )
          ],
        ),

      ),
    );
  }

// <<<<<<< HEAD
  Future scanQRCode(BuildContext _) async {
    var response = await QRCodeScanner().tryOpenScanner(_);
// =======
//   Widget _buildQrView(BuildContext context) {
//     // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
//     var scanArea = (MediaQuery.of(context).size.width < 400 ||
//             MediaQuery.of(context).size.height < 400)
//         ? 150.0
//         : 300.0;
//     // To ensure the Scanner view is properly sizes after rotation
//     // we need to listen for Flutter SizeChanged notification and update controller
//     return QRView(
//       key: qrKey,
//       onQRViewCreated: _onQRViewCreated,
//       overlay: QrScannerOverlayShape(
//           borderColor: Colors.red,
//           borderRadius: 10,
//           borderLength: 30,
//           borderWidth: 10,
//           cutOutSize: scanArea),
//       onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
//     );
//   }
// >>>>>>> master

    setState(() {
      result = response;
    });
  }
}

class QRCodeScanner extends AppQRCodeScanner {
  @override
  Future<bool?> ckCameraPermission() async {
    var camStatus = await Permission.camera.status;
    bool? camPerm;
    if (camStatus.isDenied) {
      camPerm = null;
    } else {
      if (camStatus.isPermanentlyDenied) {
        camPerm = false;
      } else {
        camPerm = camStatus.isGranted;
      }
    }

    return camPerm;
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  Future<bool?> ckPhotoPermission() async {
    var photoStatus = await Permission.photos.status;
    bool? photoPerm;
    if (photoStatus.isDenied) {
      photoPerm = null;
    } else {
      if (photoStatus.isPermanentlyDenied) {
        photoPerm = false;
      } else {
        photoPerm = photoStatus.isGranted;
      }
    }

    return photoPerm;
  }
}
