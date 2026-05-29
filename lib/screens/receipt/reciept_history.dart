import 'package:flutter/material.dart';
import 'package:m_sales/Widgets/full_screen_loading.dart';
import 'package:m_sales/Widgets/loading.dart';
import 'package:m_sales/helper/app_helper.dart';
import 'package:m_sales/helper/db_helper.dart';
import 'package:m_sales/helper/local_db.dart';
import 'package:m_sales/models/customer.dart';
import 'package:m_sales/models/reciept.dart';
import 'package:m_sales/screens/print/print_screen.dart';

class RecieptHistory extends StatefulWidget {
  final Customer customer;
  const RecieptHistory({super.key, required this.customer});

  @override
  State<RecieptHistory> createState() => _RecieptHistoryState();
}

class _RecieptHistoryState extends State<RecieptHistory> {
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
    recieptList = await DatabaseHelper.instance
        .getAllRecieptByCustomer(userId!, widget.customer.chtAccAccNo!);
    customerList = await DatabaseHelper.instance.getCustomersByUserId(userId!);
    finalRecieptList = recieptList;
    setState(() {
      isLoading = false;
    });

    customerNameFilterartion();
  }

  customerNameFilterartion() {
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

  changeFilter(bool allFilter) async {
    finalRecieptList = [];
    customerData = [];
    Loading().startLoading(context);
    if (allFilter) {
      finalRecieptList = await DatabaseHelper.instance.getAllReciepts();
      customerNameFilterartion();
    } else {
      finalRecieptList = await DatabaseHelper.instance
          .getAllRecieptByCustomer(userId!, widget.customer.chtAccAccNo!);
      customerNameFilterartion();
    }
    setState(() {});
    Loading().stopLoading(context);
  }

  getReciept(String recieptId) {
    return finalRecieptList.firstWhere((rst) {
      return rst.recieptId == recieptId;
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
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: '?',
            onPressed: () async {
              await syncData(context, widget.customer);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => RecieptHistory(
                          customer: widget.customer,
                        )),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const FullScreenLoading()
          : Column(
              children: [
                Row(
                  children: [
                    Switch(
                        activeColor: Colors.orange,
                        value: isAllReciepts,
                        onChanged: (v) {
                          setState(() {
                            isAllReciepts = v;
                            changeFilter(v);
                          });
                        }),
                    const Text(
                      'All Reciepts',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 5),
                    child: ListView.builder(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
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
                                          Container(
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
                                                  if (reciept != null) {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    PrintScreen(
                                                                      recieptList: [
                                                                        reciept
                                                                      ],
                                                                      customer:
                                                                          widget
                                                                              .customer,
                                                                              isCopy: true,
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
                                          ),
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
