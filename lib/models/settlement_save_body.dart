class SettlementSaveBody {
  int? settleId;
  String? invoiceNo;
  String? receiptNo;
  String? docDate;
  double? settleAmount;

  SettlementSaveBody(
      {this.settleId,
      this.invoiceNo,
      this.receiptNo,
      this.docDate,
      this.settleAmount});

  SettlementSaveBody.fromJson(Map<String, dynamic> json) {
    settleId = json['settleId'];
    invoiceNo = json['invoiceNo'];
    receiptNo = json['receiptNo'];
    docDate = json['docDate'];
    settleAmount = json['settleAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['settleId'] = settleId;
    data['invoiceNo'] = invoiceNo;
    data['receiptNo'] = receiptNo;
    data['docDate'] = docDate;
    data['settleAmount'] = settleAmount;
    return data;
  }
}
