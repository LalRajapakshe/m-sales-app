import 'package:m_sales/models/gin_response.dart';

class Invoice {
  int? id;
  String? vatIncExc;
  double? totalQty;
  double? grossTotal;
  double? tax;
  double? netTotal;
  String? chtAccAccNo;
  List<LineItemsSelected>? items;
  String? userId;
  String? dateTime;
  String? invoiceId;
  String? payMode;
  String? isReturn;

  Invoice(
      {this.id,
      this.vatIncExc,
      this.totalQty,
      this.grossTotal,
      this.tax,
      this.netTotal,
      this.chtAccAccNo,
      this.items,
      this.userId,
      this.dateTime,
      this.invoiceId,
      this.payMode,
      this.isReturn});

  Invoice.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    vatIncExc = json['vatIncExc'];
    totalQty = double.tryParse(json['totalQty'].toString());
    grossTotal = json['grossTotal'];
    tax = json['tax'];
    netTotal = json['netTotal'];
    chtAccAccNo = json['chtAccAccNo'];
    userId = json['userId'];
    if (json['items'] != null) {
      items = <LineItemsSelected>[];
      json['items'].forEach((v) {
        items!.add(LineItemsSelected.fromJson(v));
      });
    }
    userId = json['userId'];
    dateTime = json['dateTime'];
    invoiceId = json['invoiceId'];
    payMode = json['payMode'];
    isReturn = json['isReturn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['vatIncExc'] = vatIncExc;
    data['totalQty'] = totalQty;
    data['grossTotal'] = grossTotal;
    data['tax'] = tax;
    data['netTotal'] = netTotal;
    data['chtAccAccNo'] = chtAccAccNo;
    data['userId'] = userId;
    if (items != null) {
      data['lineItems'] = items!.map((v) => v.toJson()).toList();
    }
    data['userId'] = userId;
    data['dateTime'] = dateTime;
    data['invoiceId'] = invoiceId;
    data['payMode'] = payMode;
    data['isReturn'] = isReturn;
    return data;
  }
}

class InvoiceDB {
  int? id;
  String? vatIncExc;
  double? totalQty;
  double? grossTotal;
  double? tax;
  double? netTotal;
  String? chtAccAccNo;
  String? userId;
  String? dateTime;
  String? invoiceId;
  String? payMode;
  String? isReturn;

  InvoiceDB(
      {this.id,
      this.vatIncExc,
      this.totalQty,
      this.grossTotal,
      this.tax,
      this.netTotal,
      this.chtAccAccNo,
      this.userId,
      this.dateTime,
      this.invoiceId,
      this.payMode,
      this.isReturn});

  InvoiceDB.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    vatIncExc = json['vatIncExc'];
    totalQty = double.tryParse(json['totalQty'].toString());
    grossTotal = json['grossTotal'];
    tax = json['tax'];
    netTotal = json['netTotal'];
    chtAccAccNo = json['chtAccAccNo'];
    userId = json['userId'];
    dateTime = json['dateTime'];
    invoiceId = json['invoiceId'];
    payMode = json['payMode'];
    isReturn = json['isReturn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['vatIncExc'] = vatIncExc;
    data['totalQty'] = totalQty;
    data['grossTotal'] = grossTotal;
    data['tax'] = tax;
    data['netTotal'] = netTotal;
    data['chtAccAccNo'] = chtAccAccNo;
    data['userId'] = userId;
    data['dateTime'] = dateTime;
    data['invoiceId'] = invoiceId;
    data['payMode'] = payMode;
    data['isReturn'] = isReturn;
    return data;
  }
}
