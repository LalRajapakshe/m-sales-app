// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:m_sales/Widgets/custome-components/custome_text_field.dart';
import 'package:m_sales/api/api_consts.dart';
import 'package:m_sales/helper/db_helper.dart';
import 'package:m_sales/models/setting_types.dart';
import 'package:m_sales/screens/login.dart';
import 'package:m_sales/services/auth_service.dart';
import 'package:provider/provider.dart';

class TenetScreen extends StatelessWidget {
  TextEditingController tenentController = TextEditingController();
  late SettingTypes getSettingTypes;
  int status = 0;

  TenetScreen({super.key});
  @override
  Widget build(BuildContext context) {
    Future<void> setTenent() async {
      status = await Provider.of<AuthService>(context, listen: false)
          .fetchSettings(tenentController.text);
      // status =

      // TENENT = tenentController.text;

      if (status != 0) {
        TENENT = tenentController.text;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.white, Color.fromARGB(76, 255, 153, 0)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft)),
        child: Column(
          children: [
            // Spacer to push the TextField to the middle
            Spacer(flex: 2),

            // TextField in the middle of the screen
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: CustomTextField(
                controller: tenentController,
                name: "SFA-***",
                prefixIcon: Icons.dock_rounded,
                textInputType: TextInputType.name,
                obscureText: false,
                textCapitalization: TextCapitalization.words,
              ),
            ),

            // Spacer to keep TextField in the middle
            Spacer(flex: 3),

            // Next Button at the bottom
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity, // Make button full width
                height: 50, // Set height for the button
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 15.0, color: Colors.white),
                  ),
                  onPressed: () {
                    setTenent();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: TenetScreen()));
