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
      print(url);
      print(jsonEncode(body));
      // for (var element in bodyList) {
      //   print(element.toJson());
      //   for (var elementItm in element.lineItems!) {
      //     print(elementItm.toJson());
      //   }
      // }
      print('response');
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
        await DatabaseHelper.instance.insertDoc(_docDetailsResponse);
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
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

    String? tripCode = await Settings.getGinStuHdrFgnRefCode();
    List<InvoiceSaveBody> finalInvoiceList = [];
    for (var inv in invoiceList) {
      Customer customer = await DatabaseHelper.instance
          .getCustomersByCustomerId(inv.chtAccAccNo!);
      List<Item> itemList = [];
      for (var itm in inv.items!) {
        itemList.add(Item(
            headerId: inv.items!.indexOf(itm),
            itemCode: itm.item!.ginStuAlise,
            itemId: itm.item!.ginStuItemCode,
            itemName: itm.item!.ginStuName,
            unitId: 0,
            unitPrice: itm.item!.itMstDefualtPrice,
            lineNo: 0,
            quantity: itm.selectedQuantity,
            vatAmount: getVatForItem(itm.item!.itMstDefualtPrice!,
                inv.vatIncExc!, inv.tax! != 0.00 ? true : false),
            grossAmount: inv.tax! != 0.00
                ? itm.item!.itMstDefualtPrice! -
                    getVatForItem(itm.item!.itMstDefualtPrice!, inv.vatIncExc!,
                        inv.tax! != 0.00 ? true : false)
                : itm.item!.itMstDefualtPrice!,
            netAmount: itm.item!.itMstDefualtPrice,
            isSync: true));
      }
      var timeFormat = DateFormat("HH:mm");
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
          docTime: timeFormat.format(DateTime.now()),
          locationId: int.tryParse(userId),
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

  getAllReceipts() async {
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
}
