// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../models/account.dart';

class QrService {
  static bool isValidTotpUri(String uri) {
    return uri.startsWith('otpauth://totp/') && uri.contains('secret=');
  }

  static Account? parseQrCode(String qrData) {
    try {
      if (!isValidTotpUri(qrData)) {
        return null;
      }
      return Account.fromUri(qrData);
    } catch (e) {
      return null;
    }
  }

  static Future<String?> scanQrCode(BuildContext context) async {
    return await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (context) => const QrScannerWidget()),
    );
  }
}

class QrScannerWidget extends StatefulWidget {
  const QrScannerWidget({super.key});

  @override
  State<QrScannerWidget> createState() => _QrScannerWidgetState();
}

class _QrScannerWidgetState extends State<QrScannerWidget> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Theme.of(context).colorScheme.primary,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 250,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Position the QR code within the frame',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () async {
                          await controller?.toggleFlash();
                        },
                        icon: const Icon(Icons.flash_on),
                        tooltip: 'Toggle Flash',
                      ),
                      IconButton(
                        onPressed: () async {
                          await controller?.flipCamera();
                        },
                        icon: const Icon(Icons.flip_camera_ios),
                        tooltip: 'Flip Camera',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        Navigator.of(context).pop(scanData.code);
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}