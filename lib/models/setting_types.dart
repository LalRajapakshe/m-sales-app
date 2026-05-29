class SettingTypes {
  double? vatAmount;
  String? vattype;
  String? batchBase;
  String? payModeBase;
  String? userId;
  String? tenent;
  String? unitRate;
  String? baseUrl;
  String? invoiceCheck;
  String? companyVatNo;

  String? companyName;
  String? address;
  String? tel;
  String? hotline;
  String? email;
  String? web;
  String? invttl1;
  String? invttl2;

  SettingTypes({
    this.vatAmount,
    this.vattype,
    this.batchBase,
    this.payModeBase,
    this.userId,
    this.tenent,
    this.unitRate,
    this.baseUrl,
    this.invoiceCheck,
    this.companyName,
    this.address,
    this.tel,
    this.hotline,
    this.email,
    this.web,
    this.invttl1,
    this.invttl2,
    this.companyVatNo,
  });

  SettingTypes.fromJson(Map<String, dynamic> json) {
    vatAmount = json['vatAmount'];
    vattype = json['vattype'];
    batchBase = json['batchBase'];
    payModeBase = json['payModeBase'];
    userId = json['userId'];
    tenent = json['tenent'];
    unitRate = json['unitRate'];
    baseUrl = json['baseUrl'];
    invoiceCheck = json['invoiceCheck'];
    companyVatNo = json['companyVatNo'];
    companyName = json['companyName'];
    address = json['address'];
    tel = json['tel'];
    hotline = json['hotline'];
    email = json['email'];
    web = json['web'];
    invttl1 = json['invttl1'];
    invttl2 = json['invttl2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['vatAmount'] = vatAmount;
    data['vattype'] = vattype;
    data['batchBase'] = batchBase;
    data['payModeBase'] = payModeBase;
    data['userId'] = userId;
    data['tenent'] = tenent;
    data['unitRate'] = unitRate;
    data['baseUrl'] = baseUrl;
    data['invoiceCheck'] = invoiceCheck;
    data['companyVatNo'] = companyVatNo;
    data['companyName'] = companyName;
    data['address'] = address;
    data['tel'] = tel;
    data['hotline'] = hotline;
    data['email'] = email;
    data['web'] = web;
    data['invttl1'] = invttl1;
    data['invttl2'] = invttl2;

    return data;
  }

  factory SettingTypes.empty() => SettingTypes(
        vatAmount: 0.00,
        vattype: 'VAT_INCLUDE',
        batchBase: 'NO',
        payModeBase: 'NO',
        userId: '',
        tenent: '',
        baseUrl: 'http://124.43.177.143/SFA/',
        companyName: '',
        address: '',
        tel: '',
        hotline: '',
        email: '',
      );

  @override
  String toString() {
    return 'SettingTypes(vatAmount: $vatAmount, vattype: $vattype, batchBase: $batchBase, payModeBase: $payModeBase, userId: $userId, tenent: $tenent,baseUrl : $baseUrl , companyVatNo : $companyVatNo companyName: $companyName, address: $address, tel: $tel, hotline: $hotline, email: $email, web: $web, invttl1: $invttl1, invttl2: $invttl2, invoiceCheck: $invoiceCheck)';
  }
}
