import 'package:flutter/material.dart';
import 'package:m_sales/Widgets/full_screen_loading.dart';
import 'package:m_sales/helper/db_helper.dart';
import 'package:m_sales/models/customer.dart';
import 'package:m_sales/models/gin_response.dart';
import 'package:m_sales/models/invoice.dart';
import 'package:m_sales/models/setting_types.dart';
import 'package:m_sales/screens/print/print_screen.dart';
import 'package:m_sales/services/cart_service.dart';
import 'package:provider/provider.dart';

class InvoiceDetails extends StatefulWidget {
  final Invoice invoice;
  final Map<String, String> customerData;
  final Customer customer;
  const InvoiceDetails(
      {super.key,
      required this.invoice,
      required this.customerData,
      required this.customer});

  @override
  State<InvoiceDetails> createState() => _InvoiceDetailsState();
}

class _InvoiceDetailsState extends State<InvoiceDetails> {
  SettingTypes? settingType;
  bool isLoading = true;

  double getItemPrice(double price, double qty) {
    return price * qty;
  }

  double getUnitPrice(
      Invoice invoice, LineItemsSelected item, SettingTypes settingType) {
    double unitDefaultPrice = item.item?.itMstDefualtPrice ?? 0.00;
    double tax = 0.00;
    if (invoice.tax != null && invoice.tax! > 0.00) {
      if (settingType.vattype == 'VAT_INCLUDE') {
        tax = ((item.item?.itMstDefualtPrice ?? 0.0) * 18 / (100 + 18));
      } else {
        tax = ((item.item?.itMstDefualtPrice ?? 0.0) * 18 / (100));
      }
      return (unitDefaultPrice - tax);
    } else {
      return unitDefaultPrice;
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    settingType = await DatabaseHelper.instance.getSettingType();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          "${widget.invoice.isReturn=='true'?'Return': 'Invoice'} - ${widget.invoice.invoiceId}",
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // Change this to the desired color
        ),
      ),
      body: isLoading
          ? FullScreenLoading()
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              child: Column(
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
                              Text(widget.invoice.dateTime ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Customer Id",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(widget.customerData['chtAccAccNo'] ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Customer Name",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(widget.customerData['chtAccName'] ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
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
                        itemCount: widget.invoice.items!.length,
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
                              child: ListTile(
                                  title: Text(
                                    '${widget.invoice.items![index].item?.ginStuName ?? ''}*${widget.invoice.items![index].selectedQuantity ?? ''}',
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
                                          'B/NO:${widget.invoice.items![index].item?.ginBatchNo.toString() ?? ''}'),
                                      Text(
                                          'I/CODE: ${widget.invoice.items![index].item?.ginStuAlise ?? ''}'),
                                    ],
                                  ),
                                  trailing: Column(
                                    children: [
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        '${getUnitPrice(widget.invoice, widget.invoice.items![index], settingType!).toStringAsFixed(2) ?? ''}*${widget.invoice.items![index].selectedQuantity ?? ''}',
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        getItemPrice(
                                                getUnitPrice(
                                                    widget.invoice,
                                                    widget
                                                        .invoice.items![index],
                                                    settingType!),
                                                widget.invoice.items![index]
                                                        .selectedQuantity ??
                                                    0.00)
                                            .toStringAsFixed(2),
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  )),
                            ),
                          );
                        }),
                  ),
                  // Container(
                  //   padding: const EdgeInsets.all(
                  //       5.0), // Adjust the value as per your requirement

                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.start,
                  //     children: [
                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           Radio(
                  //             value: 'In_vat',
                  //             groupValue: _selectedValue,
                  //             onChanged: (value) {
                  //               setState(() {
                  //                 _selectedValue = value!;
                  //                 calculateNetTotal();
                  //                 Settings.setVatType('In_vat');
                  //               });
                  //             },
                  //           ),
                  //           const Text('Include vat'),
                  //           Radio(
                  //             value: 'Ex_vat',
                  //             groupValue: _selectedValue,
                  //             onChanged: (value) {
                  //               setState(() {
                  //                 _selectedValue = value!;
                  //                 calculateNetTotal();
                  //                 Settings.setVatType('Ex_vat');
                  //               });
                  //             },
                  //           ),
                  //           const Text('Exclude vat'),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // ),
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
                              Text(widget.invoice.totalQty.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
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
                              Text(
                                  widget.invoice.grossTotal!.toStringAsFixed(2),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
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
                              Text(widget.invoice.tax!.toStringAsFixed(2),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
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
                              Text(widget.invoice.netTotal!.toStringAsFixed(2),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4.0, vertical: 10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 222, 171, 95),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: const Text(
                              'Print',
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.white),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PrintScreen(
                                        invoice: widget.invoice,
                                        recieptList: [],
                                        customer: widget.customer,
                                        isCopy: true,
                                        closeButtonAction: () {
                                          Navigator.pop(context);
                                        },
                                      )));
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
