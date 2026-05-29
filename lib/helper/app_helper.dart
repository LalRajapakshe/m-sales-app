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
