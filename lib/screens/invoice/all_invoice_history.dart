import 'package:flutter/material.dart';
import 'package:m_sales/Widgets/full_screen_loading.dart';
import 'package:m_sales/helper/db_helper.dart';
import 'package:m_sales/helper/local_db.dart';
import 'package:m_sales/models/customer.dart';
import 'package:m_sales/models/invoice.dart';
import 'package:m_sales/screens/invoice/invoice_details.dart';

class AllInvoiceHistory extends StatefulWidget {
  const AllInvoiceHistory({super.key});

  @override
  State<AllInvoiceHistory> createState() => _AllInvoiceHistoryState();
}

class _AllInvoiceHistoryState extends State<AllInvoiceHistory> {
  bool isLoading = true;
  List<Invoice> invoiceList = [];
  List<Customer> customerList = [];
  List<Invoice> finalInvoiceList = [];
  bool isAllInvoices = false;
  String? userId = '';
  @override
  void initState() {
    super.initState();
    getData();
  }

  List<Map<String, String>> customerData = [];
  getData() async {
    userId = await Settings.getUserID();
    invoiceList = await DatabaseHelper.instance.getAllInvoices(userId!);
    customerList = await DatabaseHelper.instance.getCustomersByUserId(userId!);

    // for (var customer in customerList) {
    //   print(customer.toString());
    // }
    finalInvoiceList = invoiceList;
    setState(() {
      isLoading = false;
    });

    for (var i = 0; i < invoiceList.length; i++) {
      for (var j = 0; j < customerList.length; j++) {
        if (int.tryParse(invoiceList[i].chtAccAccNo!) ==
            customerList[j].chtAccAccNo) {
          customerData.add({
            'chtAccAccNo': customerList[j].chtAccAlias!,
            'chtAccName': customerList[j].chtAccName!,
            'invoiceId': invoiceList[i].invoiceId!,
            'totalQty': invoiceList[i].totalQty.toString(),
            'dateTime': invoiceList[i].dateTime.toString(),
            'netTotal': invoiceList[i].netTotal!.toStringAsFixed(2)
          });
        }
      }
    }

    print("----------------customerData--------------------");
    print(customerData);
    print("----------------customerData--------------------");
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
          "Invoice History",
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
                                  Customer customer = getCustomer(
                                      customerData[index]['chtAccAccNo']!);
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => InvoiceDetails(
                                            invoice: finalInvoiceList[index],
                                            customerData: customerData[index],
                                            customer: customer,
                                          )));
                                },
                                child: ListTile(
                                    title: Text(
                                      'Id : ${customerData[index]['invoiceId'] ?? ''} ${customerData[index]['invoiceId'] ?? ''}',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Quantity : ${customerData[index]['totalQty'] ?? ''}\n',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            'Cust/ID :${customerData[index]['chtAccAccNo'] ?? ''}',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            'Cust/Name :${customerData[index]['chtAccName'] ?? ''}',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    trailing: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          customerData[index]['dateTime'] ?? '',
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'LKR ${customerData[index]['netTotal'] ?? ''}',
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    )),
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
