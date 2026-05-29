import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:m_sales/models/printer_device.dart';

class PrinterService {
  static const MethodChannel _channel = MethodChannel('printer_service');
  static const EventChannel _eventChannel =
      EventChannel('printer_service/discovery');

  PrinterService._();

  static final PrinterService _instance = PrinterService._();

  factory PrinterService() => _instance;

  Stream<PrinterDevice> get printerDiscoveryStream {
    return _eventChannel.receiveBroadcastStream().map((event) {
      return PrinterDevice.fromJson(Map<String, dynamic>.from(event));
    });
  }

  Future<void> printPdf(List<String> filePaths, String deviceBtAddress) async {
    try {
      await _channel.invokeMethod('printPdf',
          {'filePaths': filePaths, 'deviceBtAddress': deviceBtAddress});
    } on PlatformException catch (e) {
      log("Failed to print PDF: ${e.message}");
    }
  }

  Future<void> discoverPrinters() async {
    try {
      await _channel.invokeMethod('discoverPrinters');
    } on PlatformException catch (e) {
      log("Failed to discover printers: ${e.message}");
    }
  }
}
