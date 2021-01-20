import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

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
    var camStatus = await Permission.camera.status;
    var photoStatus = await Permission.photos.status;

    var camPerm = camStatus.isUndetermined ? null : camStatus.isGranted;
    var photoPerm = photoStatus.isUndetermined ? null : photoStatus.isGranted;

    var response =
        await tryOpenScanner(_, hvCameraPerm: camPerm, hvPhotoPerm: photoPerm);

    setState(() {
      result = response ?? '';
    });
  }
}
