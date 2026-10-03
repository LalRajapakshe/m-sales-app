import 'package:flutter/material.dart';
import 'package:m_sales/Widgets/loading.dart';
import 'package:m_sales/helper/local_db.dart';
import 'package:m_sales/models/customer.dart';
import 'package:m_sales/services/customer_service.dart';
import 'package:m_sales/services/data_save_service.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';

syncData(BuildContext context, Customer? customer) async {
  Loading().startLoading(context);
  String? userName = await Settings.getUserName();
  String? password = await Settings.getPassword();
  String? userId = await Settings.getUserID();

  await Provider.of<AuthService>(context, listen: false)
      .login(userName!, password!);
  await Provider.of<CustomerProvider>(context, listen: false)
      .fetchCustomers(userId!);
  await Provider.of<CustomerProvider>(context, listen: false)
      .syncGinStuff(userId);
  await SaveDataService().getDocAttribute();

  if (customer != null) {
    String refCode = await Settings.getGinStuHdrFgnRefCode() ?? '';
    await Provider.of<CustomerProvider>(context, listen: false)
        .fetchPrices(userId, refCode, customer.chtAccPriceTblCode!, 'Cash');
  }
  Loading().stopLoading(context);
}

validator(String controller, errorItem) {
  if (controller.isEmpty) {
    return '$errorItem required';
  }
}

/// Fresh tour only. Does not call syncGinStuff.
/// [newFgns] must be the FGN reference codes from the GIN list just saved.
/// Master sync, the active-FGN preference, and UpdateGINStatus run only when
/// that list contains exactly one FGN reference code.
Future<bool> syncFreshTourMasters(
    BuildContext context, String userId, List<String> newFgns) async {
  if (newFgns.length != 1) {
    print('FRESH GIN - expected exactly one FGN, got: $newFgns');
    return false;
  }
  final CustomerProvider provider =
      Provider.of<CustomerProvider>(context, listen: false);

  try {
    print('FRESH GIN - syncing master data for FGN: $newFgns');
    print('FRESH SYNC -> fetchCustomers START');
    try {
      await provider.fetchCustomers(userId);
      print('FRESH SYNC -> fetchCustomers RESULT: completed');
    } catch (error) {
      print('FRESH SYNC -> fetchCustomers EXCEPTION: $error');
      rethrow;
    }
    print('FRESH SYNC -> fetchItems START');
    try {
      await provider.fetchItems(userId);
      print('FRESH SYNC -> fetchItems RESULT: completed');
    } catch (error) {
      print('FRESH SYNC -> fetchItems EXCEPTION: $error');
      rethrow;
    }
    print('FRESH SYNC -> fetchBankList START');
    try {
      await provider.fetchBankList(userId);
      print('FRESH SYNC -> fetchBankList RESULT: completed');
    } catch (error) {
      print('FRESH SYNC -> fetchBankList EXCEPTION: $error');
      rethrow;
    }
    print('FRESH SYNC -> getDocAttribute START');
    late final bool docsSynced;
    try {
      docsSynced = await SaveDataService().getDocAttribute();
      print('FRESH SYNC -> getDocAttribute RESULT: $docsSynced');
    } catch (error) {
      print('FRESH SYNC -> getDocAttribute EXCEPTION: $error');
      rethrow;
    }
    if (!docsSynced) {
      print('FRESH GIN - document attributes failed');
      return false;
    }
    print('FRESH SYNC -> syncPriceTable START, FGN=$newFgns');
    try {
      await provider.syncPriceTable(userId, newFgns);
      print('FRESH SYNC -> syncPriceTable RESULT: completed');
    } catch (error) {
      print('FRESH SYNC -> syncPriceTable EXCEPTION: $error');
      rethrow;
    }
    await Settings.setGinStuHdrFgnRefCode(newFgns.single);
    print('FRESH GIN - active FGN stored: ${newFgns.single}');
    print('FRESH SYNC -> UpdateGINStatus FGN: ${newFgns.single}');
    bool updateGinSuccess = false;
    try {
      updateGinSuccess = await Provider.of<AuthService>(
        context,
        listen: false,
      ).updateGin(newFgns.single);
    } catch (error) {
      updateGinSuccess = false;
      print('FRESH SYNC -> UpdateGINStatus error: $error');
    }
    print('FRESH SYNC -> UpdateGINStatus result: $updateGinSuccess');
    print('FRESH GIN - master data completed');
    return true;
  } catch (error, stackTrace) {
    print('FRESH GIN MASTER SYNC ERROR: $error');
    print('FRESH GIN MASTER SYNC STACK: $stackTrace');
    return false;
  }
}
