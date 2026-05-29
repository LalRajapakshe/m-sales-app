class Customer {
  String? userId;
  int? chtAccAccNo;
  String? chtAccName;
  int? chtAccType;
  int? chtAccGroupCode;
  double? chtAccCreditLimit;
  int? chtAccCreditPeriod;
  int? chtAccRepRefCode;
  int? chtAccPriceTblCode;
  int? chtAccAreaCode;
  String? chtAccAlias;
  int? chtAccRegNo;
  String? chtAccAddress;
  int? infoCustomerCategory;
  int? chtCustStateCode;
  String? chtAccWithCustVat;
  String? emiNo;

  Customer(
      {this.userId,
      this.chtAccAccNo,
      this.chtAccName,
      this.chtAccType,
      this.chtAccGroupCode,
      this.chtAccCreditLimit,
      this.chtAccCreditPeriod,
      this.chtAccRepRefCode,
      this.chtAccPriceTblCode,
      this.chtAccAreaCode,
      this.chtAccAlias,
      this.chtAccRegNo,
      this.chtAccAddress,
      this.infoCustomerCategory,
      this.chtCustStateCode,
      this.chtAccWithCustVat,
      this.emiNo});

  Customer.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    chtAccAccNo = json['chtAccAccNo'];
    chtAccName = json['chtAccName'];
    chtAccType = json['chtAccType'];
    chtAccGroupCode = json['chtAccGroupCode'];
    chtAccCreditLimit = double.tryParse(json['chtAccCreditLimit'].toString());
    chtAccCreditPeriod = json['chtAccCreditPeriod'];
    chtAccRepRefCode = json['chtAccRepRefCode'];
    chtAccPriceTblCode = json['chtAccPriceTblCode'];
    chtAccAreaCode = json['chtAccAreaCode'];
    chtAccAlias = json['chtAccAlias'];
    chtAccRegNo = json['chtAccRegNo'];
    chtAccAddress = json['chtAccAddress'];
    infoCustomerCategory = json['infoCustomerCategory'];
    chtCustStateCode = json['chtCustStateCode'];
    chtAccWithCustVat = json['chtAccWithCustVat'];
    emiNo = json['emiNo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['chtAccAccNo'] = chtAccAccNo;
    data['chtAccName'] = chtAccName;
    data['chtAccType'] = chtAccType;
    data['chtAccGroupCode'] = chtAccGroupCode;
    data['chtAccCreditLimit'] = chtAccCreditLimit;
    data['chtAccCreditPeriod'] = chtAccCreditPeriod;
    data['chtAccRepRefCode'] = chtAccRepRefCode;
    data['chtAccPriceTblCode'] = chtAccPriceTblCode;
    data['chtAccAreaCode'] = chtAccAreaCode;
    data['chtAccAlias'] = chtAccAlias;
    data['chtAccRegNo'] = chtAccRegNo;
    data['chtAccAddress'] = chtAccAddress;
    data['infoCustomerCategory'] = infoCustomerCategory;
    data['chtCustStateCode'] = chtCustStateCode;
    data['chtAccWithCustVat'] = chtAccWithCustVat;
    data['emiNo'] = emiNo;
    return data;
  }
}
