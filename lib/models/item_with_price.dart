class ItemWithPrice {
  int? itMstCode;
  int? itMstGrpCode;
  String? itMstDescription;
  String? itMstAlias;
  int? itMstDefaultMesUnt;
  String? itMstDeactivate;
  String? itMstBinNo;
  String? itMstBarCode;
  int? itMstDefaultPrice;
  int? itMstWeiPktConvertionRatio;
  int? itMasLowestPrice;
  String? userId;
  int? prTbPriceTableCode;
  int? prTbItemCode;
  double? prCashPrice;
  double? prCreditPrice;
  double? prChequePrice;
  double? prVatLowestPrice;
  double? prNonVatLowestPrice;

  ItemWithPrice({
    this.itMstCode,
    this.itMstGrpCode,
    this.itMstDescription,
    this.itMstAlias,
    this.itMstDefaultMesUnt,
    this.itMstDeactivate,
    this.itMstBinNo,
    this.itMstBarCode,
    this.itMstDefaultPrice,
    this.itMstWeiPktConvertionRatio,
    this.itMasLowestPrice,
    this.userId,
    this.prTbPriceTableCode,
    this.prTbItemCode,
    this.prCashPrice,
    this.prCreditPrice,
    this.prChequePrice,
    this.prVatLowestPrice,
    this.prNonVatLowestPrice,
  });

  ItemWithPrice.fromJson(Map<String, dynamic> json) {
    itMstCode = json['itMstCode'];
    itMstGrpCode = json['itMstGrpCode'];
    itMstDescription = json['itMstDescription'];
    itMstAlias = json['itMstAlias'];
    itMstDefaultMesUnt = json['itMstDefaultMesUnt'];
    itMstDeactivate = json['itMstDeactivate'];
    itMstBinNo = json['itMstBinNo'];
    itMstBarCode = json['itMstBarCode'];
    itMstDefaultPrice = json['itMstDefaultPrice'];
    itMstWeiPktConvertionRatio = json['itMstWeiPktConvertionRatio'];
    itMasLowestPrice = json['itMasLowestPrice'];
    userId = json[userId];
    prTbPriceTableCode = json['prTbPriceTableCode'];
    prTbItemCode = json['prTbItemCode'];
    prCashPrice = json['prCashPrice'];
    prCreditPrice = json['prCreditPrice'];
    prChequePrice = json['prChequePrice'];
    prVatLowestPrice = json['prVatLowestPrice'];
    prNonVatLowestPrice = json['prNonVatLowestPrice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['itMstCode'] = itMstCode;
    data['itMstGrpCode'] = itMstGrpCode;
    data['itMstDescription'] = itMstDescription;
    data['itMstAlias'] = itMstAlias;
    data['itMstDefaultMesUnt'] = itMstDefaultMesUnt;
    data['itMstDeactivate'] = itMstDeactivate;
    data['itMstBinNo'] = itMstBinNo;
    data['itMstBarCode'] = itMstBarCode;
    data['itMstDefaultPrice'] = itMstDefaultPrice;
    data['itMstWeiPktConvertionRatio'] = itMstWeiPktConvertionRatio;
    data['itMasLowestPrice'] = itMasLowestPrice;
    data['prTbPriceTableCode'] = prTbPriceTableCode;
    data['prTbItemCode'] = prTbItemCode;
    data['prCashPrice'] = prCashPrice;
    data['prCreditPrice'] = prCreditPrice;
    data['prChequePrice'] = prChequePrice;
    data['prVatLowestPrice'] = prVatLowestPrice;
    data['prNonVatLowestPrice'] = prNonVatLowestPrice;
    data['userId'] = userId;

    return data;
  }
}
