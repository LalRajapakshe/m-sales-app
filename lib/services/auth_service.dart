import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:m_sales/api/api_consts.dart';
import 'package:m_sales/helper/db_helper.dart';
import 'package:m_sales/helper/local_db.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:m_sales/models/setting_types.dart';
import 'package:m_sales/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  User _user = User(username: '', password: '');
  User get user => _user;

  Future<void> login(String userName, String password) async {
    print("----------FROM LOGIN----------");

    print(TENENT);
    print(BASER_URL);

    print("----------FROM LOGIN----------");
    final url = Uri.parse('${BASER_URL}tapi/$TENENT/authentications/token');
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          'userName': userName,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.body.isNotEmpty) {
        Map<String, dynamic> payload = JwtDecoder.decode(response.body);
        String userId = payload['UserId'];
        _user = User(username: userName, password: password, userId: userId);
        await Settings.setAccessToken(response.body);
        await Settings.setUserID(userId);
        // print(url);
        // print(response.body);
        _isAuthenticated = true;
        notifyListeners();
      } else {
        throw Exception('Failed to authenticate');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> ensureValidAccessToken() async {
    try {
      final accessToken = await Settings.getAccessToken();
      bool tokenIsValid = false;
      if (accessToken.isNotEmpty) {
        try {
          tokenIsValid = !JwtDecoder.isExpired(accessToken);
        } catch (_) {
          tokenIsValid = false;
        }
      }
      if (tokenIsValid) {
        return true;
      }

      final userName = await Settings.getUserName();
      final password = await Settings.getPassword();
      if (userName == null ||
          userName.isEmpty ||
          password == null ||
          password.isEmpty) {
        return false;
      }

      await login(userName, password).timeout(const Duration(seconds: 15));

      final refreshedToken = await Settings.getAccessToken();
      if (refreshedToken.isEmpty) {
        return false;
      }
      try {
        return !JwtDecoder.isExpired(refreshedToken);
      } catch (_) {
        return false;
      }
    } catch (error) {
      print('Unable to obtain a valid access token: $error');
      return false;
    }
  }

  Future<int> fetchSettings(String tenent) async {
    String vatAm = "0";
    String vatType = "N/A";
    String batchBas = "NO";
    String paymodeBas = "NO";
    String userId = "";
    String ten = "";
    String unitRate = "";
    String baseUrl = "";
    String invoiceCheck = "";
    String companyVatNo = "";

    String compName = "";
    String adress = "";
    String telp = "";
    String hotine = "";
    String emaila = "";
    String webs = "";
    String invtl1 = "";
    String invtl2 = "";

    print("fetchSettings FETCH ");
    final url = Uri.parse(
        '$BASER_URL/tapi/$tenent/mobile/mobileSales/SyncSystemSetting');
    try {
      final response = await http.get(
        url,
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        print(response.body);

        List<dynamic> responseList = jsonDecode(response.body);

        for (int i = 0; i < responseList.length; i++) {
          if (responseList[i]['settingType'].trim() == 'VAT_PERCENTAGE') {
            vatAm = responseList[i]['settingValue'];
          }

          if (responseList[i]['settingType'] == 'VAT_TYPE') {
            vatType = responseList[i]['settingValue'];
          }

          if (responseList[i]['settingType'] == 'BATCH BASE PRICING') {
            batchBas = responseList[i]['settingValue'];
          }

          if (responseList[i]['settingType'] == 'PAY_MODE_BASE_PRICING') {
            paymodeBas = responseList[i]['settingValue'];
          }

          if (responseList[i]['settingType'].trim() == 'COMPANY NAME') {
            compName = responseList[i]['settingValue'];
          }
          if (responseList[i]['settingType'].trim() == 'ADDRESS') {
            adress = responseList[i]['settingValue'];
          }
          if (responseList[i]['settingType'].trim() == 'TEL') {
            telp = responseList[i]['settingValue'];
          }
          if (responseList[i]['settingType'].trim() == 'HOT LINE') {
            hotine = responseList[i]['settingValue'];
          }
          if (responseList[i]['settingType'].trim() == 'E MAIL') {
            emaila = responseList[i]['settingValue'];
          }
          if (responseList[i]['settingType'].trim() == 'WEB') {
            webs = responseList[i]['settingValue'];
          }
          if (responseList[i]['settingType'].trim() == 'INVOICE TITLE') {
            invtl1 = responseList[i]['settingValue'];
          }
          if (responseList[i]['settingType'] == 'INVOICE TITLE 2 ') {
            invtl2 = responseList[i]['settingValue'];
          }

          if (responseList[i]['settingType'] == 'TENANT') {
            ten = responseList[i]['settingValue'];
          }
          if (responseList[i]['settingType'] == 'UNIT_RATE_EDITABLE') {
            unitRate = responseList[i]['settingValue'];
          }
          if (responseList[i]['settingType'] == 'BASE_URL') {
            baseUrl = responseList[i]['settingValue'];
          }
          if (responseList[i]['settingType'] == 'IS_INVOICE_WITHOUT_RECEIPT') {
            invoiceCheck = responseList[i]['settingValue'];
          }
          if (responseList[i]['settingType'] == 'COMPANY_VAT_NO') {
            companyVatNo = responseList[i]['settingValue'];
          }
        }

        print(vatAm);
        print('VAT Type: $vatType');
        print('Batch Base Pricing: $batchBas');
        print('Paymode Base Pricing: $paymodeBas');
        print('User ID: $userId');
        print('Tenet: $ten');
        print('Company Name: $compName');
        print('Address: $adress');
        print('Tel: $telp');
        print('Hotline: $hotine');
        print('Email: $emaila');
        print('Web: $webs');
        print('Invoice TTL 1: $invtl1');
        print('Invoice TTL 2: $invtl2');

        final SharedPreferences sharedPrefs =
            await SharedPreferences.getInstance();

        sharedPrefs.setString('company_name', compName);
        sharedPrefs.setString('address', adress);
        sharedPrefs.setString('tel', telp);
        sharedPrefs.setString('hotline', hotine);
        sharedPrefs.setString('email', emaila);
        sharedPrefs.setString('web', webs);
        sharedPrefs.setString('invttl1', invtl1);
        sharedPrefs.setString('invttl2', invtl2);
        sharedPrefs.setString('unitRt', unitRate);
        sharedPrefs.setString('invCheck', invoiceCheck);
        sharedPrefs.setString('companyVatNo', companyVatNo);

        TENENT = ten;
        BASER_URL = baseUrl;

        return await DatabaseHelper.instance.insertSettingType(SettingTypes(
          vatAmount: double.tryParse(vatAm),
          vattype: vatType,
          batchBase: batchBas,
          payModeBase: paymodeBas,
          userId: '',
          tenent: ten,
          unitRate: unitRate,
          baseUrl: baseUrl,
          invoiceCheck: invoiceCheck,
          companyVatNo: companyVatNo,
          companyName: compName,
          address: adress,
          tel: telp,
          hotline: hotine,
          email: emaila,
          web: webs,
          invttl1: invtl1,
          invttl2: invtl2,
        ));
      } else {
        throw Exception('Failed to load Settings');
      }
    } catch (error) {
      throw error;
    }
  }

 /*  Future<void> updateGin(String ginNo) async {
    print("TENENT : $TENENT");
    final url = Uri.parse(
        '${BASER_URL}/tapi/$TENENT/mobile/mobileSales/UpdateGINStatus');
    String accessToken = await Settings.getAccessToken();
    try {
      final body = jsonEncode({
        'GinNos': [
          {'ginNo': ginNo}
        ]
      });

      print("Request URL: $url");
      print("Request Body: $body");

      final response = await http.post(
        url,
        body: body,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $accessToken"
        },
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        // Success
        print("GIN UPDATE SUCCESS");
      } else {
        throw Exception(
            'Failed with status code: ${response.statusCode}, response: ${response.body}');
      }
    } catch (error) {
      print('Error in updateGin: $error');
      throw Exception('Error updating GIN: $error');
    }
  }
 */

Future<bool> updateGin(String ginNo) async {
  print('STEP 5 - updateGin received: $ginNo');
  print('STEP 6 - sending to API: $ginNo');
  final url = Uri.parse(
      '${BASER_URL}/tapi/$TENENT/mobile/mobileSales/UpdateGINStatus');

  String accessToken = await Settings.getAccessToken();

  try {
    final body = jsonEncode([
      {'ginNo': ginNo}
    ]);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: body,
    );

    print('UpdateGINStatus statusCode: ${response.statusCode}');
    print('UpdateGINStatus body: ${response.body}');
    print('UpdateGINStatus reasonPhrase: ${response.reasonPhrase}');

    if (response.statusCode != 200) {
      return false;
    }

    final result = int.tryParse(response.body);
    print('UpdateGINStatus parsed result: $result');

    if (result != null && result < 0) {
      return false;
    }

    return true;
  } catch (error) {
    print('Error updating GIN: $error');
    return false;
  }
}
  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
