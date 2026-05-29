import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m_sales/Widgets/full_screen_loading.dart';
import 'package:m_sales/Widgets/loading.dart';
import 'package:m_sales/helper/db_helper.dart';
import 'package:m_sales/helper/local_db.dart';
import 'package:m_sales/models/customer.dart';
import 'package:m_sales/models/gin_response.dart';
import 'package:m_sales/models/setting_types.dart';
import 'package:m_sales/screens/invoice/order_history.dart';
import 'package:m_sales/services/cart_service.dart';
import 'package:m_sales/services/customer_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderPage extends StatefulWidget {
  final Customer customer;
  final Function callBack;
  final Function callBackForback;
  const OrderPage({
    super.key,
    required this.customer,
    required this.callBack,
    required this.callBackForback,
  });

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String _selectedValue = '';

  List<LineItems> itemList = [];
  List<LineItems> finalItemList = [];
  List<List<LineItems>> listItemsFiltered = [];
  List<LineItemsWithMinMax> finalItemListWithMinMax = [];

  bool isLoading = true;
  GinResponse ginResponse = GinResponse.empty();
  bool plusClicked = false;
  String priceType = 'Cash';

  SettingTypes settingType = SettingTypes.empty();

  @override
  void initState() {
    super.initState();

    getData();
  }

  getMasterData() async {
    Loading().startLoading(context);
    finalItemListWithMinMax = [];
    itemList = [];
    finalItemList = [];
    listItemsFiltered = [];
    String refCode = await Settings.getGinStuHdrFgnRefCode() ?? '';
    await getPrices(widget.customer.userId!, refCode);
    await getData();
    Loading().stopLoading(context);
  }

  getPrices(String userId, String refCode) async {
    await Provider.of<CustomerProvider>(context, listen: false).fetchPrices(
        userId, refCode, widget.customer.chtAccPriceTblCode!, priceType);
  }

  getData() async {
    print("--------------------ORDER--------------------");

    print("--------------------ORDER--------------------");

    finalItemListWithMinMax = [];
    finalItemListWithMinMax = Provider.of<CartService>(context, listen: false)
            .finalItemWithMinMaxList
            .isNotEmpty
        ? Provider.of<CartService>(context, listen: false)
            .finalItemWithMinMaxList
            .first
        : [];
    priceType = Provider.of<CartService>(context, listen: false).getPriceType;
    String userId = await Settings.getUserID() ?? '';
    String? ginStuHdrFgnRefCode = await Settings.getGinStuHdrFgnRefCode();
    settingType = await DatabaseHelper.instance.getSettingType();
    ginResponse = await DatabaseHelper.instance
        .getGinResponses(userId, ginStuHdrFgnRefCode.toString());
    itemList = ginResponse.lineItems ?? [];
    List<String> checkedCodes = [];
    bool isChecked = false;
    if (itemList != []) {
      for (var item in itemList) {
        String itemCode = item.ginStuItemCode.toString();
        isChecked = checkedCodes.contains(itemCode);

        if (!isChecked) {
          List<LineItems> temp = itemList.where((itm) {
            return (itm.ginStuItemCode.toString() == itemCode &&
                itm.handsOnQty! > 0);
          }).toList();
          checkedCodes.add(itemCode);

          if (temp.length > 1) {
            double quantity = 0.00;
            for (var tmp in temp) {
              quantity = quantity + tmp.handsOnQty!;
            }

            LineItems _tmpItem = LineItems(
                id: item.id,
                ginBatchNo: item.ginBatchNo,
                ginStuAlise: item.ginStuAlise,
                ginStuGinCode: item.ginStuGinCode,
                ginStuItemCode: item.ginStuItemCode,
                ginStuName: item.ginStuName,
                ginStuQuantity: item.ginStuQuantity,
                ginStuQuantityPkts: item.ginStuQuantityPkts,
                ginStuUnitName: item.ginStuUnitName,
                itMstDefualtPrice: item.itMstDefualtPrice,
                ginStuHdrFgnRefCode: item.ginStuHdrFgnRefCode,
                handsOnQty: quantity,
                userId: item.userId);

            finalItemList.add(_tmpItem);
          } else if (temp.length == 1) {
            finalItemList.add(temp.first);
          }
        }
      }
      checkForPriceRanges();
      fliterBatchWise();
    }
    setState(() {
      isLoading = false;
    });
  }

  checkForPriceRanges() {
    for (var item in finalItemList) {
      double min = 100000;
      double max = 0;
      int batchCount = 0;
      List<String> batchNoList = [];
      for (var listItem in ginResponse.lineItems!) {
        if (item.ginStuItemCode == listItem.ginStuItemCode) {
          if (listItem.itMstDefualtPrice! < min) {
            min = listItem.itMstDefualtPrice!;
          }
          if (listItem.itMstDefualtPrice! > max) {
            max = listItem.itMstDefualtPrice!;
          }
          if (!batchNoList.contains(listItem.ginBatchNo)) {
            batchCount++;
            batchNoList.add(listItem.ginBatchNo!);
          }
        }
      }
      finalItemListWithMinMax.add(LineItemsWithMinMax(
          userId: item.userId,
          id: item.id,
          ginBatchNo: item.ginBatchNo,
          ginStuAlise: item.ginStuAlise,
          ginStuGinCode: item.ginStuGinCode,
          ginStuItemCode: item.ginStuItemCode,
          ginStuName: item.ginStuName,
          ginStuQuantity: item.ginStuQuantity,
          ginStuQuantityPkts: item.ginStuQuantityPkts,
          ginStuUnitName: item.ginStuUnitName,
          itMstDefualtPrice: item.itMstDefualtPrice,
          ginStuHdrFgnRefCode: item.ginStuHdrFgnRefCode,
          handsOnQty: item.handsOnQty,
          max: max,
          min: min,
          batchCount: batchCount));
    }
  }

  fliterBatchWise() {
    List<String> codeList = [];
    for (var item in itemList) {
      List<LineItems> tempList = [];

      if (!codeList.contains(item.ginStuItemCode.toString())) {
        tempList = itemList.where((itm) {
          return itm.ginStuItemCode.toString() ==
              item.ginStuItemCode.toString();
        }).toList();
        codeList.add(item.ginStuItemCode.toString());
        listItemsFiltered.add(tempList);
      }
    }
  }

  filterByBatchNumber(List<LineItems> items) {
    List<String> batchNoList = [];
    List<LineItems> finalList = [];

    for (var itm in items) {
      double qty = 0.00;
      if (itm.handsOnQty! > 0) {
        if (!batchNoList.contains(itm.ginBatchNo)) {
          List<LineItems> sameBatchItems = items.where((_itm) {
            return _itm.ginBatchNo == itm.ginBatchNo;
          }).toList();
          batchNoList.add(itm.ginBatchNo!);
          for (var sameBatchItem in sameBatchItems) {
            qty = qty + sameBatchItem.handsOnQty!;
          }
          finalList.add(LineItems(
              id: itm.id,
              userId: itm.userId,
              ginBatchNo: itm.ginBatchNo,
              ginStuAlise: itm.ginStuAlise,
              ginStuGinCode: itm.ginStuGinCode,
              ginStuItemCode: itm.ginStuItemCode,
              ginStuName: itm.ginStuName,
              ginStuQuantity: itm.ginStuQuantity,
              ginStuQuantityPkts: itm.ginStuQuantityPkts,
              ginStuUnitName: itm.ginStuUnitName,
              itMstDefualtPrice: itm.itMstDefualtPrice,
              ginStuHdrFgnRefCode: itm.ginStuHdrFgnRefCode,
              handsOnQty: qty));
        }
      }
    }
    return finalList;
  }

  onClickedCard(String itemCode) {
    List<LineItems> items = listItemsFiltered.firstWhere((itemList) {
      return itemList.first.ginStuItemCode.toString() == itemCode;
    });

    List<LineItems> finalList = filterByBatchNumber(items);
    openCustomDialog(items.first.ginStuName, finalList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 222, 171, 95),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(fontSize: 15.0, color: Colors.white),
                ),
                onPressed: () {
                  widget.callBackForback();
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 5),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 15.0, color: Colors.white),
                ),
                onPressed: () {
                  bool hasValidItem = false;
                  var cart =
                      Provider.of<CartService>(context, listen: false).cart;

                  for (var itm in cart) {
                    for (var _itm in itm) {
                      if (_itm.selectedQuantity != 0) {
                        hasValidItem = true;
                      }
                    }
                  }
                  if (cart.isNotEmpty && hasValidItem) {
                    widget.callBack();
                  } else {
                    Get.snackbar(
                      'Error',
                      'Select items',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.orange[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Search",
                      prefixIcon: const Icon(Icons.search),
                      prefixIconColor: Colors.orange,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.check_circle_rounded),
                        color: Colors.orange,
                        onPressed: () {
                          // Clear search text
                        },
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[400],
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(0.0), // Slightly rounded edges
                    ),
                  ),
                  child: const Text(
                    '+',
                    style: TextStyle(fontSize: 12.0, color: Colors.white),
                  ),
                  onPressed: () {},
                ),
                const SizedBox(width: 2),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[400],
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(0.0), // Slightly rounded edges
                    ),
                  ),
                  child: const Text(
                    '-',
                    style: TextStyle(fontSize: 12.0, color: Colors.white),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[400],
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(0.0), // Slightly rounded edges
                  ),
                ),
                child: const Text(
                  '1',
                  style: TextStyle(fontSize: 12.0, color: Colors.white),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 1),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[400],
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(0.0), // Slightly rounded edges
                  ),
                ),
                child: const Text(
                  '5',
                  style: TextStyle(fontSize: 12.0, color: Colors.white),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 1),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[400],
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(0.0), // Slightly rounded edges
                  ),
                ),
                child: const Text(
                  '15',
                  style: TextStyle(fontSize: 12.0, color: Colors.white),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 1),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[400],
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(0.0), // Slightly rounded edges
                  ),
                ),
                child: const Text(
                  '50',
                  style: TextStyle(fontSize: 12.0, color: Colors.white),
                ),
                onPressed: () {},
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(
                5.0), // Adjust the value as per your requirement
            color: Colors.orange,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Filter By Brand",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15),
                ),
                const Text(
                  "Products",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15),
                ),
                IconButton(
                  icon: const Icon(Icons.history_edu_sharp),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const OrderHistoryPage()));
                  },
                ),
              ],
            ),
          ),
          if (settingType.payModeBase == 'YES')
            Container(
              padding: const EdgeInsets.all(
                  5.0), // Adjust the value as per your requirement
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: 'Cash',
                        groupValue: priceType,
                        onChanged: (value) {
                          setState(() {
                            priceType = value!;
                          });
                          Provider.of<CartService>(context, listen: false)
                              .clearCart();
                          Provider.of<CartService>(context, listen: false)
                              .priceType = value!;
                          getMasterData();
                        },
                      ),
                      const Text('Cash'),
                      Radio(
                        value: 'Cheque',
                        groupValue: priceType,
                        onChanged: (value) {
                          setState(() {
                            priceType = value!;
                          });
                          Provider.of<CartService>(context, listen: false)
                              .clearCart();
                          Provider.of<CartService>(context, listen: false)
                              .priceType = value!;
                          getMasterData();
                        },
                      ),
                      const Text('Cheque'),
                      Radio(
                        value: 'Credit',
                        groupValue: priceType,
                        onChanged: (value) {
                          setState(() {
                            priceType = value!;
                          });
                          Provider.of<CartService>(context, listen: false)
                              .clearCart();
                          Provider.of<CartService>(context, listen: false)
                              .priceType = value!;
                          getMasterData();
                        },
                      ),
                      const Text('Credit'),
                    ],
                  ),
                ],
              ),
            ),
          isLoading
              ? const FullScreenLoading()
              : Padding(
                  padding: const EdgeInsets.all(8.0), // Add padding here
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 2.0,
                    crossAxisSpacing: 2.0,
                    children: List.generate(
                      finalItemList.length,
                      (index) => Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              onClickedCard(finalItemListWithMinMax[index]
                                  .ginStuItemCode
                                  .toString());
                            },
                            child: Card(
                              elevation: 2,
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Image.asset(
                                    'images/no_image.png',
                                    width: 80,
                                    height: 60,
                                    fit: BoxFit.fill,
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    // Wrap the Column in an Expanded widget
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const SizedBox(width: 5),
                                            Text(
                                              '${finalItemListWithMinMax[index].handsOnQty?.toStringAsFixed(2)} / ${finalItemListWithMinMax[index].selectedQty?.toStringAsFixed(2) ?? '0.00'} ${finalItemListWithMinMax[index].ginStuUnitName ?? ''}',
                                              style: const TextStyle(
                                                  color: Colors.orange,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const SizedBox(width: 5),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2 -
                                                  40,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    finalItemListWithMinMax[
                                                                index]
                                                            .ginStuName
                                                            ?.trim() ??
                                                        '',
                                                    style: const TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    'I/C - ${finalItemListWithMinMax[index].ginStuItemCode ?? ''}',
                                                    style: const TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const SizedBox(width: 5),
                                            Text(
                                              !(finalItemListWithMinMax[index]
                                                          .min ==
                                                      finalItemListWithMinMax[
                                                              index]
                                                          .max)
                                                  ? 'LKR ${finalItemListWithMinMax[index].min?.toStringAsFixed(2) ?? 0.00} - ${finalItemListWithMinMax[index].max?.toStringAsFixed(2) ?? 0.00}'
                                                  : 'LKR ${finalItemListWithMinMax[index].itMstDefualtPrice?.toStringAsFixed(2) ?? 0.00}',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                              child: Text(
                                (finalItemListWithMinMax[index].batchCount)
                                    .toString(), // Display index + 1 as number
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          // const Spacer(),
        ],
      ),
    );
  }

  onClickPlus(double qty, List<LineItems> items,
      List<TextEditingController> controllers) {
    setState(() {
      for (var ctr in controllers) {
        ctr.clear();
      }
    });
    double quantity = qty;
    bool isDone = false;
    for (var itm in items) {
      setState(() {
        if (!isDone) {
          if (quantity > itm.handsOnQty!) {
            quantity = quantity - itm.handsOnQty!;

            controllers[items.indexOf(itm)].text =
                itm.handsOnQty!.toStringAsFixed(2);
          } else {
            controllers[items.indexOf(itm)].text = quantity.toStringAsFixed(2);
            isDone = true;
          }
        }
      });
    }

    plusClicked = true;
    if (!isDone) {
      Get.snackbar(
        'Error',
        'Not Enough Quantity',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  onClickTick(double qty, List<LineItems> items,
      List<TextEditingController> controllers, int index) {
    bool validAmount = true;
    if (qty != null && qty != 0.0) {
      setState(() {
        for (var ctr in controllers) {
          if (controllers.indexOf(ctr) != index) {
            ctr.clear();
          }
        }
      });
      double quantity = 0.00;
      if (double.parse(controllers[index].text) > items[index].handsOnQty!) {
        validAmount = false;
        quantity = qty;
      } else {
        quantity = qty - double.tryParse(controllers[index].text)!;
      }
      bool isDone = false;
      for (var itm in items) {
        setState(() {
          if (!isDone) {
            if (quantity > itm.handsOnQty!) {
              if (validAmount) {
                if (items.indexOf(itm) != index) {
                  quantity = quantity - itm.handsOnQty!;
                  controllers[items.indexOf(itm)].text =
                      itm.handsOnQty!.toStringAsFixed(2);
                }
              } else {
                quantity = quantity - itm.handsOnQty!;
                controllers[items.indexOf(itm)].text =
                    itm.handsOnQty!.toStringAsFixed(2);
              }
            } else {
              controllers[items.indexOf(itm)].text =
                  quantity.toStringAsFixed(2);
              isDone = true;
            }
          }
        });
      }
      plusClicked = true;
      if (!isDone) {
        Get.snackbar(
          'Error',
          'Not Enough Quantity',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        'Error',
        'Enter Quantity',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  onClickOk(List<LineItems> items, List<TextEditingController> controllers,
      List<TextEditingController> controllers2, String isUnit) {
    List<LineItemsSelected> selectedList = [];
    double qty = 0.00;

    for (int i = 0; i < items.length; i++) {
      double? defUnitRate = items[i].itMstDefualtPrice;
      if (isUnit == 'UP') {
        if (defUnitRate! <= double.tryParse(controllers2[i].text)!) {
          items[i].handsOnQty = items[i].handsOnQty! -
              (controllers[i].text == ''
                  ? 0
                  : double.tryParse(controllers[i].text)!);
          items[i].itMstDefualtPrice = controllers2[i].text == ''
              ? 0
              : double.tryParse(controllers2[i].text)!;

          print("------------PRICE---------------");
          print(items[i].itMstDefualtPrice);
          print("------------PRICE---------------");

          selectedList.add(LineItemsSelected(
              item: items[i],
              selectedQuantity: controllers[i].text == ''
                  ? 0.00
                  : double.tryParse(controllers[i].text)));
          if (controllers[i].text == '') {
            qty = qty + (0);
          } else {
            qty = qty + (double.tryParse(controllers[i].text))!;
          }
        } else {
          Get.snackbar(
            'Error',
            'Price must highter than ${items[i].itMstDefualtPrice}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else if (isUnit == 'DOWN') {
        if (defUnitRate! >= double.tryParse(controllers2[i].text)!) {
          items[i].handsOnQty = items[i].handsOnQty! -
              (controllers[i].text == ''
                  ? 0
                  : double.tryParse(controllers[i].text)!);
          items[i].itMstDefualtPrice = controllers2[i].text == ''
              ? 0
              : double.tryParse(controllers2[i].text)!;

          print("------------PRICE---------------");
          print(items[i].itMstDefualtPrice);
          print("------------PRICE---------------");

          selectedList.add(LineItemsSelected(
              item: items[i],
              selectedQuantity: controllers[i].text == ''
                  ? 0.00
                  : double.tryParse(controllers[i].text)));
          if (controllers[i].text == '') {
            qty = qty + (0);
          } else {
            qty = qty + (double.tryParse(controllers[i].text))!;
          }
        } else {
          Get.snackbar(
            'Error',
            'Price must lower than ${items[i].itMstDefualtPrice}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        items[i].handsOnQty = items[i].handsOnQty! -
            (controllers[i].text == ''
                ? 0
                : double.tryParse(controllers[i].text)!);
        items[i].itMstDefualtPrice = controllers2[i].text == ''
            ? 0
            : double.tryParse(controllers2[i].text)!;

        print("------------PRICE---------------");
        print(items[i].itMstDefualtPrice);
        print("------------PRICE---------------");

        selectedList.add(LineItemsSelected(
            item: items[i],
            selectedQuantity: controllers[i].text == ''
                ? 0.00
                : double.tryParse(controllers[i].text)));
        if (controllers[i].text == '') {
          qty = qty + (0);
        } else {
          qty = qty + (double.tryParse(controllers[i].text))!;
        }
      }
    }

    LineItemsWithMinMax lineItem = finalItemListWithMinMax.firstWhere((itm) {
      return itm.ginStuItemCode.toString() ==
          items.first.ginStuItemCode.toString();
    });

    setState(() {
      if (lineItem.handsOnQty! < qty) {
        Get.snackbar(
          'Error',
          'Not Enough Quantity',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        plusClicked = false;
        Provider.of<CartService>(context, listen: false)
            .addToCart(selectedList);
        finalItemListWithMinMax.firstWhere((itm) {
          return itm.ginStuItemCode.toString() ==
              items.first.ginStuItemCode.toString();
        }).selectedQty = qty;
        Provider.of<CartService>(context, listen: false)
            .finalItemWithMinMaxList = [];
        Provider.of<CartService>(context, listen: false)
            .finalItemWithMinMaxList
            .add(finalItemListWithMinMax);
      }
    });
  }

  Future openCustomDialog(itemname, List<LineItems> items) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

    TextEditingController qtyController = TextEditingController();
    TextEditingController rateController = TextEditingController();
    List<TextEditingController> _controllers = [];
    List<TextEditingController> _controllers2 = [];
    List<LineItemsSelected> selectedList = [];
    List<List<LineItemsSelected>> cart =
        Provider.of<CartService>(context, listen: false).cart;
    String isUnit = sharedPrefs.getString('unitRt')!;

    if (cart.isNotEmpty) {
      cart.forEach((element) {
        for (var itm in element) {
          if (itm.item!.ginStuItemCode == items.first.ginStuItemCode) {
            selectedList.add(itm);
          }
        }
      });
    }

    for (int i = 0; i < items.length; i++) {
      _controllers.add(TextEditingController());
      _controllers2.add(TextEditingController());
    }

    if (selectedList.isNotEmpty) {
      for (int i = 0; i < selectedList.length; i++) {
        if (selectedList[i].selectedQuantity != null) {
          _controllers[i].text = selectedList[i].selectedQuantity.toString();
          _controllers2[i].text =
              selectedList[i].item!.itMstDefualtPrice.toString();
        }
      }
    }
    if (items.length > 0) {
      for (int i = 0; i < items.length; i++) {
        setState(() {
          _controllers2[i].text = items[i].itMstDefualtPrice.toString();
        });
      }
    }

    return showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                itemname,
                style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: TextField(
                      keyboardType: const TextInputType.numberWithOptions(),
                      controller: qtyController,
                      decoration: const InputDecoration(
                        hintText: 'qty',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            12.0), // Slightly rounded edges
                      ),
                    ),
                    child: const Text(
                      '+',
                      style: TextStyle(fontSize: 25.0, color: Colors.white),
                    ),
                    onPressed: () {
                      onClickPlus(double.tryParse(qtyController.text)!, items,
                          _controllers);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Table(
                    border: TableBorder.all(color: Colors.grey),
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1),
                      4: FlexColumnWidth(1), // New column
                    },
                    children: [
                      const TableRow(
                        children: [
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Batch No',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Qty',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Price (LKR)',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Added Qty',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                '',
                                textAlign: TextAlign.center,
                              ), // New cell
                            ),
                          ),
                        ],
                      ),
                      ...items.map((row) {
                        return TableRow(
                          children: [
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(row.ginBatchNo!,
                                    textAlign: TextAlign.center),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    row.handsOnQty?.toStringAsFixed(2) ?? '',
                                    textAlign: TextAlign.center),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  keyboardType:
                                      const TextInputType.numberWithOptions(),
                                  controller: _controllers2[items.indexOf(row)],
                                  onChanged: (v) {
                                    _controllers2[items.indexOf(row)].text = v;
                                  },
                                  decoration: const InputDecoration(),
                                  readOnly: isUnit == 'NO',
                                ),
                                // Text(
                                //     row.itMstDefualtPrice?.toStringAsFixed(2) ??
                                //         '',
                                //     textAlign: TextAlign.center),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  keyboardType:
                                      const TextInputType.numberWithOptions(),
                                  controller: _controllers[items.indexOf(row)],
                                  onChanged: (v) {
                                    _controllers[items.indexOf(row)].text = v;
                                    print(items.indexOf(row));
                                    print(
                                        _controllers[items.indexOf(row)].text);
                                  },
                                  decoration: const InputDecoration(),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: IconButton(
                                  color: Colors.green,
                                  icon: const Icon(Icons
                                      .done_outline_sharp), // Example icon, replace with your icon
                                  onPressed: () {
                                    onClickTick(
                                        double.tryParse(qtyController.text) ??
                                            0.00,
                                        items,
                                        _controllers,
                                        items.indexOf(row));
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      onClickOk(items, _controllers, _controllers2, isUnit);
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Ok",
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
