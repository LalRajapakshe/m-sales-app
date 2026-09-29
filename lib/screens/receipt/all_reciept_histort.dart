import 'package:flutter/material.dart';
import 'package:m_sales/Widgets/full_screen_loading.dart';
import 'package:m_sales/Widgets/loading.dart';
import 'package:m_sales/helper/app_helper.dart';
import 'package:m_sales/helper/db_helper.dart';
import 'package:m_sales/helper/local_db.dart';
import 'package:m_sales/models/customer.dart';
import 'package:m_sales/models/reciept.dart';
import 'package:m_sales/screens/print/print_screen.dart';
import 'package:sqflite/sqflite.dart';

class AllRecieptHistory extends StatefulWidget {
  const AllRecieptHistory({super.key});

  @override
  State<AllRecieptHistory> createState() => _AllRecieptHistoryState();
}

class _AllRecieptHistoryState extends State<AllRecieptHistory> {
  bool isLoading = true;
  List<Reciept> recieptList = [];
  List<Reciept> finalRecieptList = [];
  List<Map<String, String>> customerData = [];
  List<Customer> customerList = [];
  bool isAllReciepts = false;
  String? userId = '';
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    userId = await Settings.getUserID();
    recieptList = await DatabaseHelper.instance.getAllReciepts();
    customerList = await DatabaseHelper.instance.getCustomersByUserId(userId!);
    finalRecieptList = recieptList;
    setState(() {
      isLoading = false;
    });

    for (var i = 0; i < finalRecieptList.length; i++) {
      for (var j = 0; j < customerList.length; j++) {
        if (finalRecieptList[i].chtAccAccNo == customerList[j].chtAccAccNo) {
          customerData.add({
            'chtAccAccNo': customerList[j].chtAccAlias!,
            'chtAccName': customerList[j].chtAccName!,
            'recieptId': finalRecieptList[i].recieptId!,
            'invoiceId': finalRecieptList[i].invoiceId!,
            'dateTime': finalRecieptList[i].dateTime.toString(),
            'netTotal': finalRecieptList[i].netTotal!.toStringAsFixed(2),
            'selectedAmount':
                finalRecieptList[i].selectedAmount!.toStringAsFixed(2),
            'payMode': finalRecieptList[i].payMode ?? '',
          });
        }
      }
    }
  }

  getReciept(String recieptId) {
    return finalRecieptList.firstWhere((rst) {
      return rst.recieptId == recieptId;
    });
  }

  getCustomer(String customerId) {
    return customerList.firstWhere((cus) {
      return cus.chtAccAlias.toString() == customerId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          "Reciept History",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // Change this to the desired color
        ),
      ),
      body: isLoading
          ? const FullScreenLoading()
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 5),
                    child: ListView.builder(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        shrinkWrap: true,
                        itemCount: customerData.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.orange[50],
                                border: Border(
                                  bottom:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  // Navigator.of(context).push(MaterialPageRoute(
                                  //     builder: (context) => RecieptDetails(
                                  //         reciept: finalRecieptList[index])));
                                },
                                child: ListTile(
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(8, 8, 0, 8),
                                  subtitle: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Id : ${customerData[index]['recieptId']}',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange),
                                          ),
                                          Text(
                                              'Inv/Id : ${customerData[index]['invoiceId']}'),
                                          Text(
                                              'Cust/Id : ${customerData[index]['chtAccAccNo']}'),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                3,
                                            child: Text(
                                                'Cust/Name : ${customerData[index]['chtAccName']}'),
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            //  mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                customerData[index]
                                                    ['dateTime']!,
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                'NT LKR ${customerData[index]['netTotal']}',
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                'Recie/Amount LKR ${customerData[index]['selectedAmount']}',
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                customerData[index]['payMode']!,
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              IconButton(
                                                iconSize: 30,
                                                color: Colors.orange,
                                                tooltip: 'print',
                                                icon: const Icon(Icons.print),
                                                onPressed: () {
                                                  Reciept? reciept = getReciept(
                                                      customerData[index]
                                                          ['recieptId']!);
                                                  Customer? customer =
                                                      getCustomer(
                                                          customerData[index]
                                                              ['chtAccAccNo']!);
                                                  if (reciept != null &&
                                                      customer != null) {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    PrintScreen(
                                                                      recieptList: [
                                                                        reciept
                                                                      ],
                                                                      customer:
                                                                          customer,
                                                                      isCopy:
                                                                          true,
                                                                      closeButtonAction:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                    )));
                                                  }
                                                },
                                                
                                              )
                                            ],
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ),
              ],
            ),
    );
  }
}
