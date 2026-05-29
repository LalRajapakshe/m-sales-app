class Price {
  int? prTbPriceTableCode;
  int? prTbItemCode;
  double? price;
  String? prTbBatchCOde;
  String? priceType;
  String? userId;

  Price(
      {this.prTbPriceTableCode,
      this.prTbItemCode,
      this.price,
      this.prTbBatchCOde,
      this.userId});

  Price.fromJson(Map<String, dynamic> json) {
    prTbPriceTableCode = json['prTbPriceTableCode'];
    prTbItemCode = json['prTbItemCode'];
    price = double.tryParse(json['price'].toString());
    priceType = json['priceType'];
    prTbBatchCOde = json['prTbBatchCOde'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['prTbPriceTableCode'] = prTbPriceTableCode;
    data['prTbItemCode'] = prTbItemCode;
    data['price'] = price;
    data['priceType'] = priceType;
    data['prTbBatchCOde'] = prTbBatchCOde;
    data['userId'] = userId;
    return data;
  }
}
