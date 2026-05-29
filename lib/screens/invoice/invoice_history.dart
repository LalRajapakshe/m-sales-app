import 'package:flutter/material.dart';
import 'package:m_sales/Widgets/full_screen_loading.dart';
import 'package:m_sales/Widgets/loading.dart';
import 'package:m_sales/helper/app_helper.dart';
import 'package:m_sales/helper/db_helper.dart';
import 'package:m_sales/helper/local_db.dart';
import 'package:m_sales/models/customer.dart';
import 'package:m_sales/models/invoice.dart';
import 'package:m_sales/screens/invoice/invoice_details.dart';

class InvoiceHistory extends StatefulWidget {
  final Customer customer;
  const InvoiceHistory({super.key, required this.customer});

  @override
  State<InvoiceHistory> createState() => _InvoiceHistoryState();
}

class _InvoiceHistoryState extends State<InvoiceHistory> {
  bool isLoading = true;
  List<Invoice> invoiceList = [];
  List<Invoice> finalInvoiceList = [];
  List<Map<String, String>> customerData = [];
  List<Customer> customerList = [];
  bool isAllInvoices = false;
  String? userId = '';
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    userId = await Settings.getUserID();
    customerList = await DatabaseHelper.instance.getCustomersByUserId(userId!);
    invoiceList = await DatabaseHelper.instance.getAllInvoicesByCustomer(
        userId!, widget.customer.chtAccAccNo.toString());
    finalInvoiceList = invoiceList;

    print("----------------finalInvoiceList--------------------");
    print(finalInvoiceList[0].items);
    print("----------------finalInvoiceList--------------------");
    setState(() {
      isLoading = false;
    });

    customerNameFiltaration();
  }

  customerNameFiltaration() {
    for (var i = 0; i < finalInvoiceList.length; i++) {
      for (var j = 0; j < customerList.length; j++) {
        if (int.tryParse(finalInvoiceList[i].chtAccAccNo!) ==
            customerList[j].chtAccAccNo) {
          customerData.add({
            'chtAccAccNo': customerList[j].chtAccAlias!,
            'chtAccName': customerList[j].chtAccName!,
            'invoiceId': finalInvoiceList[i].invoiceId!,
            'totalQty': finalInvoiceList[i].totalQty.toString(),
            'dateTime': finalInvoiceList[i].dateTime.toString(),
            'netTotal': finalInvoiceList[i].netTotal!.toStringAsFixed(2)
          });
        }
      }
    }
  }

  changeFilter(bool allFilter) async {
    finalInvoiceList = [];
    customerData = [];
    Loading().startLoading(context);
    if (allFilter) {
      finalInvoiceList = await DatabaseHelper.instance.getAllInvoices(userId!);

      customerNameFiltaration();
    } else {
      finalInvoiceList = await DatabaseHelper.instance.getAllInvoicesByCustomer(
          userId!, widget.customer.chtAccAccNo.toString());
      customerNameFiltaration();
    }
    setState(() {});
    Loading().stopLoading(context);
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
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: '?',
            onPressed: () async {
              await syncData(context, widget.customer);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => InvoiceHistory(
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
                        value: isAllInvoices,
                        onChanged: (v) {
                          setState(() {
                            isAllInvoices = v;
                            changeFilter(v);
                          });
                        }),
                    const Text(
                      'All Invoices',
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
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => InvoiceDetails(
                                            invoice: finalInvoiceList[index],
                                            customerData: customerData[index],
                                            customer: widget.customer,
                                          )));
                                },
                                child: ListTile(
                                    title: Text(
                                      'Id : ${customerData[index]['invoiceId'] ?? ''}',
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
