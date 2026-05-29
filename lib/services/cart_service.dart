import 'package:flutter/material.dart';
import 'package:m_sales/models/gin_response.dart';

class CartService extends ChangeNotifier {
  List<List<LineItemsSelected>> cartList = [];

  List<List<LineItemsSelected>> get cart => cartList;

  List<List<LineItemsWithMinMax>> finalItemWithMinMaxList = [];

  List<List<LineItemsWithMinMax>> get getFinalItemListWithMinMax =>
      finalItemWithMinMaxList;

  double netTotal = 0.00;
  double get getNetTotal => netTotal;

  double grossTotal = 0.00;
  double get getGrossTotal => grossTotal;

  double tax = 0.00;
  double get getTax => tax;

  String priceType = 'Cash';
  String get getPriceType => priceType;

  bool useVat = false;
  bool get getUseVat => useVat;

  addToCart(List<LineItemsSelected> itemBatchCollection) {
    List<int> includeIndexs = [];
    int? mainIndex;

    if (cartList.isNotEmpty) {
      // for (var crtItem in cartList.first) {
      //   for (var element in itemBatchCollection) {
      //     if (crtItem.item!.ginStuItemCode.toString() ==
      //             element.item!.ginStuItemCode.toString() &&
      //         crtItem.item!.ginBatchNo.toString() ==
      //             element.item!.ginBatchNo.toString()) {
      //       includeIndexs.add(cartList.first.indexOf(crtItem));
      //     }
      //   }
      // }

      for (var crtItm in cartList) {
        if (crtItm.isNotEmpty) {
          crtItm.forEach((element) {
            if (element.item!.ginStuItemCode.toString() ==
                    itemBatchCollection.first.item!.ginStuItemCode.toString()) {
              includeIndexs.add(crtItm.indexOf(element));
              mainIndex = cartList.indexOf(crtItm);
            }
          });

          // if (crtItm.first.item!.ginStuItemCode.toString() ==
          //         itemBatchCollection.first.item!.ginStuItemCode.toString() &&
          //     crtItm.first.item!.ginBatchNo.toString() ==
          //         itemBatchCollection.first.item!.ginBatchNo.toString()) {
          //   isInclude = true;
          //   index = cartList.indexOf(crtItm);
          // }
        }
      }
    }

    if (mainIndex != null) {
      cartList.removeAt(mainIndex!);
    }

    // if (includeIndexs.isNotEmpty) {
    //   includeIndexs.forEach((e) {
    //     cartList[mainIndex].removeAt(e);
    //   });
    //   includeIndexs = [];
    // }
    print(cartList.length);
    cartList.add(itemBatchCollection);
    print(cartList.length);
    for (var element in cartList.first) {
      print(element.toJson());

      print('----------');
    }
    notifyListeners();
  }

  List<LineItemsSelected> getAddedItem(String itemCode) {
    List<LineItemsSelected> temp = [];
    for (var itm in cartList) {
      if (itm.first.item!.ginStuItemCode.toString() == itemCode) {
        temp = itm;
      }
    }
    return temp;
  }

  removeAddedItem(String itemCode) {
    List<LineItemsSelected> temp = [];
    for (var itm in cartList) {
      if (itm.first.item!.ginStuItemCode.toString() == itemCode) {
        temp = itm;
      }
    }
    cartList.remove(temp);
    notifyListeners();
  }

  clearCart() {
    cartList = [];
    finalItemWithMinMaxList = [];
    netTotal = 0.00;
    grossTotal = 0.00;
    tax = 0.00;
    useVat = false;
    priceType = 'Cash';

    notifyListeners();
  }
}
