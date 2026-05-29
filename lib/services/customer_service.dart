import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:m_sales/api/api_consts.dart';
import 'package:m_sales/helper/db_helper.dart';
import 'package:m_sales/helper/local_db.dart';
import 'package:m_sales/main.dart';
import 'package:m_sales/models/bank.dart';
import 'package:m_sales/models/customer.dart';
import 'package:m_sales/models/due_bill.dart';
import 'package:m_sales/models/gin_response.dart';
import 'dart:convert';

import 'package:m_sales/models/item.dart';
import 'package:m_sales/models/price.dart';
import 'package:m_sales/models/setting_types.dart';
import 'package:m_sales/models/user_model.dart';
import 'package:m_sales/services/auth_service.dart';
import 'package:provider/provider.dart';

class CustomerProvider with ChangeNotifier {
  List<Customer> _customers = [];

  List<Customer> get customers => _customers;

  List<ItemTableItem> _items = [];

  List<ItemTableItem> get items => _items;

  List<Price> _prices = [];

  List<Price> get prices => _prices;

  List<GinResponse> _ginResponse = [];
  List<GinResponse> get ginresponse => _ginResponse;

  List<Bank> bankList = [];
  List<Bank> get getBankList => bankList;

  List<DueBill> dueBillList = [];
  List<DueBill> get getDueBillList => dueBillList;

  GinResponse selectedGin = GinResponse.empty();

  DateTime now = DateTime.now();
  DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

  Future<void> fetchCustomers(String userId) async {
    print("CUSTOMER FETCH ");
    String formattedDate = formatter.format(now);
    final url = Uri.parse(
        '$BASER_URL/tapi/$TENENT/mobile/mobileSales/syncCustomerMaster?UserId=$userId&RequestDateTime=$formattedDate');

    String accessToken = await Settings.getAccessToken();
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $accessToken"
        },
      );
      print("CUSTOMER FETCH ");
      print(response);
      print("CUSTOMER FETCH ");
      if (response.statusCode == 200) {
        print(url);
        print(response.body);
        List<dynamic> data = json.decode(response.body);
        _customers = data.map((json) {
          Customer _customer = Customer.fromJson(json);
          _customer.userId = userId;
          return _customer;
        }).toList();
        await DatabaseHelper.instance.insertCustomers(_customers);
        notifyListeners();
      } else {
        throw Exception('Failed to load customers');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchItems(String userId) async {
    String formattedDate = formatter.format(now);
    final url = Uri.parse(
        '$BASER_URL/tapi/$TENENT/mobile/mobileSales/syncItemMaster?UserId=$userId&RequestDateTime=$formattedDate');
    String accessToken = await Settings.getAccessToken();
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $accessToken"
        },
      );
      print(url);
      print("response.body ITEM");
      print(response.body);
      print("response.body ITEM");

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _items = data.map((json) {
          ItemTableItem _item = ItemTableItem.fromJson(json);
          _item.userId = userId;
          print(_items);
          return _item;
        }).toList();
        await DatabaseHelper.instance.insertItems(_items);
        notifyListeners();
      } else {
        throw Exception('Failed to load items');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchPrices(
      String userId, String refCode, int cusPrTbCode, String payType) async {
    String formattedDate = formatter.format(now);
    String accessToken = await Settings.getAccessToken();
    final url = Uri.parse(
        '$BASER_URL/tapi/$TENENT/mobile/mobileSales/syncPriceTableMaster?UserId=$userId&RequestDateTime=$formattedDate&GinNo=$refCode');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $accessToken"
        },
      );
      print(url);
      print(response.body);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _prices = data.map((json) {
          Price _price = Price.fromJson(json);
          _price.userId = userId;
          return _price;
        }).toList();
        List<LineItems> lineItemsInDB = [];
        lineItemsInDB = await DatabaseHelper.instance
            .getLineItemsByUserIdAndRefCode(userId, refCode);

        List<LineItems> updatedLineItems = [];
        SettingTypes settingType =
            await DatabaseHelper.instance.getSettingType();

        for (var itm in lineItemsInDB) {
          Price? selectedPrice = _prices.firstWhere((element) {
            if (settingType.batchBase == 'YES' &&
                settingType.payModeBase == 'NO') {
              return element.prTbPriceTableCode == cusPrTbCode &&
                  element.prTbItemCode == itm.ginStuItemCode &&
                  itm.ginBatchNo == element.prTbBatchCOde;
            } else if (settingType.batchBase == 'NO' &&
                settingType.payModeBase == 'YES') {
              return element.prTbPriceTableCode == cusPrTbCode &&
                  element.prTbItemCode == itm.ginStuItemCode &&
                  payType == element.priceType;
            } else if (settingType.batchBase == 'YES' &&
                settingType.payModeBase == 'YES') {
              return element.prTbPriceTableCode == cusPrTbCode &&
                  element.prTbItemCode == itm.ginStuItemCode &&
                  payType == element.priceType &&
                  itm.ginBatchNo == element.prTbBatchCOde;
            } else {
              return element.prTbPriceTableCode == cusPrTbCode &&
                  element.prTbItemCode == itm.ginStuItemCode;
            }
          }, orElse: () => Price());
          if (selectedPrice.price != null) {
            updatedLineItems.add(LineItems(
                id: itm.id,
                ginBatchNo: itm.ginBatchNo,
                ginStuAlise: itm.ginStuAlise,
                ginStuGinCode: itm.ginStuGinCode,
                ginStuItemCode: itm.ginStuItemCode,
                ginStuName: itm.ginStuName,
                ginStuQuantity: itm.ginStuQuantity,
                ginStuQuantityPkts: itm.ginStuQuantityPkts,
                ginStuUnitName: itm.ginStuUnitName,
                itMstDefualtPrice: selectedPrice.price,
                ginStuHdrFgnRefCode: itm.ginStuHdrFgnRefCode,
                handsOnQty: itm.handsOnQty,
                userId: itm.userId));
          }

          await DatabaseHelper.instance.updateLineItemsPrice(updatedLineItems);
          notifyListeners();
        }
      } else if (response.statusCode == 401) {
        BuildContext? context = navigatorKey.currentState?.context;
        var userName = await Settings.getUserName();
        var password = await Settings.getPassword();
        await Provider.of<AuthService>(context!, listen: false)
            .login(userName!, password!);
        fetchPrices(userId, refCode, cusPrTbCode, payType);
      } else {
        throw Exception('Failed to load prices');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> syncGinStuff(String userId) async {
    String formattedDate = formatter.format(now);
    String accessToken = await Settings.getAccessToken();
    final url = Uri.parse(
        '$BASER_URL/tapi/$TENENT/mobile/mobileSales/syncGinStuffHeader?GinNo=NULL&UserId=$userId&RequestDateTime=$formattedDate');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $accessToken"
        },
      );
      print(url);
      print(response.body);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _ginResponse = data.map((json) {
          GinResponse _gin = GinResponse.fromJson(json);
          _gin.userId = userId;
          return _gin;
        }).toList();

        for (var ginItem in _ginResponse) {
          String ginStuHdrFgnRefCode = ginItem.ginStuHdrFgnRefCode!;

          for (var lineItm in ginItem.lineItems!) {
            lineItm.ginStuHdrFgnRefCode = ginStuHdrFgnRefCode;
            lineItm.userId = userId;
          }
        }

        if (_ginResponse.isNotEmpty) {
          await DatabaseHelper.instance.insertGinResponse(_ginResponse);
        }
        notifyListeners();
      } else {
        throw Exception('Failed to load');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> getDueBills(String userId) async {
    String formattedDate = formatter.format(now);
    String accessToken = await Settings.getAccessToken();
    final url = Uri.parse(
        '$BASER_URL/tapi/$TENENT/mobile/mobileSales/syncDueBills?UserId=$userId&RequestDateTime=$formattedDate');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $accessToken"
        },
      );
      print(url);
      print(response.body);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _ginResponse = data.map((json) {
          GinResponse _gin = GinResponse.fromJson(json);
          _gin.userId = userId;
          return _gin;
        }).toList();

        for (var ginItem in _ginResponse) {
          String ginStuHdrFgnRefCode = ginItem.ginStuHdrFgnRefCode!;

          for (var lineItm in ginItem.lineItems!) {
            lineItm.ginStuHdrFgnRefCode = ginStuHdrFgnRefCode;
            lineItm.userId = userId;
          }
        }

        if (_ginResponse.isNotEmpty) {
          await DatabaseHelper.instance.insertGinResponse(_ginResponse);
        }
        notifyListeners();
      } else {
        throw Exception('Failed to load');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchBankList(String userId) async {
    String formattedDate = formatter.format(now);
    String accessToken = await Settings.getAccessToken();
    final url = Uri.parse(
        '$BASER_URL/tapi/$TENENT/mobile/mobileSales/syncBankMaster?UserId=$userId&RequestDateTime=$formattedDate');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $accessToken"
        },
      );
      print(url);
      print(response.body);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        bankList = data.map((json) {
          Bank _bank = Bank.fromJson(json);
          return _bank;
        }).toList();

        if (bankList.isNotEmpty) {
          for (var bank in bankList) {
            bank.userId = userId;
          }
          await DatabaseHelper.instance.insertBanks(bankList);
        }
        notifyListeners();
      } else {
        throw Exception('Failed to load');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> saveRecord(String userId) async {
    String formattedDate = formatter.format(now);
    String accessToken = await Settings.getAccessToken();
    final url = Uri.parse(
        '$BASER_URL/tapi/$TENENT/mobile/mobileSales/syncSaveDocHeader?GinNo=NULL&UserId=$userId&RequestDateTime=$formattedDate');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $accessToken"
        },
      );
      print(url);
      print(response.body);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _ginResponse = data.map((json) {
          GinResponse _gin = GinResponse.fromJson(json);
          _gin.userId = userId;
          return _gin;
        }).toList();

        for (var ginItem in _ginResponse) {
          String ginStuHdrFgnRefCode = ginItem.ginStuHdrFgnRefCode!;

          for (var lineItm in ginItem.lineItems!) {
            lineItm.ginStuHdrFgnRefCode = ginStuHdrFgnRefCode;
            lineItm.userId = userId;
          }
        }

        if (_ginResponse.isNotEmpty) {
          await DatabaseHelper.instance.insertGinResponse(_ginResponse);
        }
        notifyListeners();
      } else {
        throw Exception('Failed to load');
      }
    } catch (error) {
      throw error;
    }
  }

  //  Future<void> fetchDoc(String userId) async {
  //   String formattedDate = formatter.format(now);
  //   final url = Uri.parse(
  //       '$BASER_URL/tapi/$TENENT/mobile/mobileSales/SyncDocAttributeMaster?UserId=$userId&RequestDateTime=$formattedDate');
  //   String accessToken = await Settings.getAccessToken();
  //   try {
  //     final response = await http.get(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         "Authorization": "Bearer $accessToken"
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       print(url);
  //       print(response.body);
  //       List<dynamic> data = json.decode(response.body);
  //       _items = data.map((json) {
  //         ItemTableItem _item = ItemTableItem.fromJson(json);
  //         _item.userId = userId;
  //         return _item;
  //       }).toList();
  //       await DatabaseHelper.instance.insertItems(_items);
  //       notifyListeners();
  //     } else {
  //       throw Exception('Failed to load items');
  //     }
  //   } catch (error) {
  //     throw error;
  //   }
  // }

  //  Future<void> fetchItems(String userId) async {
  //   String formattedDate = formatter.format(now);
  //   final url = Uri.parse(
  //       '$BASER_URL/tapi/$TENENT/mobile/mobileSales/syncItemMaster?UserId=$userId&RequestDateTime=$formattedDate');
  //   String accessToken = await Settings.getAccessToken();
  //   try {
  //     final response = await http.get(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         "Authorization": "Bearer $accessToken"
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       print(url);
  //       print(response.body);
  //       List<dynamic> data = json.decode(response.body);
  //       _items = data.map((json) {
  //         ItemTableItem _item = ItemTableItem.fromJson(json);
  //         _item.userId = userId;
  //         return _item;
  //       }).toList();
  //       await DatabaseHelper.instance.insertItems(_items);
  //       notifyListeners();
  //     } else {
  //       throw Exception('Failed to load items');
  //     }
  //   } catch (error) {
  //     throw error;
  //   }
  // }
}
