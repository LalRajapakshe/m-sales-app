import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:m_sales/helper/db_helper.dart';
import 'package:m_sales/helper/local_db.dart';
import 'package:m_sales/models/customer.dart';
import 'package:m_sales/models/gin_response.dart';
import 'package:m_sales/models/invoice.dart';
import 'package:m_sales/models/setting_types.dart';
import 'package:m_sales/services/cart_service.dart';
import 'package:provider/provider.dart';

class SummeryPage extends StatefulWidget {
  final Customer customer;
  final Function callBack;
  final Function callBackForBack;
  const SummeryPage(
      {super.key,
      required this.customer,
      required this.callBack,
      required this.callBackForBack});

  @override
  State<SummeryPage> createState() => _SummeryPageState();
}

class _SummeryPageState extends State<SummeryPage> {
  List<List<LineItemsSelected>> items = [];
  List<LineItemsSelected> allItems = [];
  double grossTotal = 0.00;
  double tax = 0.00;
  double netTotal = 0.00;
  double qty = 0.00;
  DateTime now = DateTime.now();
  DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  String buttonText = 'Payment';
  int? invoiceId = 0;
  bool useVat = false;
  late SettingTypes settingType;

  @override
  void initState() {
    super.initState();
    getData();
  }

  deleteItem(int index) {
    List<LineItemsSelected> itmIndex = [];
    itmIndex.add(allItems[index]);

    Provider.of<CartService>(context, listen: false)
        .finalItemWithMinMaxList
        .forEach((itemList) {
      for (var _itm in itemList) {
        if (_itm.ginStuItemCode == allItems[index].item!.ginStuItemCode) {
          if (_itm.selectedQty != null &&
              itmIndex[0].selectedQuantity != null) {
            _itm.selectedQty =
                _itm.selectedQty! - itmIndex[0].selectedQuantity!;
          }
        }
      }
    });

    Provider.of<CartService>(context, listen: false)
        .cartList
        .forEach((itemList) {
      itemList.forEach((element) {
        if (element.item!.ginStuItemCode ==
                allItems[index].item!.ginStuItemCode &&
            element.item!.ginBatchNo == allItems[index].item!.ginBatchNo) {
          element.selectedQuantity = 0;
        }
      });
    });

    Provider.of<CartService>(context, listen: false)
        .cartList
        .removeWhere((itemList) {
      return itemList.isEmpty;
    });

    Provider.of<CartService>(context, listen: false)
        .finalItemWithMinMaxList
        .removeWhere((itemList) {
      return itemList.isEmpty;
    });
    allItems.removeAt(index);
    getGrossTotal();
    getTotalQty();
    setState(() {});
  }

  getData() async {
    useVat = Provider.of<CartService>(context, listen: false).useVat;
    String? userId = await Settings.getUserID();
    settingType = await DatabaseHelper.instance.getSettingType();
    items = Provider.of<CartService>(context, listen: false).cart;
    for (var itm in items) {
      for (var _itm in itm) {
        if (_itm.selectedQuantity != 0) {
          allItems.add(_itm);
        }
      }
    }
    getGrossTotal();
    getTotalQty();
  }

  double getItemPrice(double price, double qty) {
    return price * qty;
  }

  getGrossTotal() {
    grossTotal = 0.00;
    for (var item in allItems) {
      double vatForItem = 0.00;
      if (useVat) {
        vatForItem = (item.item?.itMstDefualtPrice ?? 0.00) * 18 / (100 + 18);
        grossTotal = grossTotal +
            getItemPrice((item.item?.itMstDefualtPrice ?? 0.0) - vatForItem,
                (item.selectedQuantity ?? 0.00));
      } else {
        grossTotal = grossTotal +
            getItemPrice(item.item?.itMstDefualtPrice ?? 0.0,
                item.selectedQuantity ?? 0);
      }
    }
    calculateNetTotal();
  }

  calculateNetTotal() {
    netTotal = 0.00;
    tax = 0.00;
    double _tax = 0.00;
    for (var item in allItems) {
      if (settingType.vattype == 'VAT_INCLUDE') {
        _tax = _tax +
            ((item.selectedQuantity ?? 0) *
                (item.item?.itMstDefualtPrice ?? 0.0) *
                18 /
                (100 + 18));
      } else {
        _tax = _tax +
            ((item.selectedQuantity ?? 0) *
                (item.item?.itMstDefualtPrice ?? 0.0) *
                18 /
                (100));
      }
    }
    if (widget.customer.infoCustomerCategory == 1 && useVat) {
      tax = _tax;
      netTotal = tax + grossTotal;
    } else {
      tax = 0.00;
      netTotal = tax + grossTotal;
    }

    Provider.of<CartService>(context, listen: false).netTotal = netTotal;
    Provider.of<CartService>(context, listen: false).grossTotal = grossTotal;
    Provider.of<CartService>(context, listen: false).tax = tax;
  }

  getTotalQty() {
    qty = 0;
    for (var item in allItems) {
      qty = qty + (item.selectedQuantity ?? 0);
    }
    setState(() {});
  }

  getItemUnitPrice(double uPrice) {
    if (useVat) {
      return uPrice - (uPrice * 18 / (100 + 18));
    } else {
      return uPrice;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Order Date",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(formatter.format(now).toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
                //  shrinkWrap: true,
                itemCount: allItems.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.orange[50],
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: ListTile(
                          title: Text(
                            '${allItems[index].item?.ginStuName?.trim() ?? ''}*${allItems[index].selectedQuantity ?? ''}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange),
                          ),
                          contentPadding: EdgeInsets.only(left: 15, right: 5),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'I/C - ${allItems[index].item?.ginStuItemCode ?? ''}'),
                              Text(
                                  'B/N - ${allItems[index].item?.ginBatchNo ?? ''}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    '${getItemUnitPrice(allItems[index].item?.itMstDefualtPrice ?? 0.00).toStringAsFixed(2) ?? ''}*${allItems[index].selectedQuantity?.toStringAsFixed(2) ?? ''}',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    'LKR ${getItemPrice(getItemUnitPrice(allItems[index].item?.itMstDefualtPrice ?? 0.00), allItems[index].selectedQuantity ?? 0).toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                  onPressed: () {
                                    deleteItem(index);
                                  },
                                  icon: const Icon(Icons.delete))
                            ],
                          )),
                    ),
                  );
                }),
          ),
          if (widget.customer.infoCustomerCategory == 1)
            Container(
              padding: const EdgeInsets.all(
                  5.0), // Adjust the value as per your requirement

              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    child: Switch(
                        activeColor: Colors.orange,
                        value: useVat,
                        onChanged: (v) {
                          useVat = v;
                          grossTotal = 0.00;
                          tax = 0.00;
                          netTotal = 0.00;
                          qty = 0;
                          getGrossTotal();
                          getTotalQty();
                          Provider.of<CartService>(context, listen: false)
                              .useVat = v;
                          setState(() {});
                        }),
                  ),
                  const Text(
                    'Enable VAT',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Radio(
                  //       value: 'In_vat',
                  //       groupValue: _selectedValue,
                  //       onChanged: (value) {
                  //         setState(() {
                  //           _selectedValue = value!;
                  //           calculateNetTotal();
                  //           Settings.setVatType('In_vat');
                  //         });
                  //       },
                  //     ),
                  //     const Text('Include vat'),
                  //     Radio(
                  //       value: 'Ex_vat',
                  //       groupValue: _selectedValue,
                  //       onChanged: (value) {
                  //         setState(() {
                  //           _selectedValue = value!;
                  //           calculateNetTotal();
                  //           Settings.setVatType('Ex_vat');
                  //         });
                  //       },
                  //     ),
                  //     const Text('Exclude vat'),
                  //   ],
                  // ),
                ],
              ),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Quantity",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(qty.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Gross Total",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('LKR ${grossTotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Discount",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("0.00",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Tax",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('LKR ${tax.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Net Total",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('LKR ${netTotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment
            .spaceAround, // Evenly space the buttons with small space between
        children: <Widget>[
          // Expanded(
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(
          //         horizontal: 4.0), // Small padding on left and right
          //     child: ElevatedButton(
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: Colors.orange,
          //         shape: RoundedRectangleBorder(
          //           borderRadius:
          //               BorderRadius.circular(12.0), // Slightly rounded edges
          //         ),
          //       ),
          //       child: const Text(
          //         'Get Promotions',
          //         style: TextStyle(fontSize: 15.0, color: Colors.white),
          //       ),
          //       onPressed: () {},
          //     ),
          //   ),
          // ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                  vertical: 5), // Small padding on left and right
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 222, 171, 95),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12.0), // Slightly rounded edges
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(fontSize: 15.0, color: Colors.white),
                ),
                onPressed: () {
                  widget.callBackForBack();
                },
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 4.0), // Small padding on left and right
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12.0), // Slightly rounded edges
                  ),
                ),
                child: const Text(
                  'Payment',
                  style: const TextStyle(fontSize: 15.0, color: Colors.white),
                ),
                onPressed: () {
                  widget.callBack(invoiceId);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
