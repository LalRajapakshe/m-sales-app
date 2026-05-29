class DueBill {
  int? dueBilCustCode;
  String? dueBilCustName;
  String? dueBilSustAlise;
  String? dueBilBillNo;
  int? dueBilBillAmt;
  int? dueBilDueAmt;
  String? dueBillDrCrFlag;
  int? dueBillLnNo;
  int? dueBillRepCode;
  String? dueBillEmiNo;
  String? userId;
  int? id;

  DueBill(
      {this.dueBilCustCode,
      this.dueBilCustName,
      this.dueBilSustAlise,
      this.dueBilBillNo,
      this.dueBilBillAmt,
      this.dueBilDueAmt,
      this.dueBillDrCrFlag,
      this.dueBillLnNo,
      this.dueBillRepCode,
      this.dueBillEmiNo,
      this.userId,
      this.id});

  DueBill.fromJson(Map<String, dynamic> json) {
    dueBilCustCode = json['dueBilCustCode'];
    dueBilCustName = json['dueBilCustName'];
    dueBilSustAlise = json['dueBilSustAlise'];
    dueBilBillNo = json['dueBilBillNo'];
    dueBilBillAmt = json['dueBilBillAmt'];
    dueBilDueAmt = json['dueBilDueAmt'];
    dueBillDrCrFlag = json['dueBillDrCrFlag'];
    dueBillLnNo = json['dueBillLnNo'];
    dueBillRepCode = json['dueBillRepCode'];
    dueBillEmiNo = json['dueBillEmiNo'];
    userId = json['userId'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dueBilCustCode'] = dueBilCustCode;
    data['dueBilCustName'] = dueBilCustName;
    data['dueBilSustAlise'] = dueBilSustAlise;
    data['dueBilBillNo'] = dueBilBillNo;
    data['dueBilBillAmt'] = dueBilBillAmt;
    data['dueBilDueAmt'] = dueBilDueAmt;
    data['dueBillDrCrFlag'] = dueBillDrCrFlag;
    data['dueBillLnNo'] = dueBillLnNo;
    data['dueBillRepCode'] = dueBillRepCode;
    data['dueBillEmiNo'] = dueBillEmiNo;
    data['userId'] = userId;
    data['id'] = id;
    return data;
  }
}
