import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m_sales/Widgets/loading.dart';
import 'package:m_sales/helper/app_helper.dart';
import 'package:m_sales/helper/db_helper.dart';
import 'package:m_sales/helper/local_db.dart';
import 'package:m_sales/models/closedTrip.dart';
import 'package:m_sales/models/invoice_save_body.dart';
import 'package:m_sales/models/reciept_save_body.dart';
import 'package:m_sales/models/settlement_save_body.dart';
import 'package:m_sales/screens/business_trip.dart';
import 'package:m_sales/screens/customer/customer_list.dart';
import 'package:m_sales/screens/dashboard/dashboard_page.dart';
import 'package:m_sales/Widgets/drawer/drawer_header.dart';
import 'package:m_sales/screens/invoice/all_invoice_history.dart';
import 'package:m_sales/screens/login.dart';
import 'package:m_sales/screens/receipt/all_reciept_histort.dart';
import 'package:m_sales/services/data_save_service.dart';

import 'package:provider/provider.dart';
import 'package:m_sales/services/auth_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var currentPage = DrawerSections.dashboard;
  var container;
  var tittle;
  String? inProgressTrip;
  String? userId;

  @override
  void initState() {
    super.initState();
    getInProgressTrip();
    getUserId();
  }

  getInProgressTrip() async {
    inProgressTrip = await Settings.getGinStuHdrFgnRefCode();
  }

  getUserId() async {
    userId = await Settings.getUserID();
  }

  @override
  Widget build(BuildContext context) {
    if (currentPage == DrawerSections.dashboard) {
      container = const ChartDash();
      tittle = "Dashboard";
    } else if (currentPage == DrawerSections.customers) {
      container = CustomerList();
      tittle = "Customer";
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          tittle,
          style: const TextStyle(color: Colors.white),
        ),
        // actions: <Widget>[
        //   IconButton(
        //     icon: const Icon(Icons.sync),
        //     tooltip: '??',
        //     onPressed: () {
        //       syncData(context, null);
        //     },
        //   ),
        // ],
        iconTheme: const IconThemeData(
          color: Colors.white, // Change this to the desired color
        ),
      ),
      body: container,
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                const MyDrawerHeader(),
                MyDrawerList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  postMethod() async {
    Loading().startLoading(context);
    SaveDataService saveDataService = SaveDataService();
    List<InvoiceSaveBody> invoiceList = [];
    List<RecieptSaveBody> recieptList = [];
    List<SettlementSaveBody> settlementList = [];

    invoiceList = await saveDataService.getInvoiceList(null);
    recieptList = await saveDataService.getAllReceipts();
    settlementList = await saveDataService.getSettlementList();

    for (var element in invoiceList) {
      print(element.toJson());
    }
    for (var element in recieptList) {
      print(element.toJson());
    }
    for (var element in settlementList) {
      print(element.toJson());
    }

    bool invRes = await saveDataService.saveInvoices(invoiceList);
    bool recRes = await saveDataService.saveReciepts(recieptList);
    bool setRes = await saveDataService.saveSettlements(settlementList);
    SaveDataService().getDocAttribute();
    Loading().stopLoading(context);
    if (invRes && recRes && setRes) {
      return true;
    } else {
      return false;
    }
  }

  postData() async {
    bool val = await postMethod();
    if (val) {
      Get.snackbar(
        'Success',
        'Saved Successfully',
        backgroundColor: Color.fromARGB(255, 50, 118, 52),
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

/*   onTapTourClose() async {
    if (inProgressTrip != null || inProgressTrip != '') {
      await postMethod();
      await DatabaseHelper.instance.insertClosedTrip(
          ClosedTrip(ginStuHdrFgnRefCode: inProgressTrip, userId: userId));
      Settings.setGinStuHdrFgnRefCode('');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const SecondPage(),
        ),
        (route) => false,
      );
    }
  } */
 onTapTourClose() async {
  if (inProgressTrip == null || inProgressTrip!.isEmpty) {
    Get.snackbar(
      'Warning',
      'No active tour found',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
    return;
  }

  Loading().startLoading(context);

  final hasValidToken = await Provider.of<AuthService>(
    context,
    listen: false,
  ).ensureValidAccessToken();

  if (!hasValidToken) {
    Loading().stopLoading(context);
    Get.snackbar(
      'Connection Required',
      'Tour Close requires an internet connection. Please connect and try again.',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return;
  }

  final success = await tourClose();

  Loading().stopLoading(context);

  if (success) {
    Get.snackbar(
      'Success',
      'Tour closed successfully',
      backgroundColor: const Color.fromARGB(255, 50, 118, 52),
      colorText: Colors.white,
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const SecondPage(),
      ),
      (route) => false,
    );
  } else {
    Get.snackbar(
      'Tour Close Failed',
      'Tour was not closed. Please try again.',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}

  onTapSyncData() {
    syncData(context, null);
  }

  Widget MyDrawerList() {
    return Container(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        children: [
          menuItem(1, "Dashboard", Icons.dashboard,
              currentPage == DrawerSections.dashboard ? true : false, null),
          menuItem(2, "Customers", Icons.supervised_user_circle,
              currentPage == DrawerSections.customers ? true : false, null),
          menuItem(3, "Save records", Icons.save,
              currentPage == DrawerSections.save ? true : false, () {
            postData();
          }),
          menuItem(4, "All Invoices", Icons.inventory_outlined,
              currentPage == DrawerSections.invoice ? true : false, () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AllInvoiceHistory(),
                ));
          }),
          menuItem(5, "All Reciepts", Icons.receipt,
              currentPage == DrawerSections.reciept ? true : false, () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AllRecieptHistory(),
                ));
          }),
          menuItem(5, "Tour Close", Icons.close_rounded,
              currentPage == DrawerSections.tourClose ? true : false, () async {
            onTapTourClose();
          }),
          menuItem(6, "Sync", Icons.sync,
              currentPage == DrawerSections.syncData ? true : false, () async {
            onTapSyncData();
          }),
          menuItem(7, "Log Out", Icons.logout,
              currentPage == DrawerSections.LogOut ? true : false, () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
              (route) => route.isFirst,
            );
          }),
        ],
      ),
    );
  }

  Widget menuItem(int id, String tittle, IconData icon, bool selected,
      Function? onClicked) {
    return Material(
      color: selected ? Colors.orange[50] : Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          if (onClicked == null) {
            setState(() {
              if (id == 1) {
                currentPage = DrawerSections.dashboard;
              } else if (id == 2) {
                currentPage = DrawerSections.customers;
              }
            });
          } else {
            onClicked();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Expanded(
                  child: Icon(
                icon,
                size: 20,
                color: selected ? Colors.orange[700] : Colors.grey,
              )),
              Expanded(
                  flex: 3,
                  child: Text(
                    tittle,
                    style: selected
                        ? TextStyle(color: Colors.orange[700], fontSize: 16)
                        : const TextStyle(color: Colors.black, fontSize: 16),
                  ))
            ],
          ),
        ),
      ),
    );
  }

 Future<bool> tourClose() async {
  final saveDataService = SaveDataService();

  try {
    final userId = await Settings.getUserID();

    if (userId == null || userId.isEmpty) {
      throw Exception('User ID not found');
    }

    final ginNo = await Settings.getGinStuHdrFgnRefCode();

    if (ginNo == null || ginNo.isEmpty) {
      throw Exception('No active tour found');
    }

    // --------------------------------------------------
    // 1. GET CURRENT DOCS
    // --------------------------------------------------

    final docs = await DatabaseHelper.instance.getDocDetails();

    if (docs.repCode == null) {
      throw Exception('Representative code not found');
    }

    print('Tour Close Docs');
    print('RepCode: ${docs.repCode}');
    print('InvLastNo: ${docs.invLastNo}');
    print('CashReceLastNo: ${docs.cashReceLastNo}');
    print('BankReceLastNo: ${docs.bankReceLastNo}');
    print('ReturnLastNo: ${docs.returnLastNo}');

    // --------------------------------------------------
    // 2. BUILD LOCAL TRANSACTION LISTS
    // --------------------------------------------------

    final invoiceList =
        await saveDataService.getInvoiceList(null);

    final receiptList =
        await saveDataService.getAllReceipts();

    final settlementList =
        await saveDataService.getSettlementList();

    print('Invoices: ${invoiceList.length}');
    print('Receipts: ${receiptList.length}');
    print('Settlements: ${settlementList.length}');

    // --------------------------------------------------
    // 3. SAVE INVOICES
    // --------------------------------------------------

    final invRes =
        await saveDataService.saveInvoices(invoiceList);

    if (!invRes) {
      print('Tour Close stopped: invoice upload failed');
      return false;
    }

    // --------------------------------------------------
    // 4. SAVE RECEIPTS
    // --------------------------------------------------

    final recRes =
        await saveDataService.saveReciepts(receiptList);

    if (!recRes) {
      print('Tour Close stopped: receipt upload failed');
      return false;
    }

    // --------------------------------------------------
    // 5. SAVE SETTLEMENTS
    // --------------------------------------------------

    final setRes =
        await saveDataService.saveSettlements(settlementList);

    if (!setRes) {
      print('Tour Close stopped: settlement upload failed');
      return false;
    }

    // --------------------------------------------------
    // 4. UPDATE LAST NUMBERS ON SERVER
    // --------------------------------------------------

    final docUpdateResult =
        await saveDataService.updateDocAttributeMaster(
      repCode: docs.repCode!,
      invLastNo: docs.invLastNo ?? 0,
      cashReceLastNo: docs.cashReceLastNo ?? 0,
      bankReceLastNo: docs.bankReceLastNo ?? 0,
      returnLastNo: docs.returnLastNo ?? 0,
    );

    if (!docUpdateResult) {
      print('Tour Close stopped: document number update failed');
      return false;
    }

    // --------------------------------------------------
    // 5. VERIFY SERVER DOCUMENTS
    // --------------------------------------------------

    final verificationResult =
        await saveDataService.verifyTourClose(
      ginNo: ginNo,
      dateTime: DateTime.now()
          .toString()
          .substring(0, 19),
      invoiceList: invoiceList,
      receiptList: receiptList,
      settlementList: settlementList,
    );

    if (!verificationResult) {
      print('Tour Close stopped: verification failed');
      return false;
    }

    // --------------------------------------------------
    // 6. UPDATE GIN STATUS ON SERVER (FGN reference)
    // --------------------------------------------------

    final ginResult = await Provider.of<AuthService>(
      context,
      listen: false,
    ).updateGin(ginNo);

    if (!ginResult) {
      print('Tour Close stopped: GIN update failed');
      return false;
    }

    // --------------------------------------------------
    // 7. CLEAR LOCAL TOUR DATA
    // --------------------------------------------------

    await DatabaseHelper.instance
        .clearTourCloseData(userId);

    // --------------------------------------------------
    // 10. MARK TOUR CLOSED
    // --------------------------------------------------

    await DatabaseHelper.instance.insertClosedTrip(
      ClosedTrip(
        ginStuHdrFgnRefCode: ginNo,
        userId: userId,
      ),
    );

    // --------------------------------------------------
    // 11. CLEAR ACTIVE GIN
    // --------------------------------------------------

    await Settings.setGinStuHdrFgnRefCode('');

    return true;
  } catch (error) {
    print('Tour Close Error: $error');
    return false;
  }
} 
}

enum DrawerSections {
  dashboard,
  customers,
  save,
  invoice,
  reciept,
  tourClose,
  syncData,
  LogOut
}
