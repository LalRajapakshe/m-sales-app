import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:m_sales/Widgets/full_screen_loading.dart';
import 'package:m_sales/models/customer.dart';
import 'package:m_sales/models/invoice.dart';
import 'package:m_sales/models/printer_device.dart';
import 'package:m_sales/models/reciept.dart';
import 'package:m_sales/screens/customer/customer_details.dart';
import 'package:m_sales/screens/print/pdf_create.dart';
import 'package:m_sales/services/cart_service.dart';
import 'package:m_sales/services/printer_service.dart';
import 'package:millimeters/millimeters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_image_renderer/pdf_image_renderer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class PrintScreen extends StatefulWidget {
  final Invoice? invoice;
  final List<Reciept> recieptList;
  final Customer customer;
  final Function? closeButtonAction;
  final bool isCopy;
  const PrintScreen(
      {super.key,
      this.invoice,
      required this.recieptList,
      required this.customer,
      this.closeButtonAction,
      required this.isCopy});

  @override
  State<PrintScreen> createState() => _PrintScreenState();
}

class _PrintScreenState extends State<PrintScreen> {
  final PDFGenerator pdfGenerator = PDFGenerator();
  late pw.Document pdf;
  late File file;
  final List<File> filesToPrint = [];
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  bool isLoading = true;

  final PrinterService bluetoothPrint = PrinterService();
  final List<PrinterDevice> _devices = [];
  String _devicesMsg = "";
  PrinterDevice? selectedDevice;
  StreamSubscription? _printerDiscoverySubscription;

  @override
  void initState() {
    setPath();
    super.initState();
  }

  setPath() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initPrinter();
    });
    pdf = await pdfGenerator.previewPDF(context, widget.invoice,
        widget.recieptList, widget.customer, widget.isCopy);
    final output = await getTemporaryDirectory();
    file = File("${output.path}/mSales.pdf");
    await file.writeAsBytes(await pdf.save());

    final pdf2 = PdfImageRendererPdf(path: "${output.path}/mSales.pdf");
    await pdf2.open();
    for (var i = 0; i < await pdf2.getPageCount(); i++) {
      await pdf2.openPage(pageIndex: i);
      final size = await pdf2.getPageSize(pageIndex: i);
      final mm = Millimeters.of(context).mm;
      final img = await pdf2.renderPage(
        pageIndex: i,
        x: mm(0).toInt(),
        y: mm(0).toInt(),
        width: size.width,
        height: size.height,
        scale: 4,
        background: Colors.white,
      );
      final outputDir = await getTemporaryDirectory();
      final fileToPrint = File("${outputDir.path}/mSales$i.png");
      await fileToPrint.writeAsBytes(img!);
      filesToPrint.add(fileToPrint);

      await pdf2.closePage(pageIndex: i);
    }

    pdf2.close();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> initPrinter() async {
    await Permission.bluetooth.request();
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothScan.request();

    bluetoothPrint.discoverPrinters();

    if (!mounted) return;
    if (_printerDiscoverySubscription != null) {
      await _printerDiscoverySubscription?.cancel();
      _printerDiscoverySubscription = null;
    }
    _printerDiscoverySubscription =
        bluetoothPrint.printerDiscoveryStream.listen(
      (val) {
        setState(() {
          if (!_devices.any((element) => element.address == val.address)) {
            _devices.add(val);
          }
        });
        if (_devices.isEmpty) {
          setState(() {
            _devicesMsg = "No Devices";
          });
        }
      },
      onError: (e) => log(e),
    );
    
  }

  Future<void> _startPrint(PrinterDevice device) async {
    try {
      await bluetoothPrint.printPdf(
          filesToPrint.map((e) => e.path).toList(), device.address);
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.orange,
          title: const Text("Print"),
          centerTitle: true,
        ),
        body: isLoading
            ? const FullScreenLoading()
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SizedBox(
                        height: 60,
                        child: InputDecorator(
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.bluetooth),
                              labelText: 'Bluetooth Device',
                              border: OutlineInputBorder(),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<PrinterDevice>(
                                value: selectedDevice,
                                onChanged: (PrinterDevice? newValue) {
                                  setState(() {
                                    selectedDevice = newValue;
                                  });
                                },
                                items: _devices.map((PrinterDevice value) {
                                  return DropdownMenuItem<PrinterDevice>(
                                    value: value,
                                    child: Text(value.name ?? ''),
                                  );
                                }).toList(),
                              ),
                            ))),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 250,
                    child: PDFView(
                      filePath: file.path,
                      fitPolicy: FitPolicy.BOTH,
                      enableSwipe: true,
                      autoSpacing: false,
                      pageFling: false,
                      onError: (error) {},
                      onViewCreated: (PDFViewController pdfViewController) {
                        _controller.complete(pdfViewController);
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Container(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child: const Text(
                                'Print',
                                style: TextStyle(
                                    fontSize: 15.0, color: Colors.white),
                              ),
                              onPressed: () {
                                if (selectedDevice != null) {
                                _startPrint(selectedDevice!);
                                } else {
                                  Get.snackbar(
                                    'Error',
                                    'Select Device',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Container(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade100,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child: const Text(
                                'Close',
                                style: TextStyle(
                                    fontSize: 15.0, color: Colors.black),
                              ),
                              onPressed: () {
                                if (widget.closeButtonAction == null) {
                                  Provider.of<CartService>(context,
                                          listen: false)
                                      .clearCart();
                                  Navigator.of(context)
                                      .pushReplacement(MaterialPageRoute(
                                          builder: (context) => CustomerDetails(
                                                callGet: false,
                                                customer: widget.customer,
                                              )));
                                } else {
                                  widget.closeButtonAction!();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 60,
                        width: 60,
                        child: IconButton(
                            onPressed: () {
                              initPrinter();
                            },
                            icon: const Icon(Icons.refresh)),
                      )
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
