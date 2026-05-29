import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static setAccessToken(String token) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setString("access_token", token);
  }

  static Future<String> getAccessToken() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    String? token = sharedPrefs.getString("access_token");
    return token?.replaceAll('"', '') ?? "";
  }

  static setUserName(String username) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setString("username", username);
  }

  static Future<String?> getUserName() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    String? username = sharedPrefs.getString("username");
    return username;
  }

  static setUserID(String userid) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setString("userid", userid);
  }

  static Future<String?> getUserID() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    String? userid = sharedPrefs.getString("userid");
    return userid;
  }

  static setPassword(String password) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setString("password", password);
  }

  static Future<String?> getPassword() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    String? password = sharedPrefs.getString("password");
    return password;
  }

  static setGinStuHdrFgnRefCode(String? ginStuHdrFgnRefCode) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setString("ginStuHdrFgnRefCode", ginStuHdrFgnRefCode ?? '');
  }

  static Future<String?> getGinStuHdrFgnRefCode() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    String? ginStuHdrFgnRefCode = sharedPrefs.getString("ginStuHdrFgnRefCode");
    return ginStuHdrFgnRefCode;
  }

  static setVatType(String vatType) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setString("vatType", vatType);
  }

  static Future<String?> getVatType() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    String? vatType = sharedPrefs.getString("vatType");
    return vatType;
  }
}
