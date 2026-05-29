import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:m_sales/helper/app_helper.dart';
import 'package:m_sales/helper/db_helper.dart';
import 'package:m_sales/helper/local_db.dart';
import 'package:m_sales/models/bank.dart';
import 'package:m_sales/models/cheque.dart';
import 'package:m_sales/models/customer.dart';
import 'package:m_sales/models/invoice.dart';
import 'package:m_sales/models/invoice_save_body.dart';
import 'package:m_sales/models/reciept.dart';
import 'package:m_sales/services/data_save_service.dart';

class ReceiptPage extends StatefulWidget {
  final Customer customer;
  const ReceiptPage({Key? key, required this.customer});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  bool isChequeSelected = false;
  var amountController = TextEditingController();
  var chequeAmountController = TextEditingController();
  var chequeNumberController = TextEditingController();
  final chqAccNoController = TextEditingController();
  final menuBankController = TextEditingController();
  final menuBranchController = TextEditingController();
  var bankNameController = TextEditingController();
  var chequeDateController = TextEditingController();
  var chequeDate = DateTime.now();
  SaveDataService saveDataService = SaveDataService();
  List<InvoiceSaveBody> invoiceList = [];
  List<InvoiceSaveBody> finalInvoiceList = [];
  final _formKey = GlobalKey<FormState>();
  List<Cheque> chqList = [];
  double outstanding = 0.00;
  double totlaOutStanding = 0.00;
  List<String> selectedInvoice = [];
  double creditComment = 0.00;
  double invoiceBalanceTotal = 0.00;
  double previousCashAmount = 0.00;
  bool isBankError = false;
  bool isBranchError = false;
  bool isVisibleBranchList = false;
  String? selectedBank;
  String selectedBankCode = '';
  String selectedBranchCode = '';
  List<Bank> bankAllList = [];
  List<BankAndCode> bankFilteredList = [];
  List<Bank> bankBarnchNameList = [];
  String selectedDate = '';
  List<Invoice> invoiceListFromDB = [];
  String? userId = '';
  bool isLoading = true;
  String? priceType;
  @override
  void initState() {
    super.initState();
    getData();
  }

  getInvDetails(String userId, String chtAccAccNo) async {
    finalInvoiceList = [];
    List<InvoiceSaveBody> invoiceList = await saveDataService
        .getInvoiceList(widget.customer.chtAccAccNo.toString());
    invoiceListFromDB = await DatabaseHelper.instance
        .getAllInvoicesByCustomer(userId, chtAccAccNo);
    for (var inv in invoiceList) {
      if (inv.balanceAmt != 0) {
        finalInvoiceList.add(inv);
      }
    }
    setData();
  }

  getData() async {
    userId = await Settings.getUserID();
    getInvDetails(userId!, widget.customer.chtAccAccNo.toString());
    bankAllList = await DatabaseHelper.instance.getBanksByUserId(userId!);
    List<String> bankCodeList = [];

    for (var bank in bankAllList) {
      if (!bankCodeList.contains(bank.bankNo)) {
        bankFilteredList.add(BankAndCode(
            bankName: bank.branchName!.split('~').first,
            bankCode: bank.bankNo));
        bankCodeList.add(bank.bankNo!);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  setData() {
    for (var inv in finalInvoiceList) {
      totlaOutStanding = outstanding + inv.balanceAmt!;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          "Receipt",
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.help),
            tooltip: '??',
            onPressed: () {
              // handle the press
            },
          ),
        ],
        iconTheme: const IconThemeData(
          color: Colors.white, // Change this to the desired color
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // First Card
              Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Info",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Customer",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(widget.customer.chtAccName ?? "",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total Amount", style: TextStyle(fontSize: 12)),
                          Text("LKR ${totlaOutStanding.toStringAsFixed(2)}",
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 3),
              // Cards 1, 2, and 3 in the same row
              Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Invoice Settlement",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Paid Amount",
                              style: TextStyle(fontSize: 12)),
                          Text('LKR ${creditComment.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Alocated Amount",
                              style: TextStyle(fontSize: 12)),
                          Text(
                              'LKR ${double.tryParse(getAllocatedAmount().toString())!.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Balance Amount",
                              style: TextStyle(fontSize: 12)),
                          Text('LKR ${invoiceBalanceTotal.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Container(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: const Text(
                            'Cash',
                            style:
                                TextStyle(fontSize: 15.0, color: Colors.black),
                          ),
                          onPressed: () {
                            _showCashDialog();
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Container(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: const Text(
                            'Cheque',
                            style:
                                TextStyle(fontSize: 15.0, color: Colors.black),
                          ),
                          onPressed: () {
                            _showChequeDialog();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Outstanding Invoices",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: (MediaQuery.of(context).size.height / 2) - 100,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: finalInvoiceList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Card(
                              color: Colors.orange[50],
                              child: ListTile(
                                  minVerticalPadding: 5,
                                  minLeadingWidth: 0,
                                  horizontalTitleGap: 5,
                                  leading: Checkbox(
                                    value: selectedInvoice.contains(
                                        finalInvoiceList[index].invoiceNo!),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (selectedInvoice.contains(
                                            finalInvoiceList[index]
                                                .invoiceNo)) {
                                          selectedInvoice = [];

                                          outstanding = 0.00;
                                          invoiceBalanceTotal =
                                              (creditComment + outstanding);
                                        } else {
                                          selectedInvoice = [];
                                          outstanding = finalInvoiceList[index]
                                              .balanceAmt!;
                                          selectedInvoice.add(
                                              finalInvoiceList[index]
                                                  .invoiceNo!);
                                          invoiceBalanceTotal =
                                              (outstanding - creditComment);
                                        }
                                      });
                                    },
                                  ),
                                  title: Text(finalInvoiceList[index]
                                      .invoiceNo
                                      .toString()),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'LKR ${getPaidToInvoice(finalInvoiceList[index].balanceAmt!, creditComment, finalInvoiceList[index].invoiceNo!)}'),
                                      Text('Allocated Amount',
                                          style: TextStyle(
                                              fontSize: 10.0,
                                              color: Colors.grey.shade800))
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2.6,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                                '${finalInvoiceList[index].docDate}',
                                                style: TextStyle(
                                                    fontSize: 10.0,
                                                    color:
                                                        Colors.grey.shade800)),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2.6,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Inv Amount -',
                                            ),
                                            Text(
                                              'LKR ${getInvAmount(finalInvoiceList[index].invoiceNo!)}',
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2.6,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Due Amount -',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                            Text(
                                              'LKR ${finalInvoiceList[index].balanceAmt!.toStringAsFixed(2)}',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  )),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
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
                    'Process Payment',
                    style: TextStyle(fontSize: 15.0, color: Colors.white),
                  ),
                  onPressed: () {
                    onClickPaymentProcess();
                  },
                ),
              ),
            ),
            SizedBox(
              width: 150,
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
                    'Clear',
                    style: TextStyle(fontSize: 15.0, color: Colors.white),
                  ),
                  onPressed: () {
                    setState(() {
                      creditComment = 0.00;
                      chqList = [];
                      invoiceBalanceTotal = 0.00;
                      amountController.text = '';
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getInvAmount(String invId) {
    Invoice inv = invoiceListFromDB.firstWhere((inv) {
      return inv.invoiceId == invId;
    });
    return inv.netTotal!.toStringAsFixed(2);
  }

  getAllocatedAmount() {
    if (selectedInvoice.isEmpty) {
      return 0.00;
    } else {
      return finalInvoiceList.firstWhere((inv) {
        return inv.invoiceNo == selectedInvoice.first;
      }).balanceAmt!;
    }
  }

  getPaidToInvoice(double balanceAmt, double paid, String invoiceId) {
    if (selectedInvoice.contains(invoiceId)) {
      if (balanceAmt > paid) {
        return paid.toStringAsFixed(2);
      } else {
        return balanceAmt.toStringAsFixed(2);
      }
    } else {
      return '0.00';
    }
  }

  void _showCashDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter Amount"),
          content: TextFormField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Amount"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  creditComment = double.parse(amountController.text);
                  //  previousCashAmount = double.parse(amountController.text);
                  invoiceBalanceTotal = (outstanding - creditComment).abs();
                  chqList = [];
                  chqAccNoController.text = "";
                  chequeAmountController.text = "";
                  isVisibleBranchList = false;
                  menuBankController.text = '';
                  menuBranchController.text = '';
                  selectedBank = null;
                  selectedBankCode = '';
                  selectedBranchCode = '';
                  selectedDate = "";
                  chequeNumberController.text = "";
                  chequeDateController.text = "";
                  isBankError = false;
                  isBranchError = false;
                });
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showChequeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter Cheque Details"),
          content: StatefulBuilder(builder: (context, setPop) {
            return Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonHideUnderline(
                    child: DropdownMenu<BankAndCode>(
                      controller: menuBankController,
                      menuHeight: MediaQuery.of(context).size.height / 2,
                      width: MediaQuery.of(context).size.width - 100,
                      hintText: "Search Bank",
                      requestFocusOnTap: true,
                      enableFilter: true,
                      menuStyle: MenuStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.orange.shade100),
                      ),
                      label: const Text('Select Bank'),
                      onSelected: (BankAndCode? bank) {
                        setPop(() {
                          bankBarnchNameList = bankAllList.where((bnk) {
                            return bnk.bankNo == bank!.bankCode;
                          }).toList();
                          selectedBankCode = bank?.bankCode ?? '';
                          menuBranchController.text = '';
                          isVisibleBranchList = true;
                          isBankError = false;
                        });
                      },
                      dropdownMenuEntries: bankFilteredList.isEmpty
                          ? []
                          : bankFilteredList
                              .map<DropdownMenuEntry<BankAndCode>>(
                                  (BankAndCode bank) {
                              return DropdownMenuEntry<BankAndCode>(
                                value: bank,
                                label: '${bank.bankName!} - ${bank.bankCode}',
                              );
                            }).toList(),
                      searchCallback: (entries, query) {
                        if (query.isEmpty) {
                          return null;
                        }
                        final int index = entries.indexWhere(
                            (DropdownMenuEntry<BankAndCode> entry) =>
                                entry.label == query);

                        return index != -1 ? index : null;
                      },
                    ),
                  ),
                  if (isBankError)
                    const Text(
                      'Bank required',
                      style: TextStyle(color: Colors.red),
                    ),
                  if (isVisibleBranchList)
                    const SizedBox(
                      height: 30,
                    ),
                  if (isVisibleBranchList)
                    DropdownButtonHideUnderline(
                      child: DropdownMenu<Bank>(
                        controller: menuBranchController,
                        menuHeight: MediaQuery.of(context).size.height / 2,
                        width: MediaQuery.of(context).size.width - 100,
                        hintText: "Search Branch",
                        requestFocusOnTap: true,
                        enableFilter: true,
                        menuStyle: MenuStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.orange.shade100),
                        ),
                        label: const Text('Select Branch'),
                        onSelected: (Bank? bank) {
                          setPop(() {
                            selectedBranchCode = bank?.branchNo ?? '';
                            isBranchError = false;
                          });
                        },
                        dropdownMenuEntries: bankBarnchNameList
                            .map<DropdownMenuEntry<Bank>>((Bank bank) {
                          return DropdownMenuEntry<Bank>(
                            value: bank,
                            label:
                                '${bank.branchName?.split('~').last ?? ''} - ${bank.branchNo}',
                          );
                        }).toList(),
                        searchCallback: (entries, query) {
                          if (query.isEmpty) {
                            return null;
                          }
                          final int index = entries.indexWhere(
                              (DropdownMenuEntry<Bank> entry) =>
                                  entry.label == query);

                          return index != -1 ? index : null;
                        },
                      ),
                    ),
                  if (isBranchError && isVisibleBranchList)
                    const Text(
                      'Branch required',
                      style: TextStyle(color: Colors.red),
                    ),
                  TextFormField(
                    validator: (v) {
                      return amountValidator(
                          chequeAmountController.text, 'Amount');
                    },
                    controller: chequeAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Amount"),
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a Cheque No';
                      } else if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                        return 'Cheque No must be exactly 6 digits';
                      }
                      return validator(value,
                          'Cheque No'); // Call your existing validator if needed
                    },
                    controller: chequeNumberController,
                    keyboardType:
                        TextInputType.number, // Use number for cheque numbers
                    decoration: const InputDecoration(labelText: "Cheque No"),
                  ),
                  TextFormField(
                    validator: (v) {
                      return validator(chqAccNoController.text, 'Account No');
                    },
                    decoration: const InputDecoration(
                      labelText: "Account No",
                    ),
                    controller: chqAccNoController,
                    keyboardType: const TextInputType.numberWithOptions(),
                  ),
                  TextFormField(
                    controller: chequeDateController,
                    validator: (v) {
                      return validator(chequeDateController.text, 'Date');
                    },
                    keyboardType: TextInputType.datetime,
                    decoration: const InputDecoration(labelText: "Cheque Date"),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          DateFormat formatter = DateFormat('yyyy-MM-dd');
                          selectedDate = formatter.format(pickedDate);
                          chequeDateController.text =
                              formatter.format(pickedDate);
                          chequeDate = pickedDate;
                        });
                      }
                    },
                  ),
                ],
              ),
            );
          }),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                onClickOk();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  onClickPaymentProcess() async {
    if (creditComment == 0.00) {
      Get.snackbar(
        'Error',
        'Add Payment',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } else {
      List<Reciept> recieptList = await setReciepts();
      bool res =
          await DatabaseHelper.instance.insertReciept(recieptList, priceType!);
      if (res) {
        selectedInvoice = [];
        chqList = [];
        creditComment = 0.00;
        outstanding = 0.00;
        invoiceBalanceTotal = 0.00;
        amountController.text = '';

        getInvDetails(userId!, widget.customer.chtAccAccNo.toString());
        Get.snackbar(
          'Success',
          'Payment Success',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Payment Failed',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  setReciepts() async {
    List<Reciept> recieptListDB = [];
    if (selectedInvoice.isNotEmpty) {
      recieptListDB = await DatabaseHelper.instance
          .getRecieptsByInvoiceId(selectedInvoice.first);
    }

    List<Reciept> recieptList = [];
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    if (chqList.isNotEmpty) {
      for (var chq in chqList) {
        Reciept reciept = Reciept(
            invoiceId: selectedInvoice.isEmpty ? '-' : selectedInvoice.first,
            balance: selectedInvoice.isEmpty
                ? 0.00
                : recieptListDB.first.balance! - chq.chequeAmount!,
            dateTime: formatter.format(now),
            priceType: '',
            netTotal:
                selectedInvoice.isEmpty ? 0.00 : recieptListDB.first.netTotal,
            userId: userId,
            payMode: 'Cheque',
            chtAccAccNo: widget.customer.chtAccAccNo,
            chequeAmount: chq.chequeAmount,
            chequeDate: chq.date,
            chequeNo: chq.chequeNo,
            bankCode: chq.bankNo,
            branchCode: chq.branchNo,
            accountNo: chq.accountNo,
            selectedAmount: chq.chequeAmount,
            paid: selectedInvoice.isEmpty
                ? 0.00
                : recieptListDB.last.paid! + chq.chequeAmount!);

        recieptList.add(reciept);
        priceType = 'Cheque';
      }
    }
    if (amountController.text != "" &&
        double.tryParse(amountController.text)! > 0.0 &&
        chqList.isEmpty) {
      Reciept reciept = Reciept(
          invoiceId: selectedInvoice.isEmpty ? '-' : selectedInvoice.first,
          balance: selectedInvoice.isEmpty
              ? 0.00
              : recieptListDB.first.balance! -
                  double.tryParse(amountController.text)!,
          dateTime: formatter.format(now),
          priceType: '-',
          netTotal:
              selectedInvoice.isEmpty ? 0.00 : recieptListDB.first.netTotal,
          userId: userId,
          payMode: 'Cash',
          chtAccAccNo: widget.customer.chtAccAccNo,
          cashAmount: double.tryParse(amountController.text),
          selectedAmount: double.tryParse(amountController.text),
          paid: selectedInvoice.isEmpty
              ? 0.00
              : recieptListDB.last.paid! +
                  double.tryParse(amountController.text)!);
      recieptList.add(reciept);
      priceType = 'Cash';
    }

    return recieptList;
  }

  amountValidator(String controller, errorItem) {
    if (controller.isEmpty || double.tryParse(controller)! == 0.00) {
      return '$errorItem required';
    }
  }

  onClickOk() {
    if (_formKey.currentState!.validate() &&
        selectedBankCode != '' &&
        selectedBranchCode != '') {
      creditComment = creditComment -
          (double.tryParse(amountController.text.trim()) ?? 0.00);
      amountController.text = '';
      chqList.add(Cheque(
          bankNo: selectedBankCode,
          chequeAmount: double.tryParse(chequeAmountController.text.trim()),
          chequeNo: chequeNumberController.text.toString(),
          branchNo: selectedBranchCode,
          date: selectedDate,
          accountNo: chqAccNoController.text.toString(),
          userId: userId));

      setState(() {
        creditComment = creditComment +
            double.tryParse(chequeAmountController.text.trim())!;
        invoiceBalanceTotal = (outstanding - creditComment).abs();
        chqAccNoController.text = "";
        chequeAmountController.text = "";
        isVisibleBranchList = false;
        menuBankController.text = '';
        menuBranchController.text = '';
        selectedBank = null;
        selectedBankCode = '';
        selectedBranchCode = '';
        selectedDate = "";
        chequeNumberController.text = "";
        chequeDateController.text = "";
        isBankError = false;
        isBranchError = false;
      });

      Get.snackbar(
        'Success',
        'Cheque Added',
        backgroundColor: const Color.fromARGB(255, 50, 118, 52),
        colorText: Colors.white,
      );
      Navigator.of(context).pop();
    }
  }

  void _showCreditDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter Amount"),
          content: TextFormField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Amount"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
