import 'package:flutter/material.dart';
import 'package:m_sales/Widgets/full_screen_loading.dart';
import 'package:m_sales/helper/app_helper.dart';
import 'package:m_sales/helper/local_db.dart';
import 'package:m_sales/models/customer.dart';
import 'package:m_sales/screens/invoice/invoice_history.dart';
import 'package:m_sales/screens/invoice/invoice_page.dart';
import 'package:m_sales/screens/receipt/receipt_page.dart';
import 'package:m_sales/screens/receipt/reciept_history.dart';
import 'package:m_sales/screens/shop-return/shop_returns.dart';
import 'package:m_sales/services/customer_service.dart';
import 'package:provider/provider.dart'; // Importing the charts library

class CustomerDetails extends StatefulWidget {
  final Customer customer;
  final bool callGet;
  const CustomerDetails(
      {super.key, Key? keys, required this.customer, required this.callGet});

  @override
  State<CustomerDetails> createState() => _CustomerDetailsState();
}

class _CustomerDetailsState extends State<CustomerDetails> {
  final List<Map<String, dynamic>> summeryData = [
    {
      'date': '2022-10-15 10.15',
      'listCode': '20',
      'price': 'LKR 1,680.00',
    },
    {
      'date': '2024-01-10 2.15',
      'listCode': '21',
      'price': 'LKR 2,680.00',
    },
    {
      'date': '2024-08-09 12.25',
      'listCode': '22',
      'price': 'LKR 3,680.00',
    },
  ];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.callGet) {
      getData();
    }
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    String refCode = await Settings.getGinStuHdrFgnRefCode() ?? '';
    if (refCode.isEmpty) {
      await getPrices(widget.customer.userId!, refCode);
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  getPrices(String userId, String refCode) async {
    await Provider.of<CustomerProvider>(context, listen: false).fetchPrices(
        userId, refCode, widget.customer.chtAccPriceTblCode!, 'Cash');
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.orange,
        title: const Text(
          "Customer Details",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 20,
            color: Colors.white,
          ),
          tooltip: '??',
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.sync,
              color: Colors.white,
            ),
            tooltip: '??',
            onPressed: () async {
              await syncData(context, widget.customer);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => CustomerDetails(
                          customer: widget.customer,
                          callGet: true,
                        )),
              );
            },
          ),
        ],
        iconTheme: const IconThemeData(
          color: Colors.white, // Change this to the desired color
        ),
      ),
      body: isLoading
          ? const FullScreenLoading()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: Colors.orange[50],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      // Wrap the Column with SingleChildScrollView
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.customer.chtAccName ?? 'Customer Name',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.customer.chtAccAddress ?? 'Customer Address',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Contact",
                                  style: TextStyle(fontSize: 15)),
                              Text(widget.customer.emiNo ?? '+94 777777777',
                                  style: const TextStyle(fontSize: 15)),
                            ],
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Current Balance",
                                  style: TextStyle(fontSize: 15)),
                              Text("LKR 00.00", style: TextStyle(fontSize: 15)),
                            ],
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Credit Limit",
                                  style: TextStyle(fontSize: 15)),
                              Text('LKR 00.00',
                                  style: const TextStyle(fontSize: 15)),
                            ],
                          ),
                          // Add more rows as needed
                        ],
                      ),
                    ),
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              iconSize: 40,
                              color: Colors.orange,
                              tooltip: 'Invoice',
                              icon: const Icon(Icons.add_shopping_cart_rounded),
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => InvoicePage(
                                            customer: widget.customer)));
                              },
                            ),
                            IconButton(
                              iconSize: 40,
                              color: Colors.orange,
                              tooltip: 'Unproductive Call',
                              icon: const Icon(Icons.file_copy_outlined),
                              onPressed: () {},
                            ),
                            IconButton(
                              iconSize: 40,
                              color: Colors.orange,
                              tooltip: 'Customer Details',
                              icon: const Icon(Icons.assignment_ind_outlined),
                              onPressed: () {},
                            ),
                            IconButton(
                              iconSize: 40,
                              color: Colors.orange,
                              tooltip: 'Receipt',
                              icon: const Icon(Icons.receipt),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ReceiptPage(
                                          customer: widget.customer,
                                        )));
                              },
                            ),
                            IconButton(
                              iconSize: 40,
                              color: Colors.orange,
                              tooltip: 'Advanced Payment',
                              icon: const Icon(Icons.payment),
                              onPressed: () {},
                            ),
                            IconButton(
                              iconSize: 40,
                              color: Colors.orange,
                              tooltip: 'Shop Return',
                              icon: const Icon(Icons.shopping_cart_outlined),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ShopReturnPage(
                                        customer: widget.customer)));
                              },
                            ),
                          ],
                        ),
                      ),
                      // Expanded(
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(8.0),
                      //     child: charts.LineChart(
                      //       _createSampleData(),
                      //       animate: true,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),

                // Expanded(
                //   flex: 2,
                //   child: SingleChildScrollView(
                //     child: Card(
                //       color: Colors.orange[50],
                //       child: Column(
                //         children: List.generate(
                //           summeryData.length,
                //           (index) => Container(
                //             decoration: BoxDecoration(
                //               borderRadius: BorderRadius.circular(12),
                //               color: index % 2 == 0
                //                   ? Colors.orange[50]
                //                   : Colors.orange[80],
                //               border: Border(
                //                 bottom: BorderSide(color: Colors.grey.shade300),
                //               ),
                //             ),
                //             child: ListTile(
                //               title: Column(
                //                 children: [
                //                   Row(
                //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //                     children: [
                //                       Text(
                //                         summeryData[index]['date'],
                //                         style: const TextStyle(
                //                             fontSize: 13,
                //                             fontWeight: FontWeight.bold),
                //                       ),
                //                       Text(summeryData[index]['price'],
                //                           style: const TextStyle(
                //                               fontSize: 14,
                //                               fontWeight: FontWeight.bold)),
                //                     ],
                //                   ),
                //                 ],
                //               ),
                //               leading: Text(
                //                 summeryData[index]['listCode'],
                //                 style: TextStyle(color: Colors.orange[700]),
                //               ),
                //               trailing: IconButton(
                //                 icon: const Icon(Icons.settings_backup_restore),
                //                 color: Colors.purple[800],
                //                 onPressed: () {},
                //               ),
                //             ),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
      bottomNavigationBar: Padding(
        padding:
            const EdgeInsets.only(bottom: 8.0), // Padding only from the bottom
        child: Row(
          mainAxisAlignment: MainAxisAlignment
              .spaceAround, // Evenly space the buttons with small space between
          children: <Widget>[
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
                    'Invoice History',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15.0, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => InvoiceHistory(
                              customer: widget.customer,
                            )));
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
                    'Reciept History',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15.0, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => RecieptHistory(
                              customer: widget.customer,
                            )));
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
                    'Visit Note History',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15.0, color: Colors.white),
                  ),
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to create sample data for the line chart
  // List<charts.Series<LinearSales, int>> _createSampleData() {
  //   final data = [
  //     LinearSales(0, 5),
  //     LinearSales(1, 25),
  //     LinearSales(2, 100),
  //     LinearSales(3, 75),
  //   ];

  //   return [
  //     charts.Series<LinearSales, int>(
  //       id: 'Sales',
  //       colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
  //       domainFn: (LinearSales sales, _) => sales.year,
  //       measureFn: (LinearSales sales, _) => sales.sales,
  //       data: data,
  //     )
  //   ];
  // }
}

// Class to hold the sample data for the line chart
class LinearSales {
  final int year;
  final int sales;

  LinearSales(this.year, this.sales);
}
