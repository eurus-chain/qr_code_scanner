import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_tools/qr_code_tools.dart';

import '../app_qrcode_scanner.dart';
import 'permission/photo_library.dart';
import 'template/cus_modal.dart';

class QRCodeModal extends CustomModal {
  QRCodeModal({
    this.hvPhotoPerm,
    this.photoPermModal,
    this.pgTitle,
    this.imgPickerIcon,
    this.flashOnIcon,
    this.flashOnText,
    this.flashOffIcon,
    this.flashOffText,
    this.scanningText,
    this.themeColor,
  }) : super();

  final bool hvPhotoPerm;
  final CustomModal photoPermModal;

  final String pgTitle;
  final IconData imgPickerIcon;
  final IconData flashOnIcon;
  final String flashOnText;
  final IconData flashOffIcon;
  final String flashOffText;
  final String scanningText;
  final Color themeColor;

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
      child: _QrCodeModalPage(
        hvPhotoPerm: hvPhotoPerm,
        photoPermModal: photoPermModal,
        pgTitle: pgTitle ?? 'Scan',
        imgPickerIcon: imgPickerIcon ?? Icons.image_outlined,
        flashOnIcon: flashOnIcon ?? Icons.flash_on,
        flashOnText: flashOnText ?? 'Lights On',
        flashOffIcon: flashOffIcon ?? Icons.flash_off,
        flashOffText: flashOffText ?? 'Lights Off',
        scanningText: scanningText ?? 'Scanning',
        themeColor: themeColor ?? Color(0xff009FDD),
      ),
    );
  }
}

class _QrCodeModalPage extends StatefulWidget {
  _QrCodeModalPage({
    this.hvPhotoPerm,
    this.photoPermModal,
    this.pgTitle = 'Scan',
    this.imgPickerIcon,
    this.flashOnIcon,
    this.flashOnText,
    this.flashOffIcon,
    this.flashOffText,
    this.scanningText,
    this.themeColor,
  }) : super();

  final bool hvPhotoPerm;
  final CustomModal photoPermModal;

  final String pgTitle;
  final IconData imgPickerIcon;
  final IconData flashOnIcon;
  final String flashOnText;
  final IconData flashOffIcon;
  final String flashOffText;
  final String scanningText;
  final Color themeColor;

  @override
  _QrCodeModalPageState createState() => _QrCodeModalPageState();
}

class _QrCodeModalPageState extends State<_QrCodeModalPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  QRViewController _controller;
  bool _flashOn = false;
  String _result = '';

  bool _photoPerm;

  BuildContext _context;

  @override
  void initState() {
    _photoPerm = widget.hvPhotoPerm == true ? true : null;
    super.initState();
  }

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
          pgTitle: widget.pgTitle,
          overlay: QrScannerOverlayShape(
            borderColor: widget.themeColor,
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
                    title: Text(widget.pgTitle),
                    actions: [
                      IconButton(
                        icon: Icon(widget.imgPickerIcon),
                        color: Colors.white,
                        onPressed: () async {
                          await _controller?.pauseCamera();
                          await _tryOpenImagePicker(context)
                              .whenComplete(() => _controller?.resumeCamera());
                        },
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        widget.scanningText,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        _controller?.toggleFlash();
                        setState(() {
                          _flashOn = !_flashOn;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                                _flashOn
                                    ? widget.flashOnIcon
                                    : widget.flashOffIcon,
                                color: Colors.white,
                                size: scanArea / 8),
                            Padding(
                              padding: EdgeInsets.only(bottom: 10),
                            ),
                            Text(
                              _flashOn
                                  ? widget.flashOnText
                                  : widget.flashOffText,
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 50)),
                  ],
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
    // _result = val;
    if (_controller != null) {
      _controller.pauseCamera();
    }
    Future.delayed(
      Duration(milliseconds: 100),
      () => Navigator.of(_context).pop(val),
    );
  }

  Future _tryOpenImagePicker(BuildContext _) async {
    if (widget.hvPhotoPerm == true || _photoPerm == true) {
      await _openImagePicker(_);
    } else if (widget.hvPhotoPerm == false || _photoPerm == false) {
      await Navigator.of(_).push(PhotoLibraryPermModal(
        disabled: true,
        themeColor: widget.themeColor,
      ));
      return;
    } else {
      var photoPrem = await Navigator.of(_).push(
        widget.photoPermModal ??
            PhotoLibraryPermModal(themeColor: widget.themeColor),
      );
      if (photoPrem != true) {
        return;
      }
      await _openImagePicker(_);
    }
  }

  Future _openImagePicker(BuildContext _) async {
    await ImagePicker().getImage(source: ImageSource.gallery, maxWidth: 500).then(
      (pickedFile) async {
        print('normal then pickedFile $pickedFile');
        if (pickedFile != null) await _decode(pickedFile.path);
        setState(() {
          _photoPerm = true;
        });
      },
    ).catchError((e) => print('disallowed $e'));
  }

  Future _decode(String file) async {
    var data = await QrCodeToolsPlugin.decodeFrom(file);
    _onScannedData(data);
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
      _controller = null;
    }
    super.dispose();
  }
}
