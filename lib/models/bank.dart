class BankAndCode {
  String? bankName;
  String? bankCode;

  BankAndCode({this.bankName, this.bankCode});

  BankAndCode.fromJson(Map<String, dynamic> json) {
    bankName = json['bankName'];
    bankCode = json['bankCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bankName'] = bankName;
    data['bankCode'] = bankCode;

    return data;
  }

  factory BankAndCode.empty() => BankAndCode(
    bankCode: '',
    bankName: ''
  );
}

class Bank {
  String? bankNo;
  String? branchNo;
  String? branchName;
  String? userId;
  int? id;

  Bank({this.bankNo, this.branchNo, this.branchName, this.userId, this.id});

  Bank.fromJson(Map<String, dynamic> json) {
    bankNo = json['bankNo'];
    branchNo = json['branchNo'];
    branchName = json['branchName'];
    userId = json['userId'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bankNo'] = bankNo;
    data['branchNo'] = branchNo;
    data['branchName'] = branchName;
    data['userId'] = userId;
    data['id'] = id;
    return data;
  }
}
