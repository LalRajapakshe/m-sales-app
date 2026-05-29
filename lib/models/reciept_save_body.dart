class RecieptSaveBody {
  int? receiptId;
  String? receiptNo;
  String? docDate;
  String? status;
  int? customerId;
  String? customerCode;
  String? customerName;
  String? payMode;
  double? amount;
  double? balanceAmount;
  String? bankCode;
  String? branchCode;
  String? chequeNo;
  String? chequeDate;
  String? accountNo;
  bool? isSync;

  RecieptSaveBody(
      {this.receiptId,
      this.receiptNo,
      this.docDate,
      this.status,
      this.customerId,
      this.customerCode,
      this.customerName,
      this.payMode,
      this.amount,
      this.balanceAmount,
      this.bankCode,
      this.branchCode,
      this.chequeNo,
      this.chequeDate,
      this.accountNo,
      this.isSync});

  RecieptSaveBody.fromJson(Map<String, dynamic> json) {
    receiptId = json['receiptId'];
    receiptNo = json['receiptNo'];
    docDate = json['docDate'];
    status = json['status'];
    customerId = json['customerId'];
    customerCode = json['customerCode'];
    customerName = json['customerName'];
    payMode = json['payMode'];
    amount = json['amount'];
    balanceAmount = json['balanceAmount'];
    bankCode = json['bankCode'];
    branchCode = json['branchCode'];
    chequeNo = json['chequeNo'];
    chequeDate = json['chequeDate'];
    accountNo = json['accountNo'];
    isSync = json['isSync'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['receiptId'] = receiptId;
    data['receiptNo'] = receiptNo;
    data['docDate'] = docDate;
    data['status'] = status;
    data['customerId'] = customerId;
    data['customerCode'] = customerCode;
    data['customerName'] = customerName;
    data['payMode'] = payMode;
    data['amount'] = amount;
    data['balanceAmount'] = balanceAmount;
    data['bankCode'] = bankCode;
    data['branchCode'] = branchCode;
    data['chequeNo'] = chequeNo;
    data['chequeDate'] = chequeDate;
    data['accountNo'] = accountNo;
    data['isSync'] = isSync;
    return data;
  }
}
