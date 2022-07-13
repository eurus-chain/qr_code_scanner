import 'package:app_qrcode_scanner/app_qrcode_scanner.dart';
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
              child: const Padding(
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

  Future scanQRCode(BuildContext _) async {
    var response = await QRCodeScanner().tryOpenScanner(_);

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
