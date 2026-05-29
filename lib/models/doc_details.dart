class DocDetails {
  int? repCode;
  String? repShortCode;
  String? repName;
  String? invCode;
  String? cashReceCode;
  String? bankReceCode;
  String? returnCode;
  int? invLastNo;
  int? cashReceLastNo;
  int? bankReceLastNo;
  int? returnLastNo;
  int? docNoLength;

  DocDetails(
      {this.repCode,
      this.repShortCode,
      this.repName,
      this.invCode,
      this.cashReceCode,
      this.bankReceCode,
      this.returnCode,
      this.invLastNo,
      this.cashReceLastNo,
      this.bankReceLastNo,
      this.returnLastNo,
      this.docNoLength});

  DocDetails.fromJson(Map<String, dynamic> json) {
    repCode = json['repCode'];
    repShortCode = json['repShortCode'];
    repName = json['repName'];
    invCode = json['invCode'];
    cashReceCode = json['cashReceCode'];
    bankReceCode = json['bankReceCode'];
    returnCode = json['returnCode'];
    invLastNo = json['invLastNo'];
    cashReceLastNo = json['cashReceLastNo'];
    bankReceLastNo = json['bankReceLastNo'];
    returnLastNo = json['returnLastNo'];
    docNoLength = json['docNoLength'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['repCode'] = repCode;
    data['repShortCode'] = repShortCode;
    data['repName'] = repName;
    data['invCode'] = invCode;
    data['cashReceCode'] = cashReceCode;
    data['bankReceCode'] = bankReceCode;
    data['returnCode'] = returnCode;
    data['invLastNo'] = invLastNo;
    data['cashReceLastNo'] = cashReceLastNo;
    data['bankReceLastNo'] = bankReceLastNo;
    data['returnLastNo'] = returnLastNo;
    data['docNoLength'] = docNoLength;
    return data;
  }

  factory DocDetails.empty() => DocDetails(
      repCode: 0,
      repShortCode: "",
      repName: "",
      invCode: '',
      cashReceCode: '',
      bankReceCode: '',
      returnCode: '',
      invLastNo: 0,
      cashReceLastNo: 0,
      bankReceLastNo: 0,
      returnLastNo: 0,
      docNoLength: 0);
}
