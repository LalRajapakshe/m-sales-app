import 'package:flutter/material.dart';
import 'package:m_sales/Widgets/custome-components/tab_item.dart';
import 'package:m_sales/helper/app_helper.dart';
import 'package:m_sales/models/customer.dart';
import 'package:m_sales/models/invoice.dart';
import 'package:m_sales/models/reciept.dart';
import 'package:m_sales/screens/customer/customer_details.dart';
import 'package:m_sales/screens/invoice/category.dart';
import 'package:m_sales/screens/invoice/order.dart';
import 'package:m_sales/screens/invoice/payment.dart';
import 'package:m_sales/screens/invoice/summery.dart';
import 'package:m_sales/screens/print/print_screen.dart';
import 'package:m_sales/services/cart_service.dart';
import 'package:provider/provider.dart';

class InvoicePage extends StatefulWidget {
  final Customer customer;
  final InvoicePages? page;
  final int? index;
  const InvoicePage({super.key, required this.customer, this.page, this.index});

  @override
  _InvoicePageState createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  var currentPage = InvoicePages.category;
  late TabController tabController;
  int? invoiceId = 0;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    if (widget.page != null && widget.index != null) {
      currentPage = widget.page!;
      tabController.index = widget.index!;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () async {
        Provider.of<CartService>(context, listen: false).clearCart();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              size: 20,
              color: Colors.white,
            ),
            tooltip: '??',
            onPressed: () {
              Provider.of<CartService>(context, listen: false).clearCart();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => CustomerDetails(
                        callGet: false,
                        customer: widget.customer,
                      )));
            },
          ),
          backgroundColor: Colors.orange,
          title: const Text(
            "Invoice",
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            if (currentPage != InvoicePages.summery &&
                currentPage != InvoicePages.payment)
              IconButton(
                icon: const Icon(Icons.sync),
                tooltip: '?',
                onPressed: () async {
                  await syncData(context, widget.customer);
                  Provider.of<CartService>(context, listen: false).clearCart();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => InvoicePage(
                              customer: widget.customer,
                              page: currentPage,
                              index: tabController.index,
                            )),
                  );
                },
              ),
          ],
          iconTheme: const IconThemeData(
            color: Colors.white, // Change this to the desired color
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(30),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8), // Add padding here
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: Colors.orange.shade100,
                  ),
                  child: IgnorePointer(
                    ignoring: true,
                    child: TabBar(
                      controller: tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: const BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black54,
                      tabs: const [
                        TabItem(tittle: "Category"),
                        TabItem(tittle: "Order"),
                        TabItem(tittle: "Summary"),
                        TabItem(tittle: "Payment"),
                      ],
                      // onTap: (index) {
                      //   setState(() {
                      //     switch (index) {
                      //       case 0:
                      //         currentPage = InvoicePages.category;
                      //         break;
                      //       case 1:
                      //         currentPage = InvoicePages.order;
                      //         break;
                      //       case 2:
                      //         currentPage = InvoicePages.summery;
                      //         break;
                      //       case 3:
                      //         currentPage = InvoicePages.payment;
                      //         break;
                      //       default:
                      //         currentPage = InvoicePages.category;
                      //     }
                      //   });
                      // },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: getPage(currentPage),
      ),
    );
  }

  Widget getPage(InvoicePages page) {
    switch (page) {
      case InvoicePages.category:
        return CategoryPage(
          callBack: () {
            setState(() {
              currentPage = InvoicePages.order;
              tabController.index = 1;
            });
          },
        );
      case InvoicePages.order:
        return OrderPage(
          customer: widget.customer,
          callBack: () {
            setState(() {
              currentPage = InvoicePages.summery;
              tabController.index = 2;
            });
          },
          callBackForback: () {
            setState(() {
              Provider.of<CartService>(context, listen: false).clearCart();
              currentPage = InvoicePages.category;
              tabController.index = 0;
            });
          },
        );
      case InvoicePages.summery:
        return SummeryPage(
          customer: widget.customer,
          callBack: (_invoiceId) {
            setState(() {
              invoiceId = _invoiceId;
              currentPage = InvoicePages.payment;
              tabController.index = 3;
            });
          },
          callBackForBack: () {
            setState(() {
              currentPage = InvoicePages.order;
              tabController.index = 1;
            });
          },
        );
      case InvoicePages.payment:
        return PaymentPage(
          customer: widget.customer,
          invoiceId: invoiceId!,
          callBack: (Invoice invoice, List<Reciept> recieptList) {
            setState(() {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => PrintScreen(
                        invoice: invoice,
                        recieptList: recieptList,
                        customer: widget.customer,
                        isCopy: false,
                      )));
            });
          },
          callBackForBack: () {
            setState(() {
              tabController.index = 2;
              currentPage = InvoicePages.summery;
            });
          },
        );
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

enum InvoicePages { category, order, summery, payment }
