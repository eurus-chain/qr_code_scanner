import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_qrcode_scanner/app_qrcode_scanner.dart';

void main() => runApp(MaterialApp(home: QRViewExample()));

class QRViewExample extends StatefulWidget {
  const QRViewExample({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  String result = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FlatButton(
              onPressed: () async {
                await scanQRCode(context);
              },
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Show QRCode Scanner'),
              ),
            ),
            Text(
              result,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future scanQRCode(BuildContext _) async {
    var response = await QRCodeScanner().tryOpenScanner(_);

    setState(() {
      result = response ?? '';
    });
  }
}

class QRCodeScanner extends AppQRCodeScanner {
  @override
  Future<bool> ckCameraPermission() async {
    var camStatus = await Permission.camera.status;
    var camPerm = camStatus.isUndetermined ? null : camStatus.isGranted;

    return camPerm;
  }

  @override
  Future<bool> ckPhotoPermission() async {
    var photoStatus = await Permission.photos.status;
    var photoPerm = photoStatus.isUndetermined ? null : photoStatus.isGranted;

    return photoPerm;
  }
}
