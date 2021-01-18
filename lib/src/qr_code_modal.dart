import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_tools/qr_code_tools.dart';
import 'package:image_picker/image_picker.dart';

class QRCodeModal extends ModalRoute<String> {
  @override
  Duration get transitionDuration => Duration(milliseconds: 200);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // This makes sure that text and other content follows the material style
    return Material(
      type: MaterialType.transparency,
      // make sure that the overlay content is not cut off
      child: _QrCodeModalPage(),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 1),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }
}

class _QrCodeModalPage extends StatefulWidget {
  @override
  _QrCodeModalPageState createState() => _QrCodeModalPageState();
}

class _QrCodeModalPageState extends State<_QrCodeModalPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  QRViewController _controller;
  bool _flashOn = false;
  String _result = '';

  BuildContext _context;

  @override
  Widget build(BuildContext context) {
    _context = context;

    var size = MediaQuery.of(context).size;
    var maxLength = size.width > size.height ? size.height : size.width;
    var scanArea = maxLength * 0.75;
    var borderLength = scanArea * 0.075;

    return Stack(
      children: [
        QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          pgTitle: 'Scan',
          overlay: QrScannerOverlayShape(
            borderColor: Color.fromRGBO(0, 179, 243, 1),
            borderRadius: 0,
            borderLength: borderLength,
            borderWidth: 8,
            cutOutSize: scanArea,
            overlayColor: Color.fromRGBO(0, 0, 0, 0.8),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  child: AppBar(
                    backgroundColor: Color.fromRGBO(0, 0, 0, 0),
                    shadowColor: Color.fromRGBO(0, 0, 0, 0),
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      color: Colors.white,
                      onPressed: () {
                        Navigator.of(context).pop('empty');
                      },
                    ),
                    title: Text('Scan'),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.image_outlined),
                        color: Colors.white,
                        onPressed: _getImage,
                      )
                    ],
                  ),
                ),
              ),
              Container(
                height: scanArea,
                width: scanArea,
              ),
              Expanded(
                child: Center(
                  child: FlatButton(
                    onPressed: () {
                      _controller.toggleFlash();
                      setState(() {
                        _flashOn = !_flashOn;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_flashOn ? Icons.flash_off : Icons.flash_on,
                              color: Colors.white, size: scanArea / 8),
                          Padding(padding: EdgeInsets.only(bottom: 10)),
                          Text('Lights ${_flashOn ? 'Off' : 'On'}',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller.pauseCamera();
    } else if (Platform.isIOS) {
      _controller.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    _controller = controller;
    _controller.scannedDataStream.listen((c) => _onScannedData(c.code));
  }

  void _onScannedData(String val) {
    _result = val;
    _controller..pauseCamera()..dispose();
    _controller = null;
    Future.delayed(
      Duration(milliseconds: 0),
      () => Navigator.of(_context).pop(_result),
    );
  }

  Future _getImage() async {
    await _controller.pauseCamera();
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );
    await _controller.resumeCamera();
    if (pickedFile != null) await _decode(pickedFile.path);
  }

  Future _decode(String file) async {
    var data = await QrCodeToolsPlugin.decodeFrom(file);
    _onScannedData(data);
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }
    super.dispose();
  }
}
