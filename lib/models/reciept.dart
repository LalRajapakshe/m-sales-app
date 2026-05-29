class Reciept {
  int? id;
  String? invoiceId;
  double? paid;
  double? balance;
  double? netTotal;
  double? cashAmount;
  double? creditAmount;
  String? dateTime;
  String? priceType;
  String? recieptId;
  String? payMode;
  String? userId;
  String? bankCode;
  String? branchCode;
  String? chequeNo;
  String? chequeDate;
  String? accountNo;
  double? chequeAmount;
  double? selectedAmount;
  int? chtAccAccNo;

  Reciept(
      {this.id,
      this.invoiceId,
      this.balance,
      this.netTotal,
      this.recieptId,
      this.paid,
      this.cashAmount,
      this.creditAmount,
      this.dateTime,
      this.priceType,
      this.payMode,
      this.userId,
      this.accountNo,
      this.bankCode,
      this.branchCode,
      this.chequeDate,
      this.chequeNo,
      this.chequeAmount,
      this.selectedAmount,
      this.chtAccAccNo});

  Reciept.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    invoiceId = json['invoiceId'];
    balance = double.tryParse(json['balance'].toString());
    netTotal = double.tryParse(json['netTotal'].toString());
    paid = double.tryParse(json['paid'].toString());
    cashAmount = double.tryParse(json['cashAmount'].toString());
    creditAmount = double.tryParse(json['creditAmount'].toString());
    dateTime = json['dateTime'];
    priceType = json['priceType'];
    recieptId = json['recieptId'];
    payMode = json['payMode'];
    userId = json['userId'];
    bankCode = json['bankCode'];
    branchCode = json['branchCode'];
    chequeNo = json['chequeNo'];
    chequeDate = json['chequeDate'];
    accountNo = json['accountNo'];
    chequeAmount = json['chequeAmount'];
    selectedAmount = json['selectedAmount'];
    chtAccAccNo = int.tryParse(json['chtAccAccNo'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['invoiceId'] = invoiceId;
    data['balance'] = balance;
    data['netTotal'] = netTotal;
    data['paid'] = paid;
    data['cashAmount'] = cashAmount;
    data['creditAmount'] = creditAmount;
    data['dateTime'] = dateTime;
    data['priceType'] = priceType;
    data['recieptId'] = recieptId;
    data['payMode'] = payMode;
    data['userId'] = userId;
    data['bankCode'] = bankCode;
    data['branchCode'] = branchCode;
    data['chequeNo'] = chequeNo;
    data['chequeDate'] = chequeDate;
    data['accountNo'] = accountNo;
    data['chequeAmount'] = chequeAmount;
    data['selectedAmount'] = selectedAmount;
    data['chtAccAccNo'] = chtAccAccNo;
    return data;
  }
}
