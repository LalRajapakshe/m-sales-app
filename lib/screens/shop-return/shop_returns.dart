import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:m_sales/helper/db_helper.dart';
import 'package:m_sales/helper/local_db.dart';
import 'package:m_sales/models/customer.dart';
import 'package:m_sales/models/gin_response.dart';
import 'package:m_sales/models/invoice.dart';
import 'package:m_sales/models/item.dart';
import 'package:flutter/services.dart';
import 'package:m_sales/models/setting_types.dart';

class ShopReturnPage extends StatefulWidget {
  final Customer customer;
  const ShopReturnPage({super.key, required this.customer});

  @override
  State<ShopReturnPage> createState() => _ShopReturnPageState();
}

class _ShopReturnPageState extends State<ShopReturnPage> {
  String? userId = '';
  List<ItemTableItem> itemList = [];
  List<Map<String, String>> selectedItemData = [];
  List<Map<String, String>> selectedItemDataTemp = [];
  List<LineItemsSelected> allItems = [];
  SettingTypes settingType = SettingTypes.empty();

  // Controllers for TextFields
  List<TextEditingController> batchNoControllers = [];
  List<TextEditingController> itemQuantityControllers = [];
  List<TextEditingController> itemRateControllers = [];
  GinResponse ginResponse = GinResponse.empty();
  String? ginStuHdrFgnRefCode;
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    userId = await Settings.getUserID();
    settingType = await DatabaseHelper.instance.getSettingType();
    if (userId != null) {
      fetchItems();
    }
  }

  saveReturns() async {
    bool isValid = true;
    for (var ctr in batchNoControllers) {
      if (ctr.text == '' || ctr.text.isEmpty) {
        isValid = false;
      }
    }
    for (var ctr in itemQuantityControllers) {
      if (ctr.text == '' || ctr.text.isEmpty) {
        isValid = false;
      }
    }
    for (var ctr in itemRateControllers) {
      if (ctr.text == '' || ctr.text.isEmpty) {
        isValid = false;
      }
    }
    for (var ctr in itemQuantityControllers) {
      if (double.parse(ctr.text) == 0.00) {
        isValid = false;
      }
    }
    for (var ctr in itemRateControllers) {
      if (double.parse(ctr.text) == 0.00) {
        isValid = false;
      }
    }
    for (var itm in selectedItemData) {
      if (itm['isExpired'] == 'NO' && itm['isDamaged'] == 'NO') {
        isValid = false;
      }
    }
    if (selectedItemData.isEmpty) {
      isValid = false;
      return Get.snackbar(
        'Error',
        'Add Items',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    if (isValid) {
      DateTime now = DateTime.now();
      DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      double totalQty = 0.0;
      double grossNetTotal = 0.00;
      for (int i = 0; i < selectedItemData.length; i++) {
        double _handsOnQty = 0;
        totalQty = totalQty +
            double.parse(selectedItemData[i]['itemQuantity'].toString());
        grossNetTotal = grossNetTotal +
            (double.tryParse(selectedItemData[i]['itemPrice'].toString())! *
                double.parse(selectedItemData[i]['itemQuantity'].toString()));
        ItemTableItem item = itemList.firstWhere((itm) {
          return itm.itMstCode.toString() == selectedItemData[i]['itemId'];
        });
        if (ginResponse.lineItems != null && ginResponse.lineItems != []) {
          _handsOnQty = ginResponse.lineItems!.firstWhere(
                (itm) {
                  return itm.ginBatchNo == selectedItemData[i]['batchNo'] &&
                      itm.ginStuItemCode.toString() ==
                          selectedItemData[i]['itemId'];
                },
                orElse: () => LineItems(handsOnQty: 0.00),
              ).handsOnQty ??
              0.00 +
                  double.parse(selectedItemData[i]['itemQuantity'].toString());
        }
        allItems.add(LineItemsSelected(
            selectedQuantity:
                double.parse(selectedItemData[i]['itemQuantity'].toString()),
            item: LineItems(
                userId: userId,
                ginStuAlise: item.itMstAlias,
                handsOnQty: _handsOnQty,
                ginStuName: item.itMstDescription,
                isFresh: selectedItemData[i]['fresh'],
                isDamaged: selectedItemData[i]['isDamaged'],
                isExpired: selectedItemData[i]['isExpired'],
                ginBatchNo: selectedItemData[i]['batchNo'],
                ginStuItemCode:
                    int.tryParse(selectedItemData[i]['itemId'].toString()),
                itMstDefualtPrice: double.tryParse(
                    selectedItemData[i]['itemPrice'].toString()))));
      }
      Invoice invoice = Invoice(
          userId: userId,
          vatIncExc: '',
          totalQty: totalQty,
          items: allItems,
          grossTotal: grossNetTotal,
          tax: 0.00,
          netTotal: grossNetTotal,
          dateTime: formatter.format(now),
          chtAccAccNo: widget.customer.chtAccAccNo.toString(),
          payMode: 'N/A',
          isReturn: 'true');
      int? _id = await DatabaseHelper.instance.insertInvoice(invoice);
      if (_id != null) {
        setState(() {
          selectedItemData = [];
          allItems = [];
          batchNoControllers = [];
          itemQuantityControllers = [];
          itemRateControllers = [];
        });
        Get.snackbar(
          'Success',
          'saved',
          backgroundColor: const Color.fromARGB(255, 50, 118, 52),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Not saved',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        'Error',
        'Fill Values',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> fetchItems() async {
    itemList = await DatabaseHelper.instance.getItemsByUserId(userId!);
    ginStuHdrFgnRefCode = await Settings.getGinStuHdrFgnRefCode();

    ginResponse = await DatabaseHelper.instance
        .getGinResponses(userId!, ginStuHdrFgnRefCode.toString());
    print(itemList.toString());
    setState(() {});
  }

  // Initialize controllers when adding items
  void initializeControllers() {
    batchNoControllers.clear();
    itemQuantityControllers.clear();
    itemRateControllers.clear();
    for (var item in selectedItemData) {
      batchNoControllers.add(TextEditingController(text: item['batchNo']));
      itemQuantityControllers
          .add(TextEditingController(text: item['itemQuantity']));
      itemRateControllers.add(TextEditingController(text: item['itemPrice']));
    }
  }

  @override
  void dispose() {
    // Dispose of controllers when the widget is removed from the widget tree
    for (var controller in batchNoControllers) {
      controller.dispose();
    }
    for (var controller in itemQuantityControllers) {
      controller.dispose();
    }
    for (var controller in itemRateControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Function to show item list in a popup to select from
  void _showAddItemPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: itemList.length,
                    itemBuilder: (context, index) {
                      final item = itemList[index];
                      return Card(
                        color: Colors.orange[50],
                        child: ListTile(
                          title: Text(
                            item.itMstDescription?.toString() ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(item.itMstCode?.toString() ?? ''),
                          trailing: Text(
                            '${item.itMstDefaultPrice?.toString() ?? ''} LKR',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            setState(() {
                              selectedItemData.add({
                                'itemId': item.itMstCode?.toString() ?? '',
                                'itemName':
                                    item.itMstDescription?.toString() ?? '',
                                'fresh': 'NO',
                                'isExpired': 'NO',
                                'isDamaged': 'NO'
                              });

                              // Reinitialize controllers whenever a new item is added
                              initializeControllers();
                            });
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          "Shop Return",
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.question_mark, color: Colors.white),
            tooltip: 'Help',
            onPressed: () {
              // handle the press
            },
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Customer Info Card
              Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.customer.chtAccName ?? "",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Returning Items",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () {
                              _showAddItemPopup(
                                  context); // Show popup on button press
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Selected Items List
              if (selectedItemData.isNotEmpty)
                Container(
                  color: Colors.orange[50],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: selectedItemData.length,
                    itemBuilder: (context, index) {
                      final item = selectedItemData[index];
                      final isFresh = item['fresh'] == 'YES';
                      final isExpired = item['isExpired'] == 'YES';
                      final isDamaged = item['isDamaged'] == 'YES';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['itemId'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        item['itemName'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedItemData
                                          .removeAt(index); // Remove item
                                      batchNoControllers.removeAt(index);
                                      itemQuantityControllers.removeAt(index);
                                      itemRateControllers.removeAt(index);
                                    });
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Checkbox for "Fresh"
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: isFresh,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            item['fresh'] =
                                                value! ? 'YES' : 'NO';
                                          });
                                        },
                                      ),
                                      const Text("Fresh"),
                                    ],
                                  ),
                                  const SizedBox(width: 10),
                                  // Quantity Input
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 4,
                                    child: TextField(
                                      controller:
                                          itemQuantityControllers[index],
                                      textAlign: TextAlign.right,
                                      keyboardType: const TextInputType
                                          .numberWithOptions(), // Ensure numeric keyboard is shown
                                      // inputFormatters: [
                                      //   FilteringTextInputFormatter
                                      //       .digitsOnly, // Allow digits only
                                      // ],
                                      decoration: const InputDecoration(
                                        hintText: 'QTY',
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          item['itemQuantity'] = value;
                                        });
                                      },
                                    ),
                                  ),

                                  const SizedBox(width: 10),
                                  // Batch No Input
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 4,
                                    child: TextField(
                                      controller: batchNoControllers[index],
                                      textAlign: TextAlign.right,
                                      decoration: const InputDecoration(
                                        hintText: 'Batch No',
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          item['batchNo'] = value;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 48.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 4,
                                    child: TextField(
                                      controller: itemRateControllers[index],
                                      textAlign: TextAlign.right,
                                      keyboardType: const TextInputType
                                          .numberWithOptions(), // Ensure numeric keyboard is shown
                                      // inputFormatters: [
                                      //   FilteringTextInputFormatter
                                      //       .digitsOnly, // Allow digits only
                                      // ],
                                      decoration: const InputDecoration(
                                        hintText: 'Rate',
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          item['itemPrice'] = value;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Row(
                              children: [
                                const Text("Return Reason"),
                              ],
                            ),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: isExpired,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          item['isExpired'] =
                                              value! ? 'YES' : 'NO';
                                        });
                                      },
                                    ),
                                    const Text("Expired"),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: isDamaged,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          item['isDamaged'] =
                                              value! ? 'YES' : 'NO';
                                        });
                                      },
                                    ),
                                    const Text("Damaged"),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 15.0, color: Colors.white),
                  ),
                  onPressed: () {
                    // Print selectedItemData with updated values
                    // for (var item in selectedItemData) {
                    //   print(
                    //       "Item: ${item['itemName']}, Quantity: ${item['itemQuantity']}, Batch No: ${item['batchNo']}, Fresh: ${item['fresh']}");
                    // }
                    saveReturns();
                    setState(() {
                      // selectedItemData = []; // Clear the list
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
