import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:m_sales/Widgets/custome-components/custome_text_field.dart';
import 'package:m_sales/helper/app_helper.dart';
import 'package:m_sales/helper/db_helper.dart';
import 'package:m_sales/helper/local_db.dart';
import 'package:m_sales/models/bank.dart';
import 'package:m_sales/models/cheque.dart';
import 'package:m_sales/models/customer.dart';
import 'package:m_sales/models/gin_response.dart';
import 'package:m_sales/models/invoice.dart';
import 'package:m_sales/models/reciept.dart';
import 'package:m_sales/models/setting_types.dart';
import 'package:m_sales/screens/print/pdf_create.dart';
import 'package:m_sales/services/cart_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentPage extends StatefulWidget {
  final int invoiceId;
  final Customer customer;
  final Function callBack;
  final Function callBackForBack;
  const PaymentPage(
      {super.key,
      required this.invoiceId,
      required this.customer,
      required this.callBackForBack,
      required this.callBack});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  double netTotal = 0.00;
  final cashController = TextEditingController();
  final chqAmountController = TextEditingController();
  final chqAccNoController = TextEditingController();
  final chqNoController = TextEditingController();
  final bankController = TextEditingController();
  final dateController = TextEditingController();
  final creditController = TextEditingController();
  final menuBankController = TextEditingController();
  final menuBranchController = TextEditingController();
  double balance = 0.00;
  double cashBalance = 0.00;
  double creditBalance = 0.00;
  List<List<LineItemsSelected>> items = [];
  List<LineItemsSelected> allItems = [];
  SettingTypes settingType = SettingTypes.empty();
  double grossTotal = 0.00;
  double tax = 0.00;
  double qty = 0.00;
  String priceType = 'Cash';
  String? selectedBank;
  String selectedBankCode = '';
  String selectedBranchCode = '';
  List<Bank> bankAllList = [];
  List<BankAndCode> bankFilteredList = [];
  List<Bank> bankBarnchNameList = [];
  String selectedDate = '';
  DateTime date = DateTime.now();
  List<Cheque> chequeList = [];
  String? userId = '';
  double chequePaid = 0.00;
  double tempBalCashController = 0.00;
  double tempBalCreditController = 0.00;
  final _formKey = GlobalKey<FormState>();
  bool isBankError = false;
  bool isBranchError = false;
  bool isVisibleBranchList = false;

  Invoice? finalInvoiceToPrint;
  List<Reciept> finalRecieptListToPrint = [];

  String checkerr = 'NO';

  bool _isToggled = false;

  @override
  void initState() {
    super.initState();

    getData();
  }

  getData() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    checkerr = sharedPrefs.getString('invCheck')!;

    netTotal = Provider.of<CartService>(context, listen: false).netTotal;
    grossTotal = Provider.of<CartService>(context, listen: false).grossTotal;
    tax = Provider.of<CartService>(context, listen: false).tax;
    userId = await Settings.getUserID();
    bankAllList = await DatabaseHelper.instance.getBanksByUserId(userId!);
    List<String> bankCodeList = [];

    print("--------------INV CHECK------------------");

    print("--------------INV CHECK------------------");

    for (var bank in bankAllList) {
      if (!bankCodeList.contains(bank.bankNo)) {
        bankFilteredList.add(BankAndCode(
            bankName: bank.branchName!.split('~').first,
            bankCode: bank.bankNo));
        bankCodeList.add(bank.bankNo!);
      }
    }
    settingType = await DatabaseHelper.instance.getSettingType();
    priceType = Provider.of<CartService>(context, listen: false).getPriceType;
    if (priceType == 'Credit' && settingType.payModeBase == 'YES') {
      creditController.text = netTotal.toStringAsFixed(2);
      creditBalance = netTotal;
    }
    items = Provider.of<CartService>(context, listen: false).cart;
    for (var itm in items) {
      for (var _itm in itm) {
        if (_itm.selectedQuantity != 0) {
          allItems.add(_itm);
        }
      }
    }
    getTotalQty();
    setState(() {});
  }

  getTotalQty() {
    for (var item in allItems) {
      qty = qty + (item.selectedQuantity ?? 0);
    }
    setState(() {});
  }

  onPressedSave() async {
    if (settingType.payModeBase == 'YES') {
      if (priceType == 'Cash') {
        if (_isToggled) {
          save(checkerr);
        } else if (cashController.text == "" ||
            !(double.tryParse(cashController.text)! > 0.00)) {
          Get.snackbar(
            'Error',
            'Cash amount required',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } else {
          save(checkerr);
        }
      } else if (priceType == 'Cheque') {
        if (_isToggled) {
          save(checkerr);
        } else if (chequeList.isEmpty &&
            (cashController.text == "" ||
                !(double.tryParse(cashController.text)! > 0.00))) {
          Get.snackbar(
            'Error',
            'Payment  amount required',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } else {
          save(checkerr);
        }
      } else if (priceType == 'Credit') {
        if (_isToggled) {
          save(checkerr);
        } else if (creditController.text == "" ||
            !(double.tryParse(creditController.text)! > 0.00)) {
          Get.snackbar(
            'Error',
            'Credit required',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } else {
          save(checkerr);
        }
      }
    } else {
      if (_isToggled) {
        save(checkerr);
      } else if (chequeList.isEmpty &&
          (cashController.text == "" ||
              !(double.tryParse(cashController.text)! > 0.00)) &&
          (creditController.text == "" ||
              !(double.tryParse(creditController.text)! > 0.00))) {
        Get.snackbar(
          'Error',
          'Payment  amount required',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        save(checkerr);
      }
    }
  }

  save(String? checker) async {
    String? userId = await Settings.getUserID();
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    List<Reciept> finalRecieptList = [];

    if (settingType.payModeBase == 'YES') {
      Invoice invoice = Invoice(
          userId: userId,
          vatIncExc: settingType.vattype,
          totalQty: qty,
          items: allItems,
          grossTotal: double.tryParse(grossTotal.toStringAsFixed(2)),
          tax: double.tryParse(tax.toStringAsFixed(2)),
          netTotal: double.tryParse(netTotal.toStringAsFixed(2)),
          dateTime: formatter.format(now),
          chtAccAccNo: widget.customer.chtAccAccNo.toString(),
          payMode: priceType,
          isReturn: 'false');
      finalInvoiceToPrint = invoice;
      int? _id = await DatabaseHelper.instance.insertInvoice(invoice);
      if (_id != null) {
        finalRecieptList = await saveReciepts(_id);
      }

      finalRecieptListToPrint = finalRecieptList;
      bool res = await DatabaseHelper.instance
          .insertReciept(finalRecieptList, priceType);

      List<LineItems> shouldUpdateHandsOnQtyList = [];
      for (var itm in allItems) {
        shouldUpdateHandsOnQtyList.add(itm.item!);
      }

      await DatabaseHelper.instance
          .updateLineItemsHandsOnQty(shouldUpdateHandsOnQtyList);

      if (res && _id != null) {
        Get.snackbar(
          'Success',
          'saved',
          backgroundColor: const Color.fromARGB(255, 50, 118, 52),
          colorText: Colors.white,
        );

        getDataToPrint();
      } else {
        Get.snackbar(
          'Error',
          'Not saved',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      Invoice invoice = Invoice(
          userId: userId,
          vatIncExc: settingType.vattype,
          totalQty: qty,
          items: allItems,
          grossTotal: double.tryParse(grossTotal.toStringAsFixed(2)),
          tax: double.tryParse(tax.toStringAsFixed(2)),
          netTotal: double.tryParse(netTotal.toStringAsFixed(2)),
          dateTime: formatter.format(now),
          chtAccAccNo: widget.customer.chtAccAccNo.toString(),
          payMode: 'N/A',
          isReturn: 'false');
      finalInvoiceToPrint = invoice;
      int? _id = await DatabaseHelper.instance.insertInvoice(invoice);

      if (_id != null) {
        finalRecieptList = await saveReciepts(_id);
      }
      finalRecieptListToPrint = finalRecieptList;
      bool red =
          await DatabaseHelper.instance.insertReciept(finalRecieptList, "N/A");
      List<LineItems> shouldUpdateHandsOnQtyList = [];
      for (var itm in allItems) {
        shouldUpdateHandsOnQtyList.add(itm.item!);
      }

      await DatabaseHelper.instance
          .updateLineItemsHandsOnQty(shouldUpdateHandsOnQtyList);
      if (red && _id != null) {
        Get.snackbar(
          'Success',
          'saved',
          backgroundColor: const Color.fromARGB(255, 50, 118, 52),
          colorText: Colors.white,
        );

        getDataToPrint();
      } else {
        Get.snackbar(
          'Error',
          'Not saved',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  saveReciepts(int id) async {
    List<Reciept> recieptList = [];
    DateTime now = DateTime.now();
    Invoice invoice = await DatabaseHelper.instance.getInvoiceById(id);
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    if (chequeList.isNotEmpty) {
      for (var chq in chequeList) {
        Reciept reciept = Reciept(
            invoiceId: invoice.invoiceId,
            balance: cashBalance + creditBalance + chequePaid - netTotal,
            dateTime: formatter.format(now),
            priceType: priceType,
            netTotal: netTotal,
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
            paid: double.tryParse(getPaidAmount()));

        recieptList.add(reciept);
      }
    }
    if (cashController.text != "" &&
        double.tryParse(cashController.text)! > 0.0) {
      Reciept reciept = Reciept(
          invoiceId: invoice.invoiceId,
          balance: cashBalance + creditBalance + chequePaid - netTotal,
          dateTime: formatter.format(now),
          priceType: priceType,
          netTotal: netTotal,
          userId: userId,
          payMode: 'Cash',
          chtAccAccNo: widget.customer.chtAccAccNo,
          cashAmount: double.tryParse(cashController.text),
          selectedAmount: double.tryParse(cashController.text),
          paid: double.tryParse(getPaidAmount()));
      recieptList.add(reciept);
    }
    // if (creditController.text != "" &&
    //     double.tryParse(creditController.text)! > 0.0) {
    //   Reciept reciept = Reciept(
    //       invoiceId: 'IN$userId-${id.toString().padLeft(5, '0')}',
    //       balance: balance,
    //       dateTime: formatter.format(now),
    //       priceType: priceType,
    //       netTotal: netTotal,
    //       userId: userId,
    //       payMode: 'Credit',
    //       chtAccAccNo: widget.customer.chtAccAccNo,
    //       selectedAmount: double.tryParse(creditController.text),
    //       creditAmount: double.tryParse(creditController.text),
    //       paid: double.tryParse(getPaidAmount()));
    //   recieptList.add(reciept);
    // }
    return recieptList;
  }

  getPaidAmount() {
    if (settingType.payModeBase == 'YES') {
      if (priceType == 'Cheque') {
        return (chequePaid +
                (double.tryParse(cashController.text.trim()) ?? 0.00))
            .toStringAsFixed(2);
      } else if (priceType == 'Credit') {
        return (chequePaid +
                (double.tryParse(cashController.text.trim()) ?? 0.00))
            .toStringAsFixed(2);
      } else {
        return double.tryParse(cashController.text.trim())
                ?.toStringAsFixed(2) ??
            '0.00';
      }
    } else {
      double paidTemp = 0.00;

      if (cashController.text != "" &&
          (double.tryParse(cashController.text)! > 0.00)) {
        paidTemp = paidTemp + double.tryParse(cashController.text)!;
      }
      if (creditController.text != "" &&
          (double.tryParse(creditController.text)! > 0.00)) {
        paidTemp = paidTemp + double.tryParse(creditController.text)!;
      }
      paidTemp = paidTemp + chequePaid;

      return paidTemp.toStringAsFixed(2);
    }
  }

  getDataToPrint() async {
    Invoice invoice = await DatabaseHelper.instance.getLastInvoice();
    List<Reciept> recieptList = await DatabaseHelper.instance
        .getRecieptsByInvoiceId(invoice.invoiceId!);
    widget.callBack(invoice, recieptList);
  }

  void _toggle() {
    setState(() {
      cashController.text = "";
      creditController.text = "";
      chequeList = [];
      _isToggled = !_isToggled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First Column
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Net Total',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        Text(
                          'LKR ${netTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Credit Balance',
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'LKR 0.00',
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Second Column
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Methods',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Text('Cash'),
                        const SizedBox(width: 35),
                        Expanded(
                          child: CustomTextField(
                            name: 'cash',
                            controller: cashController,
                            hint: "LKR 00.00",
                            readOnly: _isToggled, // Set readOnly here
                            onChange: (v) {
                              // Your onChange logic here
                            },
                            prefixIcon: Icons.monetization_on_outlined,
                            textInputType:
                                const TextInputType.numberWithOptions(),
                            obscureText: false,
                            textCapitalization: TextCapitalization.words,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (settingType.payModeBase == 'NO' ||
                        priceType == 'Credit')
                      Row(
                        children: [
                          const Text('Credit:'),
                          const SizedBox(width: 30),
                          Expanded(
                            child: IgnorePointer(
                              ignoring: settingType.payModeBase == 'YES',
                              child: CustomTextField(
                                controller: creditController,
                                name: "credit",
                                prefixIcon: Icons.monetization_on_outlined,
                                readOnly: _isToggled,
                                textInputType:
                                    const TextInputType.numberWithOptions(),
                                onChange: (v) {
                                  setState(() {
                                    creditBalance = (double.tryParse(
                                            creditController.text) ??
                                        0.00);
                                    // tempBalCreditController =
                                    //     double.tryParse(creditController.text) ??
                                    //         0.00;
                                    // balance = balance.abs() +
                                    //     (double.tryParse(creditController.text) ??
                                    //         0.00) -
                                    //     netTotal -
                                    //     tempBalCashController;
                                  });
                                },
                                obscureText: false,
                                textCapitalization: TextCapitalization.words,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),
                    if (settingType.payModeBase == 'NO' || priceType != 'Cash')
                      Row(
                        children: [
                          const Text('Cheque'),
                          IconButton(
                            onPressed: () {
                              if (_isToggled == false) {
                                openDialog();
                              }
                            },
                            icon: const Icon(
                              Icons.add_box_sharp,
                              color: Colors.orange,
                            ),
                          )
                        ],
                      ),
                    // const SizedBox(height: 10),
                    // // Text area
                    // TextFormField(
                    //   maxLines: null, // Allows multiple lines of text
                    //   decoration: InputDecoration(
                    //     hintText: 'Enter additional information...',
                    //     border: OutlineInputBorder(),
                    //   ),
                    // ),
                  ],
                ),
              ),
              (chequeList.isNotEmpty)
                  ? Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: chequeList.length,
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
                                      '${chequeList[index].bankNo ?? ''} - ${chequeList[index].branchNo ?? ''}',
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Cheque No  - ${chequeList[index].chequeNo ?? ''}'),
                                        Text(
                                            'Account No - ${chequeList[index].accountNo ?? ''}')
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              'LKR ${chequeList[index].chequeAmount?.toStringAsFixed(2) ?? ''}',
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              chequeList[index].date ?? '',
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 10),
                                        IconButton(
                                            onPressed: () {
                                              onClickDeleteCheque(index);
                                            },
                                            icon: const Icon(Icons.delete))
                                      ],
                                    )),
                              ),
                            );
                          }),
                    )
                  : const Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (checkerr == 'YES')
                          Row(
                            children: [
                              Switch(
                                value: _isToggled,
                                activeColor: Colors.yellow,
                                onChanged: (value) {
                                  _toggle();
                                },
                              ),
                              Text(_isToggled
                                  ? 'Without Reciept'
                                  : 'With Reciept'),
                            ],
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Net Total",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('LKR ${netTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Paid",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('LKR ${getPaidAmount()}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Balance",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                                'LKR ${(cashBalance + creditBalance + chequePaid - netTotal).toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 222, 171, 95),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(fontSize: 15.0, color: Colors.white),
                        ),
                        onPressed: () {
                          widget.callBackForBack();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 5),
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
                          onPressedSave();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  onClickOk() {
    if (_formKey.currentState!.validate() &&
        selectedBankCode != '' &&
        selectedBranchCode != '') {
      chequeList.add(Cheque(
          bankNo: selectedBankCode,
          chequeAmount: double.tryParse(chqAmountController.text.trim()),
          chequeNo: chqNoController.text.toString(),
          branchNo: selectedBranchCode,
          date: selectedDate,
          accountNo: chqAccNoController.text.toString(),
          userId: userId));

      setState(() {
        chequePaid = chequePaid +
            (double.tryParse(chqAmountController.text.trim()) ?? 0.00);
        balance = balance + (chequePaid - netTotal);
        if (priceType == 'Credit' && settingType.payModeBase == 'YES') {
          creditBalance = netTotal - (chequePaid + cashBalance);
        }

        chqAccNoController.text = "";
        chqAmountController.text = "";
        isVisibleBranchList = false;
        menuBankController.text = '';
        menuBranchController.text = '';
        selectedBank = null;
        selectedBankCode = '';
        selectedBranchCode = '';
        selectedDate = "";
        chqNoController.text = "";
        dateController.text = "";
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

  onClickDeleteCheque(int index) {
    setState(() {
      chequePaid = chequePaid - chequeList[index].chequeAmount!;
      balance = balance - chequeList[index].chequeAmount!;
      if (priceType == 'Credit' && settingType.payModeBase == 'YES') {
        creditBalance = netTotal - (chequePaid + cashBalance);
      }
      chequeList.removeAt(index);
    });
  }

  onCancel() {
    chqAccNoController.text = "";
    chqAmountController.text = "";
    selectedDate = "";
    chqNoController.text = "";
    dateController.text = "";
    isVisibleBranchList = false;
    menuBankController.text = '';
    menuBranchController.text = '';
    selectedBank = null;
    selectedBankCode = '';
    selectedBranchCode = '';
    isBankError = false;
    isBranchError = false;
  }

  amountValidator(String controller, errorItem) {
    if (controller.isEmpty || double.tryParse(controller)! == 0.00) {
      return '$errorItem required';
    }
  }

  Future openDialog() => showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) =>
            StatefulBuilder(builder: (context, setPopUpState) {
          return AlertDialog(
            title: const Text("Add Cheque Details"),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          setPopUpState(() {
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
                            setPopUpState(() {
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Cheque No';
                        } else if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                          return 'Cheque No must be exactly 6 digits';
                        }
                        return null; // Return null if validation passes
                      },
                      decoration: const InputDecoration(
                        labelText: "Cheque No",
                      ),
                      controller: chqNoController,
                      keyboardType: const TextInputType.numberWithOptions(),
                    ),
                    TextFormField(
                      validator: (v) {
                        return amountValidator(
                            chqAmountController.text, 'Amount');
                      },
                      decoration: const InputDecoration(
                        labelText: "Amount",
                      ),
                      controller: chqAmountController,
                      keyboardType: const TextInputType.numberWithOptions(),
                      onChanged: (v) {},
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
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () async {
                        DateFormat formatter =
                            DateFormat('yyyy-MM-dd HH:mm:ss');
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = formatter.format(pickedDate);
                            dateController.text = selectedDate;
                            date = pickedDate;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: "Select Date",
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: TextFormField(
                          validator: (v) {
                            return validator(dateController.text, 'Date');
                          },
                          controller: dateController,
                          enabled: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  onCancel();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.orange),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (selectedBankCode == '') {
                    setPopUpState(() {
                      isBankError = true;
                    });
                  }
                  if (selectedBranchCode == '') {
                    setPopUpState(() {
                      isBranchError = true;
                    });
                  }
                  onClickOk();
                },
                child: const Text(
                  "Ok",
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          );
        }),
      );
}
