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
    repCode = _jsonInt(json['repCode']);
    repShortCode = _jsonString(json['repShortCode']);
    repName = _jsonString(json['repName']);
    invCode = _jsonString(json['invCode']);
    cashReceCode = _jsonString(json['cashReceCode']);
    bankReceCode = _jsonString(json['bankReceCode']);
    returnCode = _jsonString(json['returnCode']);
    invLastNo = _jsonInt(json['invLastNo']);
    cashReceLastNo = _jsonInt(json['cashReceLastNo']);
    bankReceLastNo = _jsonInt(json['bankReceLastNo']);
    returnLastNo = _jsonInt(json['returnLastNo']);
    docNoLength = _jsonInt(json['docNoLength']);
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

int? _jsonInt(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value.toString().trim());
}

String? _jsonString(dynamic value) {
  if (value == null) {
    return null;
  }
  return value.toString();
}
