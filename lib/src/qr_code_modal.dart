import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../app_qrcode_scanner.dart';

class QRCodeModal extends CustomModal {
  QRCodeModal({
    this.hvPhotoPerm,
    this.photoPermModal,
    this.photoDisabledPermModal,
    this.pgTitle,
    this.imgPickerIcon,
    this.flashOnIcon,
    this.flashOnText,
    this.flashOffIcon,
    this.flashOffText,
    this.scanningText,
    this.themeColor,
  }) : super();

  final bool? hvPhotoPerm;
  final CustomModal? photoPermModal;
  final CustomModal? photoDisabledPermModal;

  final String? pgTitle;
  final IconData? imgPickerIcon;
  final IconData? flashOnIcon;
  final String? flashOnText;
  final IconData? flashOffIcon;
  final String? flashOffText;
  final String? scanningText;
  final Color? themeColor;

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
        photoDisabledPermModal: photoDisabledPermModal,
        pgTitle: pgTitle ?? 'Scan',
        imgPickerIcon: imgPickerIcon ?? Icons.image_outlined,
        flashOnIcon: flashOnIcon ?? Icons.flash_on,
        flashOnText: flashOnText ?? 'Lights On',
        flashOffIcon: flashOffIcon ?? Icons.flash_off,
        flashOffText: flashOffText ?? 'Lights Off',
        scanningText: scanningText ?? 'Scanning',
        themeColor: themeColor ?? const Color(0xff009FDD),
      ),
    );
  }
}

class _QrCodeModalPage extends StatefulWidget {
  const _QrCodeModalPage({
    this.hvPhotoPerm,
    this.photoPermModal,
    this.photoDisabledPermModal,
    this.pgTitle,
    this.imgPickerIcon,
    this.flashOnIcon,
    this.flashOnText,
    this.flashOffIcon,
    this.flashOffText,
    this.scanningText,
    this.themeColor,
  }) : super();

  final bool? hvPhotoPerm;
  final CustomModal? photoPermModal;
  final CustomModal? photoDisabledPermModal;

  final String? pgTitle;
  final IconData? imgPickerIcon;
  final IconData? flashOnIcon;
  final String? flashOnText;
  final IconData? flashOffIcon;
  final String? flashOffText;
  final String? scanningText;
  final Color? themeColor;

  @override
  _QrCodeModalPageState createState() => _QrCodeModalPageState();
}

class _QrCodeModalPageState extends State<_QrCodeModalPage> {
  late MobileScannerController _controller;
  bool? _photoPerm;

  @override
  void initState() {
    _controller = MobileScannerController();
    _photoPerm = widget.hvPhotoPerm == true ? true : null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var maxLength = size.width > size.height ? size.height : size.width;
    var scanArea = maxLength * 0.75;
    var borderLength = scanArea * 0.075;

    return Stack(
      children: [
        MobileScanner(
          onDetect: (barcode, args) {
            if (barcode.rawValue != null) {
              if (barcode.format == BarcodeFormat.qrCode) {
                _onScannedData(barcode.rawValue ?? '');
              }
            }
          },
          controller: _controller,
        ),
        Container(
          decoration: ShapeDecoration(
            shape: QrScannerOverlayShape(
              borderColor: widget.themeColor ?? Colors.red,
              borderRadius: 0,
              borderLength: borderLength,
              borderWidth: 8,
              cutOutSize: scanArea,
              overlayColor: const Color.fromRGBO(0, 0, 0, 0.8),
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  child: AppBar(
                    backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
                    shadowColor: const Color.fromRGBO(0, 0, 0, 0),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      color: Colors.white,
                      onPressed: () {
                        Navigator.pop(context, 'empty');
                      },
                    ),
                    title: Text(widget.pgTitle ?? ''),
                    actions: [
                      IconButton(
                        icon: Icon(widget.imgPickerIcon),
                        color: Colors.white,
                        onPressed: () async {
                          await _controller.stop();
                          await _tryOpenImagePicker(context)
                              .whenComplete(() => _controller.start());
                        },
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: scanArea,
                width: scanArea,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        widget.scanningText ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _controller.toggleTorch(),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: ValueListenableBuilder(
                          valueListenable: _controller.torchState,
                          builder: (context, state, child) {
                            IconData icon;
                            String desc;
                            switch (state as TorchState) {
                              case TorchState.off:
                                icon = widget.flashOffIcon ?? Icons.flash_off;
                                desc = widget.flashOnText ?? '';
                                break;
                              case TorchState.on:
                                icon = widget.flashOnIcon ?? Icons.flash_on;
                                desc = widget.flashOffText ?? '';
                            }
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  icon,
                                  color: Colors.white,
                                  size: scanArea / 8,
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                ),
                                Text(
                                  desc,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
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
      _controller.stop();
    } else if (Platform.isIOS) {
      _controller.start();
    }
  }

  Future<void> _onScannedData(String val) async {
    await _controller.stop();
    Future.delayed(
      const Duration(milliseconds: 500),
      () => Navigator.pop(context, val),
    );
  }

  Future _tryOpenImagePicker(BuildContext _) async {
    if (widget.hvPhotoPerm == true || _photoPerm == true) {
      await _openImagePicker(_);
    } else if (widget.hvPhotoPerm == false || _photoPerm == false) {
      await Navigator.push(
        _,
        widget.photoDisabledPermModal ??
            PhotoLibraryPermModal(
              disabled: true,
              themeColor: widget.themeColor,
            ),
      );
      return;
    } else {
      var photoPrem = await Navigator.push(
        _,
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
    await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 500)
        .then(
      (pickedFile) async {
        if (pickedFile != null) await _decode(pickedFile.path);
      },
    );
  }

  Future _decode(String file) async {
    MobileScannerController cameraController = MobileScannerController();
    late StreamSubscription sub;
    sub = cameraController.barcodesController.stream.listen((barcode) {
      _onScannedData(barcode.rawValue ?? '');
      sub.cancel();
    });

    await cameraController.analyzeImage(file);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
