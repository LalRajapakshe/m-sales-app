import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:m_sales/api/api_consts.dart';
import 'package:m_sales/helper/db_helper.dart';
import 'package:m_sales/helper/local_db.dart';
import 'package:m_sales/models/cheque.dart';
import 'package:m_sales/models/customer.dart';
import 'package:m_sales/models/doc_details.dart';
import 'package:m_sales/models/invoice.dart';
import 'package:m_sales/models/invoice_save_body.dart';
import 'package:http/http.dart' as http;
import 'package:m_sales/models/reciept.dart';
import 'package:m_sales/models/reciept_save_body.dart';
import 'package:m_sales/models/setting_types.dart';
import 'package:m_sales/models/settlement_save_body.dart';

class SaveDataService {
  DateTime now = DateTime.now();
  DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

  Future<bool> saveInvoices(List<InvoiceSaveBody> bodyList) async {
    List body = [];
    bodyList.forEach((itm) {
      body.add(itm.toJson());
    });
    String accessToken = await Settings.getAccessToken();
    final url =
        Uri.parse('$BASER_URL/tapi/$TENENT/mobile/mobileSales/SaveInvoice');
    try {
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            "Authorization": "Bearer $accessToken"
          },
          body: jsonEncode(body));
      if (response.statusCode == 200) {
       // print('SaveInvoice OK: ${response.statusCode} ${response.body}');
        return true;
      } else {
       //print('SaveInvoice FAILED');
       // p rint('SaveInvoice URL: $url');
       // print('SaveInvoice status: ${response.statusCode}');
       // print('SaveInvoice reason: ${response.reasonPhrase}');
       // print('SaveInvoice response body: ${response.body}');
        _logLong('SaveInvoice request JSON: ', jsonEncode(body));
        return false;
      }
    } catch (error) {
     // print('SaveInvoice ERROR: $error');
     // print('SaveInvoice URL: $url');
      _logLong('SaveInvoice request JSON: ', jsonEncode(body));
      return false;
    }
  }

  // Android logcat truncates/interleaves long lines, which garbled the
  // previous single-line payload print.
  void _logLong(String prefix, String text) {
    const int chunkSize = 800;
    for (int i = 0; i < text.length; i += chunkSize) {
      final int end =
          (i + chunkSize < text.length) ? i + chunkSize : text.length;
      print('$prefix[${i ~/ chunkSize}] ${text.substring(i, end)}');
    }
  }

  Future<bool> saveReciepts(List<RecieptSaveBody> bodyList) async {
    List body = [];
    bodyList.forEach((itm) {
      body.add(itm.toJson());
    });
    String accessToken = await Settings.getAccessToken();
    final url =
        Uri.parse('$BASER_URL/tapi/$TENENT/mobile/mobileSales/SaveReceipt');
    try {
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            "Authorization": "Bearer $accessToken"
          },
          body: jsonEncode(body));
      print(url);
      for (var element in bodyList) {
        print(element.toJson());
      }
      print(response.body);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
  }

  Future<bool> saveSettlements(List<SettlementSaveBody> bodyList) async {
    List body = [];
    bodyList.forEach((itm) {
      body.add(itm.toJson());
    });
    String accessToken = await Settings.getAccessToken();
    final url =
        Uri.parse('$BASER_URL/tapi/$TENENT/mobile/mobileSales/SaveSettlement');
    try {
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            "Authorization": "Bearer $accessToken"
          },
          body: jsonEncode(body));
      print(url);
      for (var element in bodyList) {
        print(element.toJson());
      }
      print(response.body);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
  }

  Future<bool> getDocAttribute() async {
    String accessToken = await Settings.getAccessToken();
    // int? lastInvId = await getLastInvoiceId();
    // int? lastRecieptId = await getLastRecieptId();
    String? userId = await Settings.getUserID();

    final url = Uri.parse(
        '$BASER_URL/tapi/$TENENT/mobile/mobileSales/SyncDocAttributeMaster?RepId=$userId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $accessToken"
        },
      );
      print(url);
      // for (var element in bodyList) {
      //   print(element.toJson());
      // }
      print(response.body);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        DocDetails _docDetailsResponse = DocDetails.fromJson(data);
        DocDetails localDocDetails =
            await DatabaseHelper.instance.getDocDetails();
        final bool hasLocalRow =
            localDocDetails.repCode != null && localDocDetails.repCode != 0;
        final bool sameRep = hasLocalRow &&
            _docDetailsResponse.repCode != null &&
            localDocDetails.repCode == _docDetailsResponse.repCode;

        if (!hasLocalRow || !sameRep) {
          await DatabaseHelper.instance.insertDoc(_docDetailsResponse);
        } else {
          await DatabaseHelper.instance.insertDoc(DocDetails(
            repCode: _docDetailsResponse.repCode ?? localDocDetails.repCode,
            invCode: _docDetailsResponse.invCode ?? localDocDetails.invCode,
            repName: _docDetailsResponse.repName ?? localDocDetails.repName,
            cashReceCode: _docDetailsResponse.cashReceCode ??
                localDocDetails.cashReceCode,
            bankReceCode: _docDetailsResponse.bankReceCode ??
                localDocDetails.bankReceCode,
            returnCode:
                _docDetailsResponse.returnCode ?? localDocDetails.returnCode,
            repShortCode: _docDetailsResponse.repShortCode ??
                localDocDetails.repShortCode,
            docNoLength: _docDetailsResponse.docNoLength ??
                localDocDetails.docNoLength,
            invLastNo: _maxLastNo(
                localDocDetails.invLastNo, _docDetailsResponse.invLastNo),
            cashReceLastNo: _maxLastNo(localDocDetails.cashReceLastNo,
                _docDetailsResponse.cashReceLastNo),
            bankReceLastNo: _maxLastNo(localDocDetails.bankReceLastNo,
                _docDetailsResponse.bankReceLastNo),
            returnLastNo: _maxLastNo(localDocDetails.returnLastNo,
                _docDetailsResponse.returnLastNo),
          ));
        }
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
  }

  int _maxLastNo(int? localValue, int? serverValue) {
    final int local = localValue ?? 0;
    final int server = serverValue ?? 0;
    return local > server ? local : server;
  }

  // main Functions

  getInvoiceList(String? customerId) async {
    List<Invoice> invoiceList = [];
    String? userId = await Settings.getUserID();
    if (customerId != null) {
      invoiceList = await DatabaseHelper.instance
          .getAllInvoicesByCustomer(userId!, customerId);
    } else {
      invoiceList = await DatabaseHelper.instance.getAllInvoices(userId!);
    }

    SettingTypes settingType = await DatabaseHelper.instance.getSettingType();
    DocDetails docs = await DatabaseHelper.instance.getDocDetails();

    String? tripCode = await Settings.getGinStuHdrFgnRefCode();
    List<InvoiceSaveBody> finalInvoiceList = [];
    for (var inv in invoiceList) {
      Customer customer = await DatabaseHelper.instance
          .getCustomersByCustomerId(inv.chtAccAccNo!);
      List<Item> itemList = [];
      for (var itm in inv.items!) {
        final double unitPrice = itm.item!.itMstDefualtPrice!;
        final double qty = itm.selectedQuantity ?? 0.00;
        final double unitVat = getVatForItem(
            unitPrice, inv.vatIncExc!, inv.tax! != 0.00 ? true : false);
        itemList.add(Item(
            headerId: inv.items!.indexOf(itm),
            itemCode: itm.item!.ginStuAlise,
            itemId: itm.item!.ginStuItemCode,
            itemName: itm.item!.ginStuName,
            unitId: 0,
            unitPrice: unitPrice,
            lineNo: 0,
            quantity: itm.selectedQuantity,
            vatAmount: unitVat * qty,
            grossAmount:
                (inv.tax! != 0.00 ? unitPrice - unitVat : unitPrice) * qty,
            netAmount: unitPrice * qty,
            isSync: true));
      }
      String? docTime = inv.items!.isNotEmpty ? inv.items!.first.docTime : null;
      if (docTime == null) {
        final DateTime? invoiceSavedAt = DateTime.tryParse(inv.dateTime ?? '');
        if (invoiceSavedAt != null) {
          docTime = DateFormat('HH:mm:ss').format(invoiceSavedAt);
        }
      }
      double balanceAmt =
          await getBalanceAmountForInvoice(inv.invoiceId!, inv.netTotal!);
      finalInvoiceList.add(InvoiceSaveBody(
          invoiceId: invoiceList.indexOf(inv),
          invoiceNo: inv.invoiceId,
          docDate: inv.dateTime,
          docType: inv.isReturn == 'true' ? 'RTN' : 'INV',
          customerId: int.tryParse(inv.chtAccAccNo!),
          customerCode: customer.chtAccAlias,
          customerName: customer.chtAccName,
          docTime: docTime,
          locationId: docs.repCode,
          status: 'ACTIVE',
          tripCode: tripCode,
          payMode: settingType.payModeBase == 'YES' ? inv.payMode : 'N/A',
          printCount: 0,
          lineNo: 0,
          mainAmt: inv.tax! + inv.netTotal!,
          balanceAmt: balanceAmt,
          lineItems: itemList,
          isSync: true));
    }

    return finalInvoiceList;
  }

  /* getAllReceipts() async {
    String? userId = await Settings.getUserID();
    List<Reciept> list = await DatabaseHelper.instance.getAllReciepts();
    List<RecieptSaveBody> finalRecieptList = [];
    // List<Cheque> chequeList = await DatabaseHelper.instance.getAllCheques();
    SettingTypes settingType = await DatabaseHelper.instance.getSettingType();

    list.forEach((element) async {
      Customer customer = await getCustomerByInvoiceId(element.invoiceId!);
      // Cheque cheque = Cheque.empty();
      // if (element.payMode == 'Cheque') {
      //   cheque = chequeList.firstWhere((chq) {
      //     return chq.recieptId == element.recieptId;
      //   });
      // }

      double balanceAmount =
          await getBalanceAmountForReciept(element.recieptId!, element.paid!);
      finalRecieptList.add(RecieptSaveBody(
          receiptId: list.indexOf(element),
          receiptNo: element.recieptId,
          docDate: element.dateTime,
          customerId: customer.chtAccAccNo,
          customerCode: customer.chtAccAlias,
          customerName: customer.chtAccName,
          status: 'ACTIVE',
          payMode: element.payMode,
          chequeDate: element.chequeDate ?? '',
          chequeNo: element.chequeNo ?? '',
          bankCode: element.bankCode ?? '',
          branchCode: element.branchCode ?? '',
          accountNo: element.accountNo ?? '',
          amount: element.selectedAmount,
          balanceAmount: balanceAmount,
          isSync: true));
    });
    return finalRecieptList;
  } */
 Future<List<RecieptSaveBody>> getAllReceipts() async {
  String? userId = await Settings.getUserID();

  List<Reciept> list =
      await DatabaseHelper.instance.getAllReciepts();

  List<RecieptSaveBody> finalRecieptList = [];

  for (var element in list) {
    Customer customer =
        await getCustomerByInvoiceId(element.invoiceId!);

    double balanceAmount =
        await getBalanceAmountForReciept(
      element.recieptId!,
      element.paid!,
    );

    finalRecieptList.add(
      RecieptSaveBody(
        receiptId: list.indexOf(element),
        receiptNo: element.recieptId,
        docDate: element.dateTime,
        customerId: customer.chtAccAccNo,
        customerCode: customer.chtAccAlias,
        customerName: customer.chtAccName,
        status: 'ACTIVE',
        payMode: element.payMode,
        chequeDate: element.chequeDate ?? '',
        chequeNo: element.chequeNo ?? '',
        bankCode: element.bankCode ?? '',
        branchCode: element.branchCode ?? '',
        accountNo: element.accountNo ?? '',
        amount: element.selectedAmount,
        balanceAmount: balanceAmount,
        isSync: true,
      ),
    );
  }

  return finalRecieptList;
}

  getSettlementList() async {
    String? userId = await Settings.getUserID();
    List<Reciept> list = await DatabaseHelper.instance.getAllReciepts();
    List<SettlementSaveBody> settlementList = [];
    for (var element in list) {
      double? settleAmount =
          await getSettleAmountForReciept(element.recieptId!);
      settlementList.add(SettlementSaveBody(
          settleId: list.indexOf(element),
          invoiceNo: element.invoiceId,
          receiptNo: element.recieptId,
          docDate: element.dateTime,
          settleAmount: settleAmount!));
    }
    return settlementList;
  }

  //support functions

  getVatForItem(double unitPrice, String vatMode, bool isVatEnable) {
    if (isVatEnable) {
      if (vatMode == 'VAT_INCLUDE') {
        return unitPrice * (18 / (100 + 18));
      } else {
        return unitPrice * (18 / (100));
      }
    } else {
      return 0.00;
    }
  }

  getBalanceAmountForInvoice(String invoiceId, double netAmount) async {
    List<Reciept> recieptList =
        await DatabaseHelper.instance.getRecieptsByInvoiceId(invoiceId);
    double settleAmount = 0.00;
    if (recieptList.isNotEmpty) {
      settleAmount = recieptList.last.paid! < recieptList.last.netTotal!
          ? recieptList.last.paid!
          : recieptList.last.netTotal!;
    }
    print('balanceAMT - ${(settleAmount - netAmount).abs()}');
    return (settleAmount - netAmount).abs();
  }

  getSettleAmountForReciept(String recieptId) async {
    Reciept reciept =
        await DatabaseHelper.instance.getRecieptsByRecieptId(recieptId);
    if (reciept.netTotal! > reciept.selectedAmount!) {
      return reciept.selectedAmount!;
    } else {
      return reciept.netTotal!;
    }
  }

  getBalanceAmountForReciept(String recieptId, double recieptAmount) async {
    double settleAmount = await getSettleAmountForReciept(recieptId);
    return (recieptAmount - settleAmount).abs().toDouble();
  }

  getChequeByRecieptId(List<Cheque> chequeList, String recieptId) {
    return chequeList.firstWhere((element) {
      return element.recieptId == recieptId;
    });
  }

  getCustomerByInvoiceId(String invoiceId) async {
    String? userId = await Settings.getUserID();
    List<Invoice> invoiceList =
        await DatabaseHelper.instance.getAllInvoices(userId!);
    Invoice invoice = invoiceList.firstWhere((inv) {
      return inv.invoiceId == invoiceId;
    });
    Customer customer = await DatabaseHelper.instance
        .getCustomersByCustomerId(invoice.chtAccAccNo!);
    return customer;
  }

  getLastInvoiceId() async {
    String? userId = await Settings.getUserID();
    List<Invoice> invoiceList =
        await DatabaseHelper.instance.getAllInvoices(userId!);
    if (invoiceList.isNotEmpty) {
      invoiceList.sort((a, b) => a.id!.compareTo(b.id!));
      return invoiceList.last.id;
    } else {
      return 0;
    }
  }

  getLastRecieptId() async {
    List<Reciept> recieptList = await DatabaseHelper.instance.getAllReciepts();
    if (recieptList.isNotEmpty) {
      recieptList.sort((a, b) => a.id!.compareTo(b.id!));
      return recieptList.last.id;
    } else {
      return 0;
    }
  }

  Future<bool> verifyTourClose({
  required String ginNo,
  required String dateTime,
  required List<InvoiceSaveBody> invoiceList,
  required List<RecieptSaveBody> receiptList,
  required List<SettlementSaveBody> settlementList,
}) async {
  String accessToken = await Settings.getAccessToken();

  final url = Uri.parse(
      '$BASER_URL/tapi/$TENENT/mobile/mobileSales/TourCloseDocumentVarification');

  final body = {
    'groupGinNo': ginNo,
    'dateTime': dateTime,

    'invoList': invoiceList.map((invoice) {
      return {
        'documentNo': invoice.invoiceNo,
        'totalAmount': invoice.mainAmt ?? 0,
      };
    }).toList(),

    'receList': receiptList.map((receipt) {
      return {
        'receiptNo': receipt.receiptNo,
        'amount': receipt.amount ?? 0,
      };
    }).toList(),

    'settleList': settlementList.map((settlement) {
      return {
        'invoiceNo': settlement.invoiceNo,
        'receiptNo': settlement.receiptNo,
        'settleAmount': settlement.settleAmount ?? 0,
      };
    }).toList(),
  };

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body),
    );

    print('TourCloseDocumentVarification');
    print(url);
    print(jsonEncode(body));
    print(response.body);

    if (response.statusCode != 200) {
      return false;
    }

    final result = int.tryParse(response.body);

    // Server returns a negative value when verification fails.
    if (result != null && result < 0) {
      return false;
    }

    return true;
  } catch (error) {
    print('Tour close verification error: $error');
    return false;
  }
}

Future<bool> updateDocAttributeMaster({
  required int repCode,
  required int invLastNo,
  required int cashReceLastNo,
  required int bankReceLastNo,
  required int returnLastNo,
}) async {
  String accessToken = await Settings.getAccessToken();

  final url = Uri.parse(
      '$BASER_URL/tapi/$TENENT/mobile/mobileSales/UpdateDocAttributeMaster');

  final body = {
    'repCode': repCode,
    'invLastNo': invLastNo,
    'cashReceLastNo': cashReceLastNo,
    'bankReceLastNo': bankReceLastNo,
    'returnLastNo': returnLastNo,
  };

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body),
    );

    print('UpdateDocAttributeMaster');
    print(url);
    print(jsonEncode(body));
    print(response.body);

    if (response.statusCode != 200) {
      return false;
    }

    final result = int.tryParse(response.body);

    if (result != null && result < 0) {
      return false;
    }

    return true;
  } catch (error) {
    print('Update document attributes error: $error');
    return false;
  }
}
}
