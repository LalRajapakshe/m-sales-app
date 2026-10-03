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
    prTbPriceTableCode = _jsonInt(json['prTbPriceTableCode']);
    prTbItemCode = _jsonInt(json['prTbItemCode']);
    price = _jsonDouble(json['price']);
    priceType = _jsonString(json['priceType']);
    prTbBatchCOde = _jsonString(json['prTbBatchCOde']);
    userId = _jsonString(json['userId']);
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

double? _jsonDouble(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value.toString().trim());
}

String? _jsonString(dynamic value) {
  if (value == null) {
    return null;
  }
  return value.toString();
}
