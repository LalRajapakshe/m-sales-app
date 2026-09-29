import 'dart:async';
import 'dart:convert';
import 'package:m_sales/helper/local_db.dart';
import 'package:m_sales/models/bank.dart';
import 'package:m_sales/models/closedTrip.dart';
import 'package:m_sales/models/customer.dart';
import 'package:m_sales/models/doc_details.dart';
import 'package:m_sales/models/gin_response.dart';
import 'package:m_sales/models/invoice.dart';
import 'package:m_sales/models/item.dart';
import 'package:m_sales/models/price.dart';
import 'package:m_sales/models/reciept.dart';
import 'package:m_sales/models/setting_types.dart';
import 'package:m_sales/models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  // Define the table and column names
  final String userTable = 'user';
  final String colId = 'id';
  final String colUsername = 'username';
  final String colPassword = 'password';
  final String colUserId = 'userId';

  //Define Customer table and Column
  final String customerTable = 'customer';
  final String colChtAccAccNo = 'chtAccAccNo';
  final String colChtAccName = 'chtAccName';
  final String colChtAccType = 'chtAccType';
  final String colChtAccGroupCode = 'chtAccGroupCode';
  final String colChtAccCreditLimit = 'chtAccCreditLimit';
  final String colChtAccCreditPeriod = 'chtAccCreditPeriod';
  final String colChtAccRepRefCode = 'chtAccRepRefCode';
  final String colChtAccPriceTblCode = 'chtAccPriceTblCode';
  final String colChtAccAreaCode = 'chtAccAreaCode';
  final String colChtAccAlias = 'chtAccAlias';
  final String colChtAccRegNo = 'chtAccRegNo';
  final String colChtAccAddress = 'chtAccAddress';
  final String colInfoCustomerCategory = 'infoCustomerCategory';
  final String colChtCustStateCode = 'chtCustStateCode';
  final String colChtAccWithCustVat = 'chtAccWithCustVat';
  final String colEmiNo = 'emiNo';

  //Define Items table and columns
  final String itemTable = 'item';
  final String colItMstCode = 'itMstCode';
  final String colItMstGrpCode = 'itMstGrpCode';
  final String colItMstDescription = 'itMstDescription';
  final String colItMstAlias = 'itMstAlias';
  final String colItMstDefaultMesUnt = 'itMstDefaultMesUnt';
  final String colItMstDeactivate = 'itMstDeactivate';
  final String colItMstBinNo = 'itMstBinNo';
  final String colItMstBarCode = 'itMstBarCode';
  final String colItMstDefaultPrice = 'itMstDefaultPrice';
  final String colItMstWeiPktConvertionRatio = 'itMstWeiPktConvertionRatio';
  final String colItMasLowestPrice = 'itMasLowestPrice';

//Define price table and columns
  final String priceTable = 'price';
  final String colPrTbPriceTableCode = 'prTbPriceTableCode';
  final String colPrTbItemCode = 'prTbItemCode';
  final String colPrice = 'price';
  final String colPrTbBatchCOde = 'prTbBatchCOde';
  final String colPriceType = 'priceType';

//Define Gin table
  final String ginTable = 'gin';
  final String colGinStuHdrId = 'ginStuHdrId';
  final String colGinNo = 'ginNo';
  final String colGinStuHdrGinNo = 'ginStuHdrGinNo';
  final String colGinStuHdrDocType = 'ginStuHdrDocType';
  final String colGinStuHdrFrLocCode = 'ginStuHdrFrLocCode';
  final String colGinStuHdrToLocCode = 'ginStuHdrToLocCode';
  final String colGinStuHdrDate = 'ginStuHdrDate';
  final String colGinStuHdrRefCode = 'ginStuHdrRefCode';
  final String colGinStuHdrFgnRefCode = 'ginStuHdrFgnRefCode';
  final String colGinStuHdrStatus = 'ginStuHdrStatus';

  //Define LineItemTable
  final String lineItemsTable = 'lineItems';
  final String colGinStuGinCode = 'ginStuGinCode';
  final String colGinBatchNo = 'ginBatchNo';
  final String colGinStuItemCode = 'ginStuItemCode';
  final String colGinStuAlise = 'ginStuAlise';
  final String colGinStuName = 'ginStuName';
  final String colGinStuUnitName = 'ginStuUnitName';
  final String colGinStuQuantity = 'ginStuQuantity';
  final String colGinStuQuantityPkts = 'ginStuQuantityPkts';
  final String colitMstDefualtPrice = 'itMstDefualtPrice';
  final String colHandOnItemQty = 'handsOnQty';
  final String colIsFresh = 'isFresh';
  final String colIsExpired = 'isExpired';
  final String colIsDamaged = 'isDamaged';

  //Define invoiceTable
  final String invoiceTable = 'invoice';
  final String colVatIncExc = 'vatIncExc';
  final String colTotalQty = 'totalQty';
  final String colGrossTotal = 'grossTotal';
  final String colTax = 'tax';
  final String colNetTotal = 'netTotal';
  final String colDateTime = 'dateTime';
  final String colIsReturn = 'isReturn';

  //Define invoicedItemTable
  final String invoicedItemTable = 'invoicedItems';
  final String colitem = 'item';
  final String colQty = 'selectedQuantity';
  final String colInvoiceId = 'invoiceId';

  //Define recieptTable
  final String recieptTable = 'reciept';
  final String colPaid = 'paid';
  final String colBalance = 'balance';
  final String colPayMode = 'payMode';
  final String colCreditAmount = 'creditAmount';
  final String colCashAmount = 'cashAmount';
  final String colSelectedAmount = 'selectedAmount';

  //Define SettingTypesTable
  final String settingTypesTable = 'settingTypes';
  final String colVatAmount = 'vatAmount';
  final String colVatType = 'vattype';
  final String colBatchBase = 'batchBase';
  final String colPayModeBase = 'payModeBase';

  final String colTenent = 'tenent';
  final String colUnitRate = 'unitRate';
  final String colBaseUrl = 'baseUrl';
  final String colInvoiceCheck = 'invoiceCheck';
  final String colCompanyVatNo = 'companyVatNo';

  final String companyName = 'companyName';
  final String address = 'address';
  final String tel = 'tel';
  final String hotline = 'hotline';

  final String email = 'email';
  final String web = 'web';
  final String invttl1 = 'invttl1';
  final String invttl2 = 'invttl2';

  //Define chequeDetailsTable
  final String chequeTable = 'cheques';
  final String colBank = 'bank';
  final String colChequeNo = 'chequeNo';
  final String colChequeAmount = 'chequeAmount';
  final String colAccNo = 'accountNo';
  final String colDate = 'date';
  final String colRecieptId = 'recieptId';
  final String colChequeDate = 'chequeDate';
  final String colBankCode = 'bankCode';
  final String colBranchCode = 'branchCode';

  //Define BankTable
  final String banksTable = 'banks';
  final String colBankNo = 'bankNo';
  final String colBranchNo = 'branchNo';
  final String colBranchName = 'branchName';

  //Define DOcTable
  final String doctable = 'docs';
  final String colRepCode = 'repCode';
  final String colInvCode = 'invCode';
  final String colRepShortCode = 'repShortCode';
  final String colReturnCode = 'returnCode';
  final String colInvLastNo = 'invLastNo';
  final String colRepName = 'repName';
  final String colReturnLastNo = 'returnLastNo';
  final String colDocNoLength = 'docNoLength';
  final String colCashReceCode = 'cashReceCode';
  final String colBankReceCode = 'bankReceCode';
  final String colCashReceLastNo = 'cashReceLastNo';
  final String colBankReceLastNo = 'bankReceLastNo';

  //Define closedTripsTable
  final String closedTripsTable = 'closedTrips';

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Get the database path
    String path = join(await getDatabasesPath(), 'm_sales_1.6.2.db');

    // Open the database and create the table if it doesn't exist
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create the user table
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $userTable(
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colUsername TEXT NOT NULL,
        $colPassword TEXT NOT NULL,
        $colUserId TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $customerTable(
    $colId INTEGER PRIMARY KEY AUTOINCREMENT,
    $colChtAccAccNo INTEGER,
    $colUserId TEXT,
    $colChtAccName TEXT,
    $colChtAccType INTEGER,
    $colChtAccGroupCode INTEGER,
    $colChtAccCreditLimit INTEGER,
    $colChtAccCreditPeriod INTEGER,
    $colChtAccRepRefCode INTEGER,
    $colChtAccPriceTblCode INTEGER,
    $colChtAccAreaCode INTEGER,
    $colChtAccAlias TEXT,
    $colChtAccRegNo INTEGER,
    $colChtAccAddress TEXT,
    $colInfoCustomerCategory INTEGER,
    $colChtCustStateCode INTEGER,
    $colChtAccWithCustVat TEXT,
    $colEmiNo TEXT
           )
    ''');

    await db.execute('''
      CREATE TABLE $itemTable(
    $colId INTEGER PRIMARY KEY AUTOINCREMENT,
    $colItMstCode INTEGER,
    $colUserId TEXT,
    $colItMstGrpCode INTEGER,
    $colItMstDescription TEXT,
    $colItMstAlias TEXT,
    $colItMstDefaultMesUnt INTEGER,
    $colItMstDeactivate TEXT,
    $colItMstBinNo TEXT,
    $colItMstBarCode TEXT,
    $colItMstDefaultPrice DOUBLE,
    $colItMstWeiPktConvertionRatio DOUBLE,
    $colItMasLowestPrice DOUBLE
            )
    ''');

    await db.execute('''
      CREATE TABLE $priceTable(
    $colId INTEGER PRIMARY KEY AUTOINCREMENT,
    $colPrTbPriceTableCode INTEGER,
    $colUserId TEXT,
    $colPrTbItemCode INTEGER,
    $colPrice DOUBLE,
    $colPrTbBatchCOde TEXT,
    $colPriceType TEXT
         )
    ''');
    await db.execute('''
      CREATE TABLE $ginTable (
       $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colGinStuHdrId INTEGER,
        $colGinNo INTEGER,
        $colGinStuHdrGinNo TEXT,
        $colGinStuHdrDocType TEXT,
        $colGinStuHdrFrLocCode INTEGER,
        $colGinStuHdrToLocCode INTEGER,
        $colGinStuHdrDate TEXT,
        $colGinStuHdrRefCode TEXT,
        $colGinStuHdrFgnRefCode TEXT,
        $colGinStuHdrStatus TEXT,
        $colUserId TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE $lineItemsTable (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colGinNo TEXT,
        $colGinStuGinCode TEXT,
        $colGinBatchNo TEXT,
        $colGinStuItemCode INTEGER,
        $colGinStuAlise TEXT,
        $colGinStuName TEXT,
        $colGinStuUnitName TEXT,
        $colGinStuQuantity DOUBLE,
        $colGinStuQuantityPkts DOUBLE,
        $colitMstDefualtPrice DOUBLE, 
        $colGinStuHdrFgnRefCode TEXT,
        $colUserId TEXT,
        $colHandOnItemQty DOUBLE,
        $colIsFresh TEXT,
        $colIsExpired TEXT,
        $colIsDamaged TEXT
            )
    ''');

    await db.execute('''
      CREATE TABLE $invoiceTable (
        $colId INTEGER PRIMARY KEY,
        $colVatIncExc TEXT,
        $colTotalQty DOUBLE,
        $colGrossTotal DOUBLE,
        $colTax DOUBLE,
        $colNetTotal DOUBLE,
        $colUserId TEXT,
        $colChtAccAccNo TEXT,
        $colDateTime TEXT,
        $colInvoiceId TEXT,
        $colPayMode TEXT,
        $colIsReturn TEXT
            )
    ''');

    await db.execute('''
      CREATE TABLE $invoicedItemTable (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colInvoiceId TEXT,
        $colitem TEXT,
        $colQty DOUBLE
            )
    ''');

    await db.execute('''
      CREATE TABLE $recieptTable (
        $colId INTEGER,
        $colInvoiceId INTEGER,
        $colPaid DOUBLE,
        $colBalance INTEGER,
        $colDateTime TEXT,
        $colPriceType TEXT,
        $colNetTotal DOUBLE,
        $colRecieptId TEXT,
        $colPayMode TEXT,
        $colUserId TEXT,
        $colChtAccAccNo INTEGER,
        $colChequeDate TEXT,
        $colChequeAmount DOUBLE,
        $colBankCode TEXT,
        $colChequeNo TEXT,
        $colAccNo TEXT,
        $colBranchCode TEXT,
        $colCashAmount DOUBLE,
        $colCreditAmount DOUBLE,
        $colSelectedAmount DOUBLE
            )
    ''');

    await db.execute('''
      CREATE TABLE $settingTypesTable (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colVatAmount DOUBLE,
        $colVatType TEXT,
        $colBatchBase TEXT,
        $colPayModeBase TEXT,
        $colUserId TEXT,
        $colTenent TEXT,
        $companyName TEXT,
        $address TEXT,
        $tel TEXT,
        $hotline TEXT,
        $email TEXT,
        $web TEXT,
        $invttl1 TEXT,
        $invttl2 TEXT,
        $colUnitRate TEXT,
        $colBaseUrl TEXT,
        $colInvoiceCheck TEXT,
        $colCompanyVatNo TEXT
            )
    ''');

    await db.execute('''
      CREATE TABLE $doctable (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colRepCode INTEGER,
        $colInvCode TEXT,
        $colRepName TEXT,
        $colRepShortCode TEXT,
        $colCashReceCode TEXT,
        $colBankReceCode TEXT,
        $colReturnCode TEXT,
        $colInvLastNo INTEGER,
        $colCashReceLastNo INTEGER,
        $colBankReceLastNo INTEGER,
        $colReturnLastNo INTEGER,
        $colDocNoLength INTEGER,
        $colUserId INTEGER
            )
    ''');
    // await db.execute('''
    //   CREATE TABLE $chequeTable (
    //     $colId INTEGER PRIMARY KEY AUTOINCREMENT,
    //     $colChequeAmount DOUBLE,
    //     $colBankNo TEXT,
    //     $colChequeNo TEXT,
    //     $colAccNo TEXT,
    //     $colBranchNo TEXT,
    //     $colDate TEXT,
    //     $colUserId TEXT,
    //     $colRecieptId TEXT
    //         )
    // ''');

    await db.execute('''
      CREATE TABLE $banksTable (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colBankNo TEXT,
        $colBranchNo TEXT,
        $colBranchName TEXT,
        $colUserId TEXT
            )
    ''');
    await db.execute('''
      CREATE TABLE $closedTripsTable (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colGinStuHdrFgnRefCode TEXT,
        $colUserId TEXT
            )
    ''');
  }

  // Insert a user into the database
  Future<int> insertUser(User user) async {
    Database db = await database;
    return await db.insert(userTable, user.toMap());
  }

  Future<User?> getUserByUsernameAndPassword(
      String username, String password) async {
    final db = await database;
    final maps = await db.query(
      userTable,
      where: '$colUsername = ? AND $colPassword = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<bool> verifyPassword(String username, String password) async {
    final db = await database;
    final maps = await db.query(
      userTable,
      where: '$colUsername = ? AND $colPassword = ?',
      whereArgs: [username, password],
    );

    return maps.isNotEmpty;
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final maps = await db.query(
      userTable,
      where: '$colUsername = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<void> insertCustomers(List<Customer> customers) async {
    final db = await database;
    final batch = db.batch();
    String userId = await Settings.getUserID() ?? '';
    await db.delete(
      customerTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    for (Customer customer in customers) {
      batch.insert(customerTable, customer.toJson());
    }
    await batch.commit(noResult: true);
  }

  Future<List<Customer>> getCustomersByUserId(String userId) async {
    final db = await database;
    final data = await db.query(
      customerTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    List<Customer> result = data.map((e) => Customer.fromJson(e)).toList();
    return result;
  }

  Future<Customer> getCustomersByCustomerId(String customerId) async {
    String? userId = await Settings.getUserID();
    final db = await database;
    final data = await db.query(
      customerTable,
      where: 'userId = ? AND chtAccAccNo = ?',
      whereArgs: [userId, customerId],
    );
    Customer result = Customer.fromJson(data.first);
    return result;
  }

  Future<void> insertItems(List<ItemTableItem> items) async {
    final db = await database;
    final batch = db.batch();
    String userId = await Settings.getUserID() ?? '';
    await db.delete(
      itemTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    for (ItemTableItem item in items) {
      batch.insert(itemTable, item.toJson());
    }
    await batch.commit(noResult: true);
  }

  Future<List<ItemTableItem>> getItemsByUserId(String userId) async {
    final db = await database;
    final data = await db.query(
      itemTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    List<ItemTableItem> result =
        data.map((e) => ItemTableItem.fromJson(e)).toList();
    return result;
  }

  Future<void> insertPrices(List<Price> prices) async {
    final db = await database;
    final batch = db.batch();
    String userId = await Settings.getUserID() ?? '';
    await db.delete(
      priceTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    for (Price price in prices) {
      batch.insert(priceTable, price.toJson());
    }
    await batch.commit(noResult: true);
  }

  Future<List<Price>> getPricesByUserId(String userId) async {
    final db = await database;
    final data = await db.query(
      priceTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    List<Price> result = data.map((e) => Price.fromJson(e)).toList();
    return result;
  }

  // Future<void> insertLineItems(
  //     List<LineItems>? lineItems, String ginStuHdrId) async {
  //   final db = await database;
  //   final batch = db.batch();
  //   String userId = await Settings.getUserID() ?? '';
  //   await db.delete(
  //     lineItemsTable,
  //     where: 'userId = ?',
  //     whereArgs: [userId],
  //   );
  //   if (lineItems != []) {
  //     for (LineItems lineItem in lineItems!) {
  //       lineItem.ginStuHdrId = int.tryParse(ginStuHdrId);
  //       batch.insert(lineItemsTable, lineItem.toJson());
  //     }
  //   }
  //   await batch.commit(noResult: true);
  // }

  Future<void> insertGinResponse(
    List<GinResponse> ginResponse, {
    bool replaceExisting = true,
  }) async {
    Database db = await database;
    String userId = await Settings.getUserID() ?? '';

    if (replaceExisting) {
      await db.delete(
        ginTable,
        where: 'userId = ?',
        whereArgs: [userId],
      );
      await db.delete(
        lineItemsTable,
        where: 'userId = ?',
        whereArgs: [userId],
      );
    }

    for (var ginItem in ginResponse) {
      if (!replaceExisting) {
        List<Map<String, dynamic>> existing = [];
        if (ginItem.ginStuHdrGinNo != null &&
            ginItem.ginStuHdrGinNo!.isNotEmpty) {
          existing = await db.query(
            ginTable,
            where: 'userId = ? AND $colGinStuHdrGinNo = ?',
            whereArgs: [userId, ginItem.ginStuHdrGinNo],
          );
        } else if (ginItem.ginStuHdrId != null) {
          existing = await db.query(
            ginTable,
            where: 'userId = ? AND $colGinStuHdrId = ?',
            whereArgs: [userId, ginItem.ginStuHdrId],
          );
        }
        if (existing.isNotEmpty) {
          continue;
        }
      }

      GinResponseLocal local = GinResponseLocal(
          ginNo: ginItem.ginNo,
          ginStuHdrId: ginItem.ginStuHdrId,
          ginStuHdrDate: ginItem.ginStuHdrDate,
          ginStuHdrDocType: ginItem.ginStuHdrDocType,
          ginStuHdrFgnRefCode: ginItem.ginStuHdrFgnRefCode,
          ginStuHdrFrLocCode: ginItem.ginStuHdrFrLocCode,
          ginStuHdrGinNo: ginItem.ginStuHdrGinNo,
          ginStuHdrRefCode: ginItem.ginStuHdrRefCode,
          ginStuHdrStatus: ginItem.ginStuHdrStatus,
          ginStuHdrToLocCode: ginItem.ginStuHdrToLocCode,
          userId: ginItem.userId);
      await db.insert(ginTable, local.toJson());
      final List<LineItems> lineItems = ginItem.lineItems ?? [];
      for (LineItems lineItem in lineItems) {
        lineItem.handsOnQty = lineItem.ginStuQuantity;
        lineItem.isFresh = '';
        lineItem.isExpired = '';
        lineItem.isDamaged = '';
        print(lineItem.toJson());
        await db.insert(lineItemsTable, lineItem.toJson());
      }
    }
  }

  Future<List<GinResponse>> getAllGinResponsesByUserId(String userId) async {
    final db = await database;
    final data = await db.query(
      ginTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    List<GinResponse> result =
        data.map((e) => GinResponse.fromJson(e)).toList();
    return result;
  }

  Future<GinResponse> getGinResponses(
      String userId, String ginStuHdrFgnRefCode) async {
    final db = await database;
    final data = await db.query(
      ginTable,
      where: 'userId = ? AND ginStuHdrFgnRefCode =?',
      whereArgs: [userId, ginStuHdrFgnRefCode],
    );

    GinResponseLocal _ginResponseLocal = GinResponseLocal.fromJson(data.first);

    final lineData = await db.query(
      lineItemsTable,
      where: 'userId = ? AND ginStuHdrFgnRefCode =?',
      whereArgs: [userId, ginStuHdrFgnRefCode],
    );
    List<LineItems> _lineItems =
        lineData.map((v) => LineItems.fromJson(v)).toList();

    GinResponse ginResponse = GinResponse(
        ginNo: _ginResponseLocal.ginNo,
        ginStuHdrId: _ginResponseLocal.ginStuHdrId,
        ginStuHdrDate: _ginResponseLocal.ginStuHdrDate,
        ginStuHdrDocType: _ginResponseLocal.ginStuHdrDocType,
        ginStuHdrFgnRefCode: _ginResponseLocal.ginStuHdrFgnRefCode,
        ginStuHdrFrLocCode: _ginResponseLocal.ginStuHdrFrLocCode,
        ginStuHdrGinNo: _ginResponseLocal.ginStuHdrGinNo,
        ginStuHdrRefCode: _ginResponseLocal.ginStuHdrRefCode,
        ginStuHdrStatus: _ginResponseLocal.ginStuHdrStatus,
        ginStuHdrToLocCode: _ginResponseLocal.ginStuHdrToLocCode,
        lineItems: _lineItems,
        userId: _ginResponseLocal.userId);
    return ginResponse;
  }

  Future<List<LineItems>> getLineItemsByUserIdAndRefCode(
      String userId, String refCode) async {
    final db = await database;
    final data = await db.query(
      lineItemsTable,
      where: 'userId = ? AND ginStuHdrFgnRefCode = ?',
      whereArgs: [userId, refCode],
    );
    List<LineItems> result = data.map((e) => LineItems.fromJson(e)).toList();
    return result;
  }

  Future<void> updateLineItemsPrice(List<LineItems> itemList) async {
    final db = await database;

    for (var item in itemList) {
      await db.update(
        lineItemsTable,
        item.toJson(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
    }
  }

  Future<void> updateLineItemsHandsOnQty(List<LineItems> itemList) async {
    final db = await database;
    String? ref = await Settings.getGinStuHdrFgnRefCode();
    for (var itm in itemList) {
      itm.ginStuHdrFgnRefCode = ref ?? '';
    }

    for (var item in itemList) {
      await db.update(
        lineItemsTable,
        item.toJson(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
    }
  }

  Future<int?> insertInvoice(Invoice invoice) async {
    String? userId = await Settings.getUserID();
    Database db = await database;
    DocDetails _docDetails = await getDocDetails();
    InvoiceDB invoiceDb = InvoiceDB(
        //id: _docDetails.invLastNo! + 1,
        vatIncExc: invoice.vatIncExc,
        totalQty: invoice.totalQty,
        grossTotal: invoice.grossTotal,
        netTotal: invoice.netTotal,
        tax: invoice.tax,
        userId: invoice.userId,
        chtAccAccNo: invoice.chtAccAccNo,
        dateTime: invoice.dateTime,
        payMode: invoice.payMode,
        isReturn: invoice.isReturn,
        invoiceId: invoice.isReturn == 'true'
            ? '${_docDetails.returnCode ?? 'RTN'}-${(_docDetails.returnLastNo! + 1).toString().padLeft(5, '0')}'
            : '${_docDetails.invCode ?? 'INV'}-${(_docDetails.invLastNo! + 1).toString().padLeft(5, '0')}');
    int id = await db.insert(invoiceTable, invoiceDb.toJson());
    // await db.update(
    //   invoiceTable,
    //   InvoiceDB(
    //           id: _docDetails.invLastNo! + 1,
    //           vatIncExc: invoiceDb.vatIncExc,
    //           totalQty: invoiceDb.totalQty,
    //           grossTotal: invoiceDb.grossTotal,
    //           netTotal: invoiceDb.netTotal,
    //           tax: invoiceDb.tax,
    //           userId: invoiceDb.userId,
    //           chtAccAccNo: invoiceDb.chtAccAccNo,
    //           dateTime: invoiceDb.dateTime,
    //           payMode: invoiceDb.payMode,
    //           invoiceId:
    //               'IN${invoiceDb.userId}-${(_docDetails.invLastNo! + 1).toString().padLeft(5, '0')}')
    //       .toJson(),
    //   where: 'id = ?',
    //   whereArgs: [id],
    // );
    print('id---$id');
    final bool isReturn = invoice.isReturn == 'true';
    await updateDocDetails(DocDetails(
      repCode: _docDetails.repCode,
      invCode: _docDetails.invCode,
      repName: _docDetails.repName,
      cashReceCode: _docDetails.cashReceCode,
      cashReceLastNo: _docDetails.cashReceLastNo,
      bankReceCode: _docDetails.bankReceCode,
      bankReceLastNo: _docDetails.bankReceLastNo,
      repShortCode: _docDetails.repShortCode,
      returnCode: _docDetails.returnCode,
      invLastNo: isReturn
          ? _docDetails.invLastNo
          : (_docDetails.invLastNo ?? 0) + 1,
      returnLastNo: isReturn
          ? (_docDetails.returnLastNo ?? 0) + 1
          : _docDetails.returnLastNo,
      docNoLength: _docDetails.docNoLength,
    ));
    final DateTime? invoiceSavedAt = DateTime.tryParse(invoice.dateTime ?? '');
    final String? docTime = invoiceSavedAt == null
        ? null
        : DateFormat('HH:mm:ss').format(invoiceSavedAt);
    for (var item in invoice.items!) {
      // docTime lives only in the invoicedItems JSON; LineItems.toJson() is
      // also written to lineItemsTable, which has no docTime column.
      final Map<String, dynamic> itemJson = item.item!.toJson();
      itemJson['docTime'] = docTime;
      LineItemsSelectedDb lineItemsSelectedDb = LineItemsSelectedDb(
          item: jsonEncode(itemJson),
          selectedQuantity: item.selectedQuantity,
          invoiceId: invoice.isReturn == 'true'
              ? '${_docDetails.returnCode ?? 'RTN'}-${(_docDetails.returnLastNo! + 1).toString().padLeft(5, '0')}'
              : '${_docDetails.invCode ?? 'INV'}-${(_docDetails.invLastNo! + 1).toString().padLeft(5, '0')}');
      await db.insert(invoicedItemTable, lineItemsSelectedDb.toJson());
    }

    return id;
  }

  Future<Invoice> getLastInvoice() async {
    String? userId = await Settings.getUserID();
    final db = await database;
    final data = await db.query(
      invoiceTable,
      where: 'userId = ? ',
      whereArgs: [userId],
    );
    InvoiceDB invoice = InvoiceDB.fromJson(data.last);
    final dataList = await db.query(
      invoicedItemTable,
      where: 'invoiceId = ?',
      whereArgs: [invoice.invoiceId.toString()],
    );

    List<LineItemsSelectedDb> result =
        dataList.map((e) => LineItemsSelectedDb.fromJson(e)).toList();
    List<LineItemsSelected> finalList = [];
    for (var element in result) {
      finalList.add(LineItemsSelected(
        id: element.id,
        invoiceId: element.invoiceId,
        item: LineItems.fromJson(jsonDecode(element.item!)),
        selectedQuantity: element.selectedQuantity,
      ));
    }
    Invoice _invoice = Invoice(
        invoiceId: invoice.invoiceId,
        id: invoice.id,
        vatIncExc: invoice.vatIncExc,
        tax: invoice.tax,
        netTotal: invoice.netTotal,
        grossTotal: invoice.grossTotal,
        items: finalList,
        chtAccAccNo: invoice.chtAccAccNo,
        dateTime: invoice.dateTime,
        totalQty: invoice.totalQty,
        payMode: invoice.payMode,
        isReturn: invoice.isReturn,
        userId: invoice.userId);
    return _invoice;
  }

  Future<Invoice> getInvoiceByInvId(String invId) async {
    String? userId = await Settings.getUserID();
    final db = await database;
    final data = await db.query(
      invoiceTable,
      where: 'userId = ? AND invoiceId = ? ',
      whereArgs: [userId, invId],
    );
    InvoiceDB invoice = InvoiceDB.fromJson(data.first);
    final dataList = await db.query(
      invoicedItemTable,
      where: 'invoiceId = ?',
      whereArgs: [invoice.invoiceId.toString()],
    );

    List<LineItemsSelectedDb> result =
        dataList.map((e) => LineItemsSelectedDb.fromJson(e)).toList();
    List<LineItemsSelected> finalList = [];
    for (var element in result) {
      finalList.add(LineItemsSelected(
        id: element.id,
        invoiceId: element.invoiceId,
        item: LineItems.fromJson(jsonDecode(element.item!)),
        selectedQuantity: element.selectedQuantity,
      ));
    }
    Invoice _invoice = Invoice(
        invoiceId: invoice.invoiceId,
        id: invoice.id,
        vatIncExc: invoice.vatIncExc,
        tax: invoice.tax,
        netTotal: invoice.netTotal,
        grossTotal: invoice.grossTotal,
        items: finalList,
        chtAccAccNo: invoice.chtAccAccNo,
        dateTime: invoice.dateTime,
        totalQty: invoice.totalQty,
        payMode: invoice.payMode,
        isReturn: invoice.isReturn,
        userId: invoice.userId);
    return _invoice;
  }

  Future<Invoice> getInvoiceById(int id) async {
    String? userId = await Settings.getUserID();
    final db = await database;
    final data = await db.query(
      invoiceTable,
      where: 'userId = ? AND id = ? ',
      whereArgs: [userId, id],
    );
    InvoiceDB invoice = InvoiceDB.fromJson(data.first);
    final dataList = await db.query(
      invoicedItemTable,
      where: 'invoiceId = ?',
      whereArgs: [invoice.invoiceId.toString()],
    );

    List<LineItemsSelectedDb> result =
        dataList.map((e) => LineItemsSelectedDb.fromJson(e)).toList();
    List<LineItemsSelected> finalList = [];
    for (var element in result) {
      finalList.add(LineItemsSelected(
        id: element.id,
        invoiceId: element.invoiceId,
        item: LineItems.fromJson(jsonDecode(element.item!)),
        selectedQuantity: element.selectedQuantity,
      ));
    }
    Invoice _invoice = Invoice(
        invoiceId: invoice.invoiceId,
        id: invoice.id,
        vatIncExc: invoice.vatIncExc,
        tax: invoice.tax,
        netTotal: invoice.netTotal,
        grossTotal: invoice.grossTotal,
        items: finalList,
        chtAccAccNo: invoice.chtAccAccNo,
        dateTime: invoice.dateTime,
        totalQty: invoice.totalQty,
        payMode: invoice.payMode,
        isReturn: invoice.isReturn,
        userId: invoice.userId);
    return _invoice;
  }

  Future<List<Invoice>> getAllInvoicesByCustomer(
      String userId, String chtAccAccNo) async {
    final db = await database;
    final data = await db.query(
      invoiceTable,
      where: 'userId = ? AND chtAccAccNo =?',
      whereArgs: [userId, chtAccAccNo],
    );

    List<InvoiceDB> invoiceList =
        data.map((e) => InvoiceDB.fromJson(e)).toList();
    List<Invoice> finalInvoiceList = [];
    for (var invoice in invoiceList) {
      final dataList = await db.query(
        invoicedItemTable,
        where: 'invoiceId = ?',
        whereArgs: [invoice.invoiceId.toString()],
      );
      List<LineItemsSelectedDb> result =
          dataList.map((e) => LineItemsSelectedDb.fromJson(e)).toList();
      List<LineItemsSelected> finalList = [];
      for (var element in result) {
        final Map<String, dynamic> itemJson = jsonDecode(element.item!);
        finalList.add(LineItemsSelected(
          id: element.id,
          invoiceId: element.invoiceId,
          item: LineItems.fromJson(itemJson),
          selectedQuantity: element.selectedQuantity,
          docTime: itemJson['docTime'],
        ));
      }
      Invoice _invoice = Invoice(
          invoiceId: invoice.invoiceId,
          id: invoice.id,
          vatIncExc: invoice.vatIncExc,
          tax: invoice.tax,
          netTotal: invoice.netTotal,
          grossTotal: invoice.grossTotal,
          items: finalList,
          chtAccAccNo: invoice.chtAccAccNo,
          dateTime: invoice.dateTime,
          totalQty: invoice.totalQty,
          payMode: invoice.payMode,
          isReturn: invoice.isReturn,
          userId: invoice.userId);
      finalInvoiceList.add(_invoice);
    }

    return finalInvoiceList;
  }

  Future<List<Invoice>> getAllInvoices(String userId) async {
    final db = await database;
    final data = await db.query(
      invoiceTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    List<InvoiceDB> invoiceList =
        data.map((e) => InvoiceDB.fromJson(e)).toList();
    List<Invoice> finalInvoiceList = [];
    for (var invoice in invoiceList) {
      final dataList = await db.query(
        invoicedItemTable,
        where: 'invoiceId = ?',
        whereArgs: [invoice.invoiceId.toString()],
      );
      List<LineItemsSelectedDb> result =
          dataList.map((e) => LineItemsSelectedDb.fromJson(e)).toList();
      List<LineItemsSelected> finalList = [];
      for (var element in result) {
        final Map<String, dynamic> itemJson = jsonDecode(element.item!);
        finalList.add(LineItemsSelected(
          id: element.id,
          invoiceId: element.invoiceId,
          item: LineItems.fromJson(itemJson),
          selectedQuantity: element.selectedQuantity,
          docTime: itemJson['docTime'],
        ));
      }
      Invoice _invoice = Invoice(
          invoiceId: invoice.invoiceId,
          id: invoice.id,
          vatIncExc: invoice.vatIncExc,
          tax: invoice.tax,
          netTotal: invoice.netTotal,
          grossTotal: invoice.grossTotal,
          items: finalList,
          chtAccAccNo: invoice.chtAccAccNo,
          dateTime: invoice.dateTime,
          payMode: invoice.payMode,
          totalQty: invoice.totalQty,
          isReturn: invoice.isReturn,
          userId: invoice.userId);
      finalInvoiceList.add(_invoice);
    }

    return finalInvoiceList;
  }

  Future<bool> insertReciept(
      List<Reciept> recieptList, String priceType) async {
    String? userId = await Settings.getUserID();
    Database db = await database;

    List<int> successCollection = [];
    for (var reciept in recieptList) {
      DocDetails _docDetails = await getDocDetails();
      final bool isCheque = priceType == 'Cheque';
      final int nextCashReceLastNo = (_docDetails.cashReceLastNo ?? 0) + 1;
      final int nextBankReceLastNo = (_docDetails.bankReceLastNo ?? 0) + 1;
      //  int id = await db.insert(recieptTable, reciept.toJson());
      await db.insert(
        recieptTable,
        Reciept(
                //   id: _docDetails.receLastNo! + 1,
                balance: reciept.balance,
                paid: reciept.paid,
                userId: reciept.userId,
                priceType: reciept.priceType,
                dateTime: reciept.dateTime,
                netTotal: reciept.netTotal,
                recieptId: isCheque
                    ? '${_docDetails.bankReceCode} -${nextBankReceLastNo.toString().padLeft(5, '0')}'
                    : '${_docDetails.cashReceCode} -${nextCashReceLastNo.toString().padLeft(5, '0')}',
                invoiceId: reciept.invoiceId,
                chtAccAccNo: reciept.chtAccAccNo,
                chequeAmount: reciept.chequeAmount,
                chequeDate: reciept.chequeDate,
                chequeNo: reciept.chequeNo,
                bankCode: reciept.bankCode,
                branchCode: reciept.branchCode,
                accountNo: reciept.accountNo,
                cashAmount: reciept.cashAmount,
                creditAmount: reciept.creditAmount,
                selectedAmount: reciept.selectedAmount,
                payMode: reciept.payMode)
            .toJson(),
      );
      await updateDocDetails(DocDetails(
        repCode: _docDetails.repCode,
        invCode: _docDetails.invCode,
        repName: _docDetails.repName,
        cashReceCode: _docDetails.cashReceCode,
        cashReceLastNo:
            isCheque ? _docDetails.cashReceLastNo : nextCashReceLastNo,
        bankReceCode: _docDetails.bankReceCode,
        bankReceLastNo:
            isCheque ? nextBankReceLastNo : _docDetails.bankReceLastNo,
        repShortCode: _docDetails.repShortCode,
        returnCode: _docDetails.returnCode,
        invLastNo: _docDetails.invLastNo,
        returnLastNo: _docDetails.returnLastNo,
        docNoLength: _docDetails.docNoLength,
      ));
      successCollection
          .add(isCheque ? nextBankReceLastNo : nextCashReceLastNo);
    }
    if (successCollection.length == recieptList.length) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<Reciept>> getRecieptsByInvoiceId(String invoiceId) async {
    final db = await database;
    final data = await db.query(
      recieptTable,
      where: 'invoiceId = ?',
      whereArgs: [invoiceId],
    );

    List<Reciept> result = data.map((e) => Reciept.fromJson(e)).toList();
    return result;
  }

  Future<Reciept> getRecieptsByRecieptId(String recieptId) async {
    final db = await database;
    final data = await db.query(
      recieptTable,
      where: 'recieptId = ?',
      whereArgs: [recieptId],
    );

    Reciept result = Reciept.fromJson(data.first);
    return result;
  }

  Future<List<Reciept>> getAllReciepts() async {
    String? userId = await Settings.getUserID();
    final db = await database;
    final data = await db.query(
      recieptTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );

    List<Reciept> result = data.map((e) => Reciept.fromJson(e)).toList();
    return result;
  }

  Future<List<Reciept>> getAllRecieptByCustomer(
      String userId, int chtAccAccNo) async {
    final db = await database;
    final data = await db.query(
      recieptTable,
      where: 'userId = ? AND chtAccAccNo = ?',
      whereArgs: [userId, chtAccAccNo],
    );
    List<Reciept> result = data.map((e) => Reciept.fromJson(e)).toList();
    return result;
  }

  // Future<List<Cheque>> getAllCheques() async {
  //   String? userId = await Settings.getUserID();
  //   final db = await database;
  //   final data = await db.query(
  //     chequeTable,
  //     where: 'userId = ?',
  //     whereArgs: [userId],
  //   );

  //   List<Cheque> result = data.map((e) => Cheque.fromJson(e)).toList();
  //   return result;
  // }

  Future<int> insertSettingType(SettingTypes settingType) async {
    Database db = await database;
    return await db.insert(settingTypesTable, settingType.toJson());
  }

  Future<SettingTypes> getSettingType() async {
    Database db = await database;
    final data = await db.query(
      settingTypesTable,
    );
    SettingTypes settingType = SettingTypes.fromJson(data.first);
    return settingType;
  }

  Future<void> insertBanks(List<Bank> banks) async {
    final db = await database;
    final batch = db.batch();
    String userId = await Settings.getUserID() ?? '';
    await db.delete(
      banksTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    for (Bank bank in banks) {
      batch.insert(banksTable, bank.toJson());
    }
    await batch.commit(noResult: true);
  }

  Future<List<Bank>> getBanksByUserId(String userId) async {
    final db = await database;
    final data = await db.query(
      banksTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    List<Bank> result = data.map((e) => Bank.fromJson(e)).toList();
    return result;
  }

  Future<int?> insertDoc(DocDetails docDetails) async {
    Database db = await database;
    final existingRows = await db.query(
      doctable,
      orderBy: '$colId ASC',
    );

    if (existingRows.isEmpty) {
      return await db.insert(doctable, docDetails.toJson());
    }

    final DocDetails existing = DocDetails.fromJson(existingRows.first);
    final int keepId = existingRows.first[colId] as int;
    final bool sameRep = docDetails.repCode != null &&
        existing.repCode != null &&
        docDetails.repCode == existing.repCode;

    if (sameRep) {
      await db.update(
        doctable,
        docDetails.toJson(),
        where: '$colId = ?',
        whereArgs: [keepId],
      );
      if (existingRows.length > 1) {
        await db.delete(
          doctable,
          where: '$colId != ?',
          whereArgs: [keepId],
        );
      }
      return keepId;
    }

    await db.delete(doctable);
    return await db.insert(doctable, docDetails.toJson());
  }

  Future<void> updateDocDetails(DocDetails docDetails) async {
    Database db = await database;
    final existingRows = await db.query(
      doctable,
      orderBy: '$colId ASC',
      limit: 1,
    );
    if (existingRows.isEmpty) {
      return;
    }
    final int keepId = existingRows.first[colId] as int;
    await db.update(
      doctable,
      docDetails.toJson(),
      where: '$colId = ?',
      whereArgs: [keepId],
    );
  }

  Future<DocDetails> getDocDetails({int? repCode}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      doctable,
      orderBy: '$colId ASC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return DocDetails.fromJson(maps.first);
    }
    return DocDetails.empty();
  }

  Future<int> insertClosedTrip(ClosedTrip closedTrip) async {
    Database db = await database;
    return await db.insert(closedTripsTable, closedTrip.toJson());
  }

  Future<List<ClosedTrip>> getclosedTrips() async {
    String userId = await Settings.getUserID() ?? '';
    final db = await database;
    final maps = await db.query(
      closedTripsTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    if (maps.isNotEmpty) {
      List<ClosedTrip> result =
          maps.map((e) => ClosedTrip.fromJson(e)).toList();
      return result;
    }
    return [];
  }
  // // Update a user
  // Future<int> updateUser(Map<String, dynamic> user) async {
  //   Database db = await database;
  //   int id = user[colId];
  //   return await db.update(
  //     userTable,
  //     user,
  //     where: '$colId = ?',
  //     whereArgs: [id],
  //   );
  // }

  // // Delete a user
  // Future<int> deleteUser(int id) async {
  //   Database db = await database;
  //   return await db.delete(
  //     userTable,
  //     where: '$colId = ?',
  //     whereArgs: [id],
  //   );
  // }

  // Close the database
  Future<void> close() async {
    Database db = await database;
    await db.close();
  }


Future<void> clearTourCloseData(String userId) async {
  final db = await database;

  await db.transaction((txn) async {
    // Delete invoice line items first
    final invoiceRows = await txn.query(
      invoiceTable,
      columns: [colInvoiceId],
      where: '$colUserId = ?',
      whereArgs: [userId],
    );

    final invoiceIds = invoiceRows
        .map((row) => row[colInvoiceId]?.toString())
        .whereType<String>()
        .toList();

    for (final invoiceId in invoiceIds) {
      await txn.delete(
        invoicedItemTable,
        where: '$colInvoiceId = ?',
        whereArgs: [invoiceId],
      );
    }

    // Delete invoices
    await txn.delete(
      invoiceTable,
      where: '$colUserId = ?',
      whereArgs: [userId],
    );

    // Delete receipts
    await txn.delete(
      recieptTable,
      where: '$colUserId = ?',
      whereArgs: [userId],
    );

    // Delete GIN
    await txn.delete(
      ginTable,
      where: '$colUserId = ?',
      whereArgs: [userId],
    );

    // Delete GIN line items
    await txn.delete(
      lineItemsTable,
      where: '$colUserId = ?',
      whereArgs: [userId],
    );
  });
}

}
