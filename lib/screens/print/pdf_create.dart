import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:m_sales/helper/db_helper.dart';
import 'package:m_sales/helper/local_db.dart';
import 'package:m_sales/models/customer.dart';
import 'package:m_sales/models/doc_details.dart';
import 'package:m_sales/models/gin_response.dart';
import 'package:m_sales/models/invoice.dart';
import 'package:m_sales/models/reciept.dart';
import 'package:m_sales/models/setting_types.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PDFGenerator {
  getGinNo() async {
    return await Settings.getGinStuHdrFgnRefCode();
  }

  DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

  late final SharedPreferences sharedPrefs;
  static const fontSizeLarge = 30.0;
  static const fontSizeMedium = 24.0;
  static const fontSizeGeneral = 16.0;

/*
  Future<pw.Page> createInvoicePDF(
      Invoice invoice, Customer customer, bool isCopy) async {
    var ginNo = await getGinNo();
    return pw.Page(
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          //   sharedPrefs.setString('company_name', compName);
          // sharedPrefs.setString('address', adress);
          // sharedPrefs.setString('tel', telp);
          // sharedPrefs.setString('hotline', hotine);
          // sharedPrefs.setString('email', emaila);
          // sharedPrefs.setString('web', webs);
          // sharedPrefs.setString('invttl1', invtl1);
          // sharedPrefs.setString('invttl2', invtl2);
          isCopy
              ? invoice.tax! > 0.00
                  ? pw.Text('Tax - ${sharedPrefs.getString('invttl2') ?? ''}',
                      style: pw.TextStyle(
                          fontSize: fontSizeLarge,
                          fontWeight: pw.FontWeight.bold))
                  : pw.Text(sharedPrefs.getString('invttl2') ?? '',
                      style: pw.TextStyle(
                          fontSize: fontSizeLarge,
                          fontWeight: pw.FontWeight.bold))
              : invoice.tax! > 0.00
                  ? pw.Text('Tax - ${sharedPrefs.getString('invttl1') ?? ''}',
                      style: pw.TextStyle(
                          fontSize: fontSizeLarge,
                          fontWeight: pw.FontWeight.bold))
                  : pw.Text(sharedPrefs.getString('invttl1') ?? '',
                      style: pw.TextStyle(
                          fontSize: fontSizeLarge,
                          fontWeight: pw.FontWeight.bold)),

          pw.Text(
              "Company Name : ${sharedPrefs.getString('company_name') ?? ''}",
              style: const pw.TextStyle(fontSize: fontSizeLarge)),
          pw.Text("Address : ${sharedPrefs.getString('address') ?? ''}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text("Tel : ${sharedPrefs.getString('tel') ?? ''}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text("Hotline : ${sharedPrefs.getString('hotline') ?? ''}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text("Email : ${sharedPrefs.getString('cemail') ?? ''}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text("Web : ${sharedPrefs.getString('web') ?? ''}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),

          pw.SizedBox(height: 30),
          pw.Text("Invoice No : ${invoice.invoiceId}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text("Date : ${invoice.dateTime}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text("Gin No : $ginNo", style: const pw.TextStyle(fontSize: 24)),
          pw.Text("Customer : ${customer.chtAccAlias}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text("Address : ${customer.chtAccAddress}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),

          pw.Text(
              "--------------------------------------------------------------------------------------------------------",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text(
              "ITEM DESCRIPTION                     |        RATE      |       QTY       |        VALUE",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text(
              "--------------------------------------------------------------------------------------------------------",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.SizedBox(height: 10),
          pw.ListView.builder(
            itemCount: invoice.items!.length,
            itemBuilder: (context, index) {
              final item = invoice.items![index];
              return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 3),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Container(
                        width: 300,
                        child: pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Row(children: [
                                pw.Text("${item.item!.ginStuAlise} - ",
                                    style: const pw.TextStyle(
                                        fontSize: fontSizeGeneral)),
                                pw.Text("${item.item!.ginStuName}",
                                    style: const pw.TextStyle(
                                        fontSize: fontSizeGeneral)),
                              ]),
                              pw.Text(
                                  item.item!.itMstDefualtPrice!
                                      .toStringAsFixed(2),
                                  style: const pw.TextStyle(
                                      fontSize: fontSizeGeneral)),
                            ]),
                      ),
                      pw.Container(
                          width: 150,
                          child: pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(
                                    "${item.selectedQuantity.toString()} ${item.item!.ginStuUnitName.toString()}",
                                    style: const pw.TextStyle(
                                        fontSize: fontSizeGeneral)),
                                pw.Row(children: [
                                  pw.Text(
                                      (item.selectedQuantity! *
                                              item.item!.itMstDefualtPrice!)
                                          .toStringAsFixed(2),
                                      style: const pw.TextStyle(
                                          fontSize: fontSizeGeneral)),
                                  pw.SizedBox(width: 10),
                                ])
                              ]))
                    ],
                  ));
            },
          ),
          pw.SizedBox(height: 10),
          pw.Text("--------------------------------------"),
          pw.SizedBox(height: 10),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('SUB AMOUNT :'),
                pw.Row(children: [
                  pw.Text(invoice.netTotal!.toStringAsFixed(2),
                      style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                  pw.SizedBox(width: 10)
                ])
              ]),
          // pw.Row(
          //     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          //     children: [
          //       pw.Text('DISCOUNT :'),
          //       pw.Row(children: [
          //         pw.Text('0', style: const pw.TextStyle(fontSize: 24)),
          //         pw.SizedBox(width: 90)
          //       ])
          //     ]),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('TOTAL AMOUNT :'),
                pw.Row(children: [
                  pw.Text(invoice.netTotal!.toStringAsFixed(2),
                      style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                  pw.SizedBox(width: 90)
                ])
              ]),
          pw.SizedBox(height: 10),
          pw.Text("--------------------------------------"),
          pw.SizedBox(height: 10),
          pw.Text("Print Date : ${formatter.format(DateTime.now())}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.SizedBox(height: 5),
          pw.Text("Received goods in good condition."),
          pw.SizedBox(height: 40),
          pw.Container(
              child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                pw.Column(children: [
                  pw.Text('..............................'),
                  pw.SizedBox(height: 5),
                  pw.Text('CUST. SIGNATURE')
                ]),
                pw.Row(children: [
                  pw.Column(children: [
                    pw.Text('........................'),
                    pw.SizedBox(height: 5),
                    pw.Text('AUTHORIZED')
                  ]),
                  pw.SizedBox(width: 20),
                ])
              ]))
        ],
      ),
    );
  }

  Future<pw.Page> createRecieptPDF(
      Reciept reciept, Customer customer, bool isCopy) async {
    return pw.Page(
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          isCopy
              ? pw.Text("Reciept (copy)",
                  style: pw.TextStyle(
                      fontSize: fontSizeLarge, fontWeight: pw.FontWeight.bold))
              : pw.Text("Reciept",
                  style: pw.TextStyle(
                      fontSize: fontSizeLarge, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 30),
          pw.Text("RCPT NO : ${reciept.recieptId}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text("INV NO : ${reciept.invoiceId}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text("DATE : ${reciept.dateTime}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text("CUSTOMER : ${customer.chtAccAlias}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text("ADDRESS : ${customer.chtAccAddress}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text("--------------------------------------"),
          pw.SizedBox(height: 10),
          pw.Text("PAYMODE : ${reciept.payMode}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          if (reciept.payMode == 'Cheque')
            pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("CHEQUE NO : ${reciept.chequeNo}",
                      style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                  pw.Text("BANK : ${reciept.bankCode}",
                      style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                  pw.Text("BRANCH : ${reciept.branchCode}",
                      style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                  pw.Text("CUS ACC NO : ${reciept.accountNo}",
                      style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                  pw.Text("CHEQUE DATE : ${reciept.chequeDate}",
                      style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                ]),
          pw.Text("AMOUNT : ${reciept.selectedAmount!.toStringAsFixed(2)}"),
          pw.Text("--------------------------------------"),
          pw.SizedBox(height: 10),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("AMOUNT :"),
                pw.Row(children: [
                  pw.Text(reciept.selectedAmount!.toStringAsFixed(2),
                      style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                  pw.SizedBox(width: 70)
                ]),
              ]),
          pw.SizedBox(height: 10),
          pw.Text("--------------------------------------"),
          pw.SizedBox(height: 10),
          pw.Text("Print Date : ${formatter.format(DateTime.now())}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.SizedBox(height: 5),
          pw.Text("Recieved goods in good condition."),
          pw.SizedBox(height: 40),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Column(children: [
                  pw.Text('.............................'),
                  pw.Text('CUST. SIGNATURE')
                ]),
                pw.Column(children: [
                  pw.Text('............................'),
                  pw.Text('REP. SIGNATURE')
                ])
              ])
        ],
      ),
    );
  }
*/

  double getUnitPrice(
      Invoice invoice, LineItemsSelected item, SettingTypes settingType) {
    double unitDefaultPrice = item.item?.itMstDefualtPrice ?? 0.00;
    double tax = 0.00;
    if (invoice.tax != null && invoice.tax! > 0.00) {
      if (settingType.vattype == 'VAT_INCLUDE') {
        tax = ((item.item?.itMstDefualtPrice ?? 0.0) * 18 / (100 + 18));
      } else {
        tax = ((item.item?.itMstDefualtPrice ?? 0.0) * 18 / (100));
      }
      return (unitDefaultPrice - tax);
    } else {
      return unitDefaultPrice;
    }
  }

  getRepName() async {
    DocDetails docDetails = await DatabaseHelper.instance.getDocDetails();
    return docDetails.repName ?? '';
  }

  Future<pw.Page> createInvoicePDF(
      Invoice invoice, Customer customer, bool isCopy) async {
    var ginNo = await getGinNo();
    var repName = await getRepName();
    SettingTypes settingType = await DatabaseHelper.instance.getSettingType();
    return pw.Page(
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(sharedPrefs.getString('company_name') ?? '',
              style: const pw.TextStyle(fontSize: fontSizeLarge)),
          pw.Text(sharedPrefs.getString('address') ?? '',
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text(sharedPrefs.getString('companyVatNo') ?? '',
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text(
              "Tel : ${sharedPrefs.getString('tel') ?? ''} / Hotline : ${sharedPrefs.getString('hotline') ?? ''}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text(
              "Email : ${sharedPrefs.getString('email') ?? ''} / Web : ${sharedPrefs.getString('web') ?? ''}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.SizedBox(height: 20),
          isCopy
              ? invoice.tax! > 0.00
                  ? pw.Text('Tax - ${sharedPrefs.getString('invttl2') ?? ''}',
                      style: pw.TextStyle(
                          fontSize: fontSizeLarge,
                          fontWeight: pw.FontWeight.bold))
                  : pw.Text(sharedPrefs.getString('invttl2') ?? '',
                      style: pw.TextStyle(
                          fontSize: fontSizeLarge,
                          fontWeight: pw.FontWeight.bold))
              : invoice.tax! > 0.00
                  ? pw.Text('Tax - ${sharedPrefs.getString('invttl1') ?? ''}',
                      style: pw.TextStyle(
                          fontSize: fontSizeLarge,
                          fontWeight: pw.FontWeight.bold))
                  : pw.Text(sharedPrefs.getString('invttl1') ?? '',
                      style: pw.TextStyle(
                          fontSize: fontSizeLarge,
                          fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 20),
          pw.Text("Mode of Payment : ${invoice.payMode}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text("Invoice No : ${invoice.invoiceId}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text("Date : ${invoice.dateTime}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text("Trip No : $ginNo",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text("Customer : ${customer.chtAccAlias} - ${customer.chtAccName}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text("Address : ${customer.chtAccAddress}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          if (customer.infoCustomerCategory == 1)
            pw.Text("Vat No : ${customer.chtAccWithCustVat}",
                style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.SizedBox(height: 15),
          pw.Text(
              "------------------------------------------------------------------------------------------",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text(
              "ITEM DESCRIPTION                |     RATE     |     QTY      |    VALUE",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text(
              "------------------------------------------------------------------------------------------",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.SizedBox(height: 10),
          pw.ListView.builder(
            itemCount: invoice.items!.length,
            itemBuilder: (context, index) {
              final item = invoice.items![index];
              return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 3),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment
                            .start, // Align items to the start
                        children: [
                          pw.Container(
                            width: 300,
                            child: pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Row(children: [
                                  pw.Text("${item.item!.ginStuAlise} - ",
                                      style: const pw.TextStyle(
                                          fontSize: fontSizeGeneral)),
                                  pw.Text("${item.item!.ginStuName}",
                                      style: const pw.TextStyle(
                                          fontSize: fontSizeGeneral)),
                                ]),
                              ],
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          // Spacing between the containers
                          pw.Container(
                            width:
                                300, // Same width as the first container for alignment
                            child: pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.SizedBox(width: 250),
                                pw.Text(
                                  getUnitPrice(invoice, item, settingType)
                                      .toStringAsFixed(2),
                                  style: const pw.TextStyle(
                                      fontSize: fontSizeGeneral),
                                ),
                                pw.SizedBox(width: 50),
                                pw.Text(
                                  "${item.selectedQuantity.toString()} ${item.item!.ginStuUnitName.toString()}",
                                  style: const pw.TextStyle(
                                      fontSize: fontSizeGeneral),
                                ),
                                pw.SizedBox(width: 50),
                                pw.Row(children: [
                                  pw.Text(
                                    (item.selectedQuantity! *
                                            getUnitPrice(
                                                invoice, item, settingType))
                                        .toStringAsFixed(2),
                                    style: const pw.TextStyle(
                                        fontSize: fontSizeGeneral),
                                  ),
                                  pw.SizedBox(width: 10),
                                ]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ));
            },
          ),
          pw.SizedBox(height: 10),
          pw.Text(
              "------------------------------------------------------------------------------------------",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.SizedBox(height: 10),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('SUB AMOUNT :',
                    style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                pw.Row(children: [
                  invoice.tax! > 0.00
                      ? pw.Text((invoice.grossTotal!).toStringAsFixed(2),
                          style: const pw.TextStyle(fontSize: fontSizeGeneral))
                      : pw.Text(invoice.netTotal!.toStringAsFixed(2),
                          style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                  pw.SizedBox(width: 10)
                ])
              ]),
          // pw.Row(
          //     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          //     children: [
          //       pw.Text('DISCOUNT :',
          //           style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          //       pw.Row(children: [
          //         pw.Text('0',
          //             style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          //         pw.SizedBox(width: 10)
          //       ])
          //     ]),
          if (invoice.tax! > 0.00)
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('VAT :',
                      style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                  pw.Row(children: [
                    pw.Text(invoice.tax!.toStringAsFixed(2),
                        style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                    pw.SizedBox(width: 10)
                  ])
                ]),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('TOTAL AMOUNT :',
                    style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                pw.Row(children: [
                  pw.Text(invoice.netTotal!.toStringAsFixed(2),
                      style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                  pw.SizedBox(width: 10)
                ])
              ]),
          pw.SizedBox(height: 10),
          pw.Text(
              "------------------------------------------------------------------------------------------",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.SizedBox(height: 10),
          pw.Text("Print Date : ${formatter.format(DateTime.now())}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.SizedBox(height: 5),
          pw.Text("Received goods in good condition.",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.SizedBox(height: 40),
          pw.Container(
              child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                pw.Column(children: [
                  pw.Text('.................................',
                      style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                  pw.SizedBox(height: 5),
                  pw.Text('CUST. SIGNATURE',
                      style: const pw.TextStyle(fontSize: fontSizeGeneral))
                ]),
                pw.Row(children: [
                  pw.Column(children: [
                    pw.Text('.................................',
                        style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                    pw.SizedBox(height: 5),
                    pw.Text('REP. SIGNATURE',
                        style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                    pw.Text('($repName)',
                        style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                  ]),
                  pw.SizedBox(width: 20),
                ])
              ]))
        ],
      ),
    );
  }

  Future<pw.Page> createRecieptPDF(
      Reciept reciept, Customer customer, bool isCopy) async {
    var repName = await getRepName();
    return pw.Page(
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(sharedPrefs.getString('company_name') ?? '',
              style: const pw.TextStyle(fontSize: fontSizeLarge)),
          pw.Text(sharedPrefs.getString('address') ?? '',
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text(
              "Tel : ${sharedPrefs.getString('tel') ?? ''} / Hotline : ${sharedPrefs.getString('hotline') ?? ''}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text(
              "Email : ${sharedPrefs.getString('email') ?? ''} / Web : ${sharedPrefs.getString('web') ?? ''}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.SizedBox(height: 20),
          isCopy
              ? pw.Text("Receipt (Copy)",
                  style: pw.TextStyle(
                      fontSize: fontSizeLarge, fontWeight: pw.FontWeight.bold))
              : pw.Text("Receipt",
                  style: pw.TextStyle(
                      fontSize: fontSizeLarge, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 20),
          pw.Text("RCPT NO : ${reciept.recieptId}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text("INV NO : ${reciept.invoiceId}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text("DATE : ${reciept.dateTime}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text("CUSTOMER : ${customer.chtAccAlias} - ${customer.chtAccName}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text("ADDRESS : ${customer.chtAccAddress}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.SizedBox(height: 15),
          pw.Text(
              "------------------------------------------------------------------------------------------",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.SizedBox(height: 10),
          pw.Text("PAY MODE : ${reciept.payMode}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          if (reciept.payMode == 'Cheque')
            pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("CHEQUE NO : ${reciept.chequeNo}",
                      style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                  pw.Text("BANK : ${reciept.bankCode}",
                      style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                  pw.Text("BRANCH : ${reciept.branchCode}",
                      style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                  pw.Text("CUS ACC NO : ${reciept.accountNo}",
                      style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                  pw.Text("CHEQUE DATE : ${reciept.chequeDate}",
                      style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                ]),
          pw.Text("AMOUNT : ${reciept.selectedAmount!.toStringAsFixed(2)}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.Text(
              "------------------------------------------------------------------------------------------",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.SizedBox(height: 10),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("AMOUNT :",
                    style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                pw.Row(children: [
                  pw.Text(reciept.selectedAmount!.toStringAsFixed(2),
                      style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                  pw.SizedBox(width: 10)
                ]),
              ]),
          pw.SizedBox(height: 10),
          pw.Text(
              "------------------------------------------------------------------------------------------",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.SizedBox(height: 10),
          pw.Text("Print Date : ${formatter.format(DateTime.now())}",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.SizedBox(height: 5),
          pw.Text("Received goods in good condition.",
              style: const pw.TextStyle(fontSize: fontSizeGeneral)),
          pw.SizedBox(height: 40),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(children: [
                  pw.Text('.................................',
                      style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                  pw.Text('CUST. SIGNATURE',
                      style: const pw.TextStyle(fontSize: fontSizeGeneral))
                ]),
                pw.Column(children: [
                  pw.Text('.................................',
                      style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                  pw.Text('REP. SIGNATURE',
                      style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                  pw.Text('($repName)',
                      style: const pw.TextStyle(fontSize: fontSizeGeneral)),
                ])
              ])
        ],
      ),
    );
  }

  Future<pw.Document> createCombinedPDF(List<pw.Page> pdfList) async {
    final pdfFInal = pw.Document();

    for (var pdf in pdfList) {
      pdfFInal.addPage(pdf);
    }

    return pdfFInal;
  }

  Future<pw.Document> previewPDF(BuildContext context, Invoice? invoice,
      List<Reciept> recieptList, Customer customer, bool isOneCopy) async {
    List<pw.Page> recieptPageList = [];
    sharedPrefs = await SharedPreferences.getInstance();

    if (invoice != null) {
      if (!isOneCopy) {
        final sellerPDF = await createInvoicePDF(invoice, customer, false);
        recieptPageList.add(sellerPDF);
      }
      final customerPDF = await createInvoicePDF(invoice, customer, true);
      recieptPageList.add(customerPDF);
    }
    if (recieptList.isNotEmpty) {
      for (var reciept in recieptList) {
        if (!isOneCopy) {
          final sellerReciept =
              await createRecieptPDF(reciept, customer, false);
          recieptPageList.add(sellerReciept);
        }
        final customerReciept = await createRecieptPDF(reciept, customer, true);

        recieptPageList.add(customerReciept);
      }
    }
    pw.Document pdfFinal = await createCombinedPDF(recieptPageList);
    return pdfFinal;
//     // await Printing.layoutPdf(
//     //   onLayout: (PdfPageFormat format) async => pdfFinal.save(),
//     // );
  }
}
