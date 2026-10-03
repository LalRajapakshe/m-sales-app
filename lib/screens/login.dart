// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:m_sales/Widgets/loading.dart';
import 'package:m_sales/api/api_consts.dart';
import 'package:m_sales/helper/app_helper.dart';
import 'package:m_sales/helper/db_helper.dart';
import 'package:m_sales/helper/local_db.dart';
import 'package:m_sales/models/gin_response.dart';
import 'package:m_sales/models/setting_types.dart';
import 'package:m_sales/models/user_model.dart';
import 'package:m_sales/screens/business_trip.dart';
import 'package:m_sales/Widgets/custome-components/custome_text_field.dart';
import 'package:m_sales/services/auth_service.dart';
import 'package:m_sales/services/customer_service.dart';
import 'package:m_sales/services/data_save_service.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? selectedBusiness;
  String? selectedTrip;
  bool passwordVisibility = false;

  void _login() async {
    try {
      await Provider.of<AuthService>(context, listen: false)
          .login(usernameController.text, passwordController.text);
      if (!mounted) {
        return;
      }
      if (Provider.of<AuthService>(context, listen: false).isAuthenticated) {
        String? userId = await Settings.getUserID();
        // await DatabaseHelper.instance.insertSettingType(SettingTypes(
        //     vatAmount: 18.00,
        //     vattype: 'VAT_INCLUDE',
        //     batchBase: 'NO',
        //     payModeBase: 'NO',
        //     userId: userId));
        await getData(userId!);
      }
    } catch (error) {
      Loading().stopLoading(context);
      Get.snackbar(
        'Error',
        'Login Failed',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  getData(String userId) async {
    final String? activeFgn = await Settings.getGinStuHdrFgnRefCode();
    final bool isFreshGin = activeFgn == null || activeFgn.isEmpty;

    // An already-active FGN is a sub-GIN sync. Fresh acquisition must not
    // download masters before the GIN exists; that sync runs after it is saved.
    if (!isFreshGin) {
      await getCustomers(userId);
      await getItems(userId);
      // await getPrices(userId);
      await fetchBanks(userId);
      await getDocs();
    }

    final List<GinResponse> syncedGins = await syncGinStuff(userId);

    if (isFreshGin) {
      final List<String> newFgns = syncedGins
          .map((gin) => gin.ginStuHdrFgnRefCode)
          .whereType<String>()
          .where((code) => code.isNotEmpty)
          .toSet()
          .toList();

      if (newFgns.length > 1) {
        print('FRESH GIN - multiple FGNs returned; online setup stopped');
        Loading().stopLoading(context);
        Get.snackbar(
          'Tour Setup Stopped',
          'The server returned more than one active tour.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (newFgns.length == 1) {
        final bool mastersSynced =
            await syncFreshTourMasters(context, userId, newFgns);
        if (!mastersSynced) {
          Loading().stopLoading(context);
          Get.snackbar(
            'Sync Failed',
            'New tour data was not fully synchronized. Please try again.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
      }
    }

    User user = Provider.of<AuthService>(context, listen: false).user;
    setLoginData(user);
    Loading().stopLoading(context);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const SecondPage(),
      ),
      (route) => false,
    );
  }

  setLoginData(User user) {
    Settings.setUserName(user.username);
    Settings.setPassword(user.password);
    DatabaseHelper.instance.insertUser(user);
  }

  getCustomers(String userId) async {
    await Provider.of<CustomerProvider>(context, listen: false)
        .fetchCustomers(userId);
  }

  getItems(String userId) async {
    await Provider.of<CustomerProvider>(context, listen: false)
        .fetchItems(userId);
  }

  Future<List<GinResponse>> syncGinStuff(String userId) {
    return Provider.of<CustomerProvider>(context, listen: false)
        .syncGinStuff(userId);
    // .whenComplete(() async {
    // if (Provider.of<CustomerProvider>(context, listen: false)
    //         .ginresponse
    //         .ginNo !=
    //     null) {
    //   await Provider.of<CustomerProvider>(context, listen: false)
    //       .syncGinStuff(userId);
    // }
    //}
//);
  }

  getDocs() async {
    await SaveDataService().getDocAttribute();
  }

  fetchBanks(String userId) async {
    await Provider.of<CustomerProvider>(context, listen: false)
        .fetchBankList(userId);
  }

  _onTapLogin() async {
    print("------------");
    print(TENENT);
    print("------------");
    final username = usernameController.text;
    final password = passwordController.text;

    if (username.isEmpty) {
      Get.snackbar(
        'Error',
        'Enter User Name',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } else if (password.isEmpty) {
      Get.snackbar(
        'Error',
        'Enter Password',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } else {
      Loading().startLoading(context);
      final existingUser = await DatabaseHelper.instance
          .getUserByUsernameAndPassword(username, password);
      if (existingUser == null) {
        _login();
      } else {
        final isPasswordCorrect =
            await DatabaseHelper.instance.verifyPassword(username, password);

        if (isPasswordCorrect) {
          final logUser =
              await DatabaseHelper.instance.getUserByUsername(username);
          if (logUser != null) {
            await Settings.setUserName(logUser.username);
            await Settings.setPassword(logUser.password);
            await Settings.setUserID(logUser.userId!);
            Loading().stopLoading(context);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const SecondPage(),
              ),
              (route) => false,
            );
          } else {
            print("User not found with the provided username.");
          }
        } else {
          Loading().stopLoading(context);
          Get.snackbar(
            'Error',
            'Incorrect password',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(
                        width: 300,
                        height: 300,
                        child: Image.asset(
                          'images/asale.jpg',
                          fit: BoxFit.contain,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: CustomTextField(
                          controller: usernameController,
                          name: "yours@example.com",
                          prefixIcon: Icons.account_circle,
                          textInputType: TextInputType.name,
                          obscureText: false,
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: CustomTextField(
                          controller: passwordController,
                          name: "your password",
                          prefixIcon: Icons.lock,
                          suffix: GestureDetector(
                            onTap: () {
                              setState(() {
                                passwordVisibility = !passwordVisibility;
                              });
                            },
                            child: passwordVisibility
                                ? const Icon(Icons.visibility)
                                : const Icon(Icons.visibility_off),
                          ),
                          textInputType: TextInputType.name,
                          obscureText: passwordVisibility ? false : true,
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Don't remember your password ?",
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Version 1.6.2",
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 15.0, color: Colors.white),
                  ),
                  onPressed: () {
                    _onTapLogin();
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
