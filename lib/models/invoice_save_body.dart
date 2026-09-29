class InvoiceSaveBody {
  int? invoiceId;
  String? invoiceNo;
  String? docDate;
  String? docType;
  int? customerId;
  String? customerCode;
  String? customerName;
  String? status;
  String? tripCode;
  String? payMode;
  String? docTime;
  int? locationId;
  int? printCount;
  int? lineNo;
  List<Item>? lineItems;
  double? mainAmt;
  double? balanceAmt;
  bool? isSync;

  InvoiceSaveBody(
      {this.invoiceId,
      this.invoiceNo,
      this.docDate,
      this.docType,
      this.customerId,
      this.customerCode,
      this.customerName,
      this.status,
      this.locationId,
      this.docTime,
      this.tripCode,
      this.payMode,
      this.printCount,
      this.lineNo,
      this.lineItems,
      this.mainAmt,
      this.balanceAmt,
      this.isSync});

  InvoiceSaveBody.fromJson(Map<String, dynamic> json) {
    invoiceId = json['invoiceId'];
    invoiceNo = json['invoiceNo'];
    docDate = json['docDate'];
    docType = json['docType'];
    customerId = json['customerId'];
    customerCode = json['customerCode'];
    customerName = json['customerName'];
    locationId = json['locationId'];
    status = json['status'];
    docTime = json['docTime'];
    tripCode = json['tripCode'];
    payMode = json['payMode'];
    printCount = json['printCount'];
    lineNo = json['lineNo'];
    mainAmt = json['mainAmt'];
    balanceAmt = json['balanceAmt'];
    isSync = json['isSync'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['invoiceId'] = invoiceId;
    data['invoiceNo'] = invoiceNo;
    data['docDate'] = docDate;
    data['docType'] = docType;
    data['customerId'] = customerId;
    data['customerCode'] = customerCode;
    data['customerName'] = customerName;
    data['status'] = status;
    data['tripCode'] = tripCode;
    data['docTime'] = docTime;
    data['locationId'] = locationId;
    if (lineItems != null) {
      data['lineItems'] = lineItems;
    }
    data['payMode'] = payMode;
    data['printCount'] = printCount;
    data['lineNo'] = lineNo;
    data['mainAmt'] = mainAmt;
    data['balanceAmt'] = balanceAmt;
    data['isSync'] = isSync;
    return data;
  }
}

class Item {
  int? headerId;
  int? lineNo;
  int? itemId;
  String? itemCode;
  String? itemName;
  double? unitPrice;
  int? unitId;
  double? quantity;
  double? vatAmount;
  double? grossAmount;
  double? netAmount;
  bool? isSync;

  Item(
      {this.headerId,
      this.lineNo,
      this.itemId,
      this.itemCode,
      this.itemName,
      this.unitPrice,
      this.unitId,
      this.quantity,
      this.vatAmount,
      this.grossAmount,
      this.netAmount,
      this.isSync});

  Item.fromJson(Map<String, dynamic> json) {
    headerId = json['headerId'];
    lineNo = json['lineNo'];
    itemId = json['itemId'];
    unitId = json['unitId'];
    itemCode = json['itemCode'];
    itemName = json['itemName'];
    unitPrice = json['unitPrice'];
    quantity = double.tryParse(json['quantity'].toString());
    vatAmount = json['vatAmount'];
    grossAmount = json['grossAmount'];
    netAmount = json['netAmount'];
    isSync = json['isSync'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['headerId'] = headerId;
    data['lineNo'] = lineNo;
    data['itemId'] = itemId;
    data['itemCode'] = itemCode;
    data['itemName'] = itemName;
    data['unitPrice'] = unitPrice;
    data['quantity'] = quantity;
    data['vatAmount'] = vatAmount;
    data['grossAmount'] = grossAmount;
    data['netAmount'] = netAmount;
    data['isSync'] = isSync;
    return data;
  }
}
