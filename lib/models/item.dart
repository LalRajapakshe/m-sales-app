class ItemTableItem {
  int? itMstCode;
  int? itMstGrpCode;
  String? itMstDescription;
  String? itMstAlias;
  int? itMstDefaultMesUnt;
  String? itMstDeactivate;
  String? itMstBinNo;
  String? itMstBarCode;
  double? itMstDefaultPrice;
  double? itMstWeiPktConvertionRatio;
  double? itMasLowestPrice;
  String? userId;

  ItemTableItem(
      {this.itMstCode,
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
      this.userId});

  ItemTableItem.fromJson(Map<String, dynamic> json) {
    itMstCode = json['itMstCode'];
    itMstGrpCode = json['itMstGrpCode'];
    itMstDescription = json['itMstDescription'];
    itMstAlias = json['itMstAlias'];
    itMstDefaultMesUnt = json['itMstDefaultMesUnt'];
    itMstDeactivate = json['itMstDeactivate'];
    itMstBinNo = json['itMstBinNo'];
    itMstBarCode = json['itMstBarCode'];
    itMstDefaultPrice = double.tryParse(json['itMstDefaultPrice'].toString());
    itMstWeiPktConvertionRatio =
        double.tryParse(json['itMstWeiPktConvertionRatio'].toString());
    itMasLowestPrice = double.tryParse(json['itMasLowestPrice'].toString());
    userId = json['userId'];
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
    data['userId'] = userId;
    return data;
  }

  @override
  String toString() {
    return 'ItemTableItem(itMstCode: $itMstCode, itMstGrpCode: $itMstGrpCode, itMstDescription: $itMstDescription, '
        'itMstAlias: $itMstAlias, itMstDefaultMesUnt: $itMstDefaultMesUnt, itMstDeactivate: $itMstDeactivate, '
        'itMstBinNo: $itMstBinNo, itMstBarCode: $itMstBarCode, itMstDefaultPrice: $itMstDefaultPrice, '
        'itMstWeiPktConvertionRatio: $itMstWeiPktConvertionRatio, itMasLowestPrice: $itMasLowestPrice, userId: $userId)';
  }
}
