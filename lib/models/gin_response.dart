import 'dart:convert';

GinResponse ginResponseFromJson(str) => GinResponse.fromJson(json.decode(str));

class GinResponse {
  int? ginStuHdrId;
  int? ginNo;
  String? ginStuHdrGinNo;
  String? ginStuHdrDocType;
  int? ginStuHdrFrLocCode;
  int? ginStuHdrToLocCode;
  String? ginStuHdrDate;
  String? ginStuHdrRefCode;
  String? ginStuHdrFgnRefCode;
  String? ginStuHdrStatus;
  List<LineItems>? lineItems;
  String? userId;

  GinResponse(
      {this.ginStuHdrId,
      this.ginNo,
      this.ginStuHdrGinNo,
      this.ginStuHdrDocType,
      this.ginStuHdrFrLocCode,
      this.ginStuHdrToLocCode,
      this.ginStuHdrDate,
      this.ginStuHdrRefCode,
      this.ginStuHdrFgnRefCode,
      this.ginStuHdrStatus,
      this.lineItems,
      this.userId});

  GinResponse.fromJson(Map<String, dynamic> json) {
    ginStuHdrId = json['ginStuHdrId'];
    ginNo = json['ginNo'];
    ginStuHdrGinNo = json['ginStuHdrGinNo'];
    ginStuHdrDocType = json['ginStuHdrDocType'];
    ginStuHdrFrLocCode = json['ginStuHdrFrLocCode'];
    ginStuHdrToLocCode = json['ginStuHdrToLocCode'];
    ginStuHdrDate = json['ginStuHdrDate'];
    ginStuHdrRefCode = json['ginStuHdrRefCode'];
    ginStuHdrFgnRefCode = json['ginStuHdrFgnRefCode'];
    ginStuHdrStatus = json['ginStuHdrStatus'];
    if (json['lineItems'] != null) {
      lineItems = <LineItems>[];
      json['lineItems'].forEach((v) {
        lineItems!.add(LineItems.fromJson(v));
      });
    }
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ginStuHdrId'] = ginStuHdrId;
    data['ginNo'] = ginNo;
    data['ginStuHdrGinNo'] = ginStuHdrGinNo;
    data['ginStuHdrDocType'] = ginStuHdrDocType;
    data['ginStuHdrFrLocCode'] = ginStuHdrFrLocCode;
    data['ginStuHdrToLocCode'] = ginStuHdrToLocCode;
    data['ginStuHdrDate'] = ginStuHdrDate;
    data['ginStuHdrRefCode'] = ginStuHdrRefCode;
    data['ginStuHdrFgnRefCode'] = ginStuHdrFgnRefCode;
    data['ginStuHdrStatus'] = ginStuHdrStatus;
    if (lineItems != null) {
      data['lineItems'] = lineItems!.map((v) => v.toJson()).toList();
    }
    data['userId'] = userId;
    return data;
  }

  factory GinResponse.empty() {
    return GinResponse(
      ginStuHdrId: null,
      ginNo: null,
      ginStuHdrGinNo: null,
      ginStuHdrDocType: null,
      ginStuHdrFrLocCode: null,
      ginStuHdrToLocCode: null,
      ginStuHdrDate: null,
      ginStuHdrRefCode: null,
      ginStuHdrFgnRefCode: null,
      ginStuHdrStatus: null,
      lineItems: [],
      userId: null,
    );
  }
}

class LineItems {
  int? id;
  String? ginStuGinCode;
  String? ginBatchNo;
  int? ginStuItemCode;
  String? ginStuAlise;
  String? ginStuName;
  String? ginStuUnitName;
  double? ginStuQuantity;
  double? ginStuQuantityPkts;
  double? itMstDefualtPrice;
  String? ginStuHdrFgnRefCode;
  String? userId;
  double? handsOnQty;
  String? isFresh;
  String? isExpired;
  String? isDamaged;

  LineItems(
      {this.id,
      this.ginStuGinCode,
      this.ginBatchNo,
      this.ginStuItemCode,
      this.ginStuAlise,
      this.ginStuName,
      this.ginStuUnitName,
      this.ginStuQuantity,
      this.ginStuQuantityPkts,
      this.itMstDefualtPrice,
      this.ginStuHdrFgnRefCode,
      this.userId,
      this.handsOnQty,
      this.isFresh,
      this.isExpired,
      this.isDamaged});

  LineItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ginStuGinCode = json['ginStuGinCode'] ?? '';
    ginBatchNo = json['ginBatchNo'] ?? '';
    ginStuItemCode = json['ginStuItemCode'] ?? 0;
    ginStuAlise = json['ginStuAlise'] ?? '';
    ginStuName = json['ginStuName'] ?? '';
    ginStuUnitName = json['ginStuUnitName'] ?? '';
    ginStuQuantity =
        double.tryParse(json['ginStuQuantity'].toString().split('.').first) ??
            0.0;
    ginStuQuantityPkts = double.tryParse(
            json['ginStuQuantityPkts'].toString().split('.').first) ??
        0.0;
    itMstDefualtPrice = json['itMstDefualtPrice'] ?? 0.00;
    ginStuHdrFgnRefCode = json['ginStuHdrFgnRefCode'] ?? '';
    userId = json['userId'];
    handsOnQty = double.tryParse(json['handsOnQty'].toString()) ?? 0.00;
    isFresh = json['isFresh'];
    isExpired = json['isExpired'];
    isDamaged = json['isDamaged'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['ginStuGinCode'] = ginStuGinCode;
    data['ginBatchNo'] = ginBatchNo;
    data['ginStuItemCode'] = ginStuItemCode;
    data['ginStuAlise'] = ginStuAlise;
    data['ginStuName'] = ginStuName;
    data['ginStuUnitName'] = ginStuUnitName;
    data['ginStuQuantity'] = ginStuQuantity;
    data['ginStuQuantityPkts'] = ginStuQuantityPkts;
    data['itMstDefualtPrice'] = itMstDefualtPrice;
    data['ginStuHdrFgnRefCode'] = ginStuHdrFgnRefCode;
    data['userId'] = userId;
    data['handsOnQty'] = handsOnQty;
    data['isFresh'] = isFresh;
    data['isExpired'] = isExpired;
    data['isDamaged'] = isDamaged;
    return data;
  }
}

class GinResponseLocal {
  int? ginStuHdrId;
  int? ginNo;
  String? ginStuHdrGinNo;
  String? ginStuHdrDocType;
  int? ginStuHdrFrLocCode;
  int? ginStuHdrToLocCode;
  String? ginStuHdrDate;
  String? ginStuHdrRefCode;
  String? ginStuHdrFgnRefCode;
  String? ginStuHdrStatus;
  String? userId;

  GinResponseLocal(
      {this.ginStuHdrId,
      this.ginNo,
      this.ginStuHdrGinNo,
      this.ginStuHdrDocType,
      this.ginStuHdrFrLocCode,
      this.ginStuHdrToLocCode,
      this.ginStuHdrDate,
      this.ginStuHdrRefCode,
      this.ginStuHdrFgnRefCode,
      this.ginStuHdrStatus,
      this.userId});

  GinResponseLocal.fromJson(Map<String, dynamic> json) {
    ginStuHdrId = json['ginStuHdrId'];
    ginNo = json['ginNo'];
    ginStuHdrGinNo = json['ginStuHdrGinNo'];
    ginStuHdrDocType = json['ginStuHdrDocType'];
    ginStuHdrFrLocCode = json['ginStuHdrFrLocCode'];
    ginStuHdrToLocCode = json['ginStuHdrToLocCode'];
    ginStuHdrDate = json['ginStuHdrDate'];
    ginStuHdrRefCode = json['ginStuHdrRefCode'];
    ginStuHdrFgnRefCode = json['ginStuHdrFgnRefCode'];
    ginStuHdrStatus = json['ginStuHdrStatus'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ginStuHdrId'] = ginStuHdrId;
    data['ginNo'] = ginNo;
    data['ginStuHdrGinNo'] = ginStuHdrGinNo;
    data['ginStuHdrDocType'] = ginStuHdrDocType;
    data['ginStuHdrFrLocCode'] = ginStuHdrFrLocCode;
    data['ginStuHdrToLocCode'] = ginStuHdrToLocCode;
    data['ginStuHdrDate'] = ginStuHdrDate;
    data['ginStuHdrRefCode'] = ginStuHdrRefCode;
    data['ginStuHdrFgnRefCode'] = ginStuHdrFgnRefCode;
    data['ginStuHdrStatus'] = ginStuHdrStatus;
    data['userId'] = userId;
    return data;
  }

  factory GinResponseLocal.empty() {
    return GinResponseLocal(
      ginStuHdrId: null,
      ginNo: null,
      ginStuHdrGinNo: null,
      ginStuHdrDocType: null,
      ginStuHdrFrLocCode: null,
      ginStuHdrToLocCode: null,
      ginStuHdrDate: null,
      ginStuHdrRefCode: null,
      ginStuHdrFgnRefCode: null,
      ginStuHdrStatus: null,
      userId: null,
    );
  }
}

class LineItemsWithMinMax {
  int? id;
  String? ginStuGinCode;
  String? ginBatchNo;
  int? ginStuItemCode;
  String? ginStuAlise;
  String? ginStuName;
  String? ginStuUnitName;
  double? ginStuQuantity;
  double? ginStuQuantityPkts;
  double? itMstDefualtPrice;
  String? ginStuHdrFgnRefCode;
  String? userId;
  double? min;
  double? max;
  int? batchCount;
  double? selectedQty;
  double? handsOnQty;

  LineItemsWithMinMax(
      {this.id,
      this.ginStuGinCode,
      this.ginBatchNo,
      this.ginStuItemCode,
      this.ginStuAlise,
      this.ginStuName,
      this.ginStuUnitName,
      this.ginStuQuantity,
      this.ginStuQuantityPkts,
      this.itMstDefualtPrice,
      this.ginStuHdrFgnRefCode,
      this.userId,
      this.max,
      this.min,
      this.batchCount,
      this.selectedQty,
      this.handsOnQty});

  LineItemsWithMinMax.fromJson(Map<String, dynamic> json) {
    ginStuGinCode = json['ginStuGinCode'];
    ginBatchNo = json['ginBatchNo'];
    ginStuItemCode = json['ginStuItemCode'];
    ginStuAlise = json['ginStuAlise'];
    ginStuName = json['ginStuName'];
    ginStuUnitName = json['ginStuUnitName'];
    userId = json['userId'];
    ginStuQuantity =
        double.tryParse(json['ginStuQuantity'].toString().split('.').first);
    ginStuQuantityPkts =
        double.tryParse(json['ginStuQuantityPkts'].toString().split('.').first);
    itMstDefualtPrice = json['itMstDefualtPrice'];
    ginStuHdrFgnRefCode = json['ginStuHdrFgnRefCode'];
    handsOnQty = json['handsOnQty'];
    selectedQty = double.tryParse(json['selectedQty'].toString());
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ginStuGinCode'] = ginStuGinCode;
    data['ginBatchNo'] = ginBatchNo;
    data['ginStuItemCode'] = ginStuItemCode;
    data['ginStuAlise'] = ginStuAlise;
    data['ginStuName'] = ginStuName;
    data['ginStuUnitName'] = ginStuUnitName;
    data['ginStuQuantity'] = ginStuQuantity;
    data['ginStuQuantityPkts'] = ginStuQuantityPkts;
    data['itMstDefualtPrice'] = itMstDefualtPrice;
    data['ginStuHdrFgnRefCode'] = ginStuHdrFgnRefCode;
    data['userId'] = userId;
    data['min'] = min;
    data['max'] = max;
    data['batchCount'] = batchCount;
    data['selectedQty'] = selectedQty;
    data['handsOnQty'] = handsOnQty;
    data['id'] = id;
    return data;
  }
}

class LineItemsSelected {
  LineItems? item;
  double? selectedQuantity;
  int? id;
  String? invoiceId;

  LineItemsSelected(
      {this.item, this.selectedQuantity, this.id, this.invoiceId});

  LineItemsSelected.fromJson(Map<String, dynamic> json) {
    item = LineItems.fromJson(json['item']);
    selectedQuantity = double.tryParse(json['selectedQuantity'].toString());
    id = json['id'];
    invoiceId = json['invoiceId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['item'] = item;
    data['selectedQuantity'] = selectedQuantity;
    data['id'] = id;
    data['invoiceId'] = invoiceId;
    return data;
  }
}

class LineItemsSelectedDb {
  String? item;
  double? selectedQuantity;
  int? id;
  String? invoiceId;

  LineItemsSelectedDb(
      {this.item, this.selectedQuantity, this.id, this.invoiceId});

  LineItemsSelectedDb.fromJson(Map<String, dynamic> json) {
    item = (json['item']);
    selectedQuantity = double.tryParse(json['selectedQuantity'].toString());
    id = json['id'];
    invoiceId = json['invoiceId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['item'] = item;
    data['selectedQuantity'] = selectedQuantity;
    data['id'] = id;
    data['invoiceId'] = invoiceId;
    return data;
  }
}
