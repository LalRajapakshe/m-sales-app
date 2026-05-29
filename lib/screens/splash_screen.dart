import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m_sales/api/api_consts.dart';
import 'package:m_sales/helper/db_helper.dart';
import 'package:m_sales/models/setting_types.dart';
import 'package:m_sales/screens/login.dart';
import 'package:m_sales/screens/tenet_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late SettingTypes getSettingTypes;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Delay for 2 seconds, then fetch the setting type
    Future.delayed(const Duration(seconds: 2), () async {
      final SharedPreferences sharedPrefs =
          await SharedPreferences.getInstance();
      // Fetch the setting type from the database
      getSettingTypes = await fetchSettingTypes();

      // Print the fetched setting types for debugging purposes
      print("getSettingTypes: ${getSettingTypes.toString()}");

      // Navigate based on the tenant value
      if (getSettingTypes.tenent == null || getSettingTypes.tenent == '') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => TenetScreen()),
        );
      } else {
        TENENT = getSettingTypes.tenent!;
        BASER_URL = getSettingTypes.baseUrl!;
        sharedPrefs.setString('unitRt', getSettingTypes.unitRate!);
        sharedPrefs.setString('invCheck', getSettingTypes.invoiceCheck!);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    });
  }

  Future<SettingTypes> fetchSettingTypes() async {
    try {
      return await DatabaseHelper.instance.getSettingType();
    } catch (e) {
      return SettingTypes.empty();
    }
  }

  @override
  void dispose() {
    // Re-enable the system UI overlays when the screen is disposed
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.orange],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.ac_unit,
              size: 80,
              color: Colors.orange[600],
            ),
            const SizedBox(height: 20),
            const Text(
              "Smart Sales",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.white,
                fontSize: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
