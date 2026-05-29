import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m_sales/Widgets/full_screen_loading.dart';
import 'package:m_sales/Widgets/loading.dart';
import 'package:m_sales/helper/db_helper.dart';
import 'package:m_sales/helper/local_db.dart';
import 'package:m_sales/models/closedTrip.dart';
import 'package:m_sales/models/gin_response.dart';
import 'package:m_sales/screens/dashboard/landing_page.dart';
import 'package:m_sales/screens/login.dart';
import 'package:m_sales/services/auth_service.dart';
import 'package:m_sales/services/customer_service.dart';
import 'package:provider/provider.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  String? selectedBusiness;
  String? selectedTrip;
  List<GinResponse> ginResponses = [];
  bool isLoading = true;
  String buttonText = 'Done';
  String? userId;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    userId = await Settings.getUserID() ?? '';
    String? inprogressGin = await Settings.getGinStuHdrFgnRefCode();

    List<ClosedTrip> closedTripList =
        await DatabaseHelper.instance.getclosedTrips();

    List<GinResponse> _ginResponses =
        await DatabaseHelper.instance.getAllGinResponsesByUserId(userId!);

    if (inprogressGin == null || inprogressGin == '') {
      if (closedTripList.isNotEmpty) {
        for (var ginRes in _ginResponses) {
          bool isClosedGin = false;
          for (var trip in closedTripList) {
            if (ginRes.ginStuHdrFgnRefCode == trip.ginStuHdrFgnRefCode) {
              isClosedGin = true;
            }
          }
          if (!isClosedGin) {
            ginResponses.add(ginRes);
          }
        }
      } else {
        ginResponses = _ginResponses;
      }
    } else {
      ginResponses.add(_ginResponses.firstWhere((element) {
        return element.ginStuHdrFgnRefCode == inprogressGin;
      }));
    }

    if (ginResponses.isEmpty) {
      buttonText = 'Log out';
      Get.snackbar(
        'Error',
        'No trips available',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: isLoading
          ? const FullScreenLoading()
          : SizedBox(
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: () async {
                            Loading().startLoading(context);
                            await Provider.of<CustomerProvider>(context,
                                    listen: false)
                                .syncGinStuff(userId!);
                            await getData();
                            Loading().stopLoading(context);
                          },
                          icon: const Icon(Icons.sync)),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SizedBox(
                          width: 300,
                          height: 300,
                          child: Image.asset(
                            'images/asale.jpg',
                            fit: BoxFit.contain,
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: SizedBox(
                                height: 60, // Specify desired height
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.business),
                                    labelText: 'Business',
                                    border: OutlineInputBorder(),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedBusiness,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedBusiness = newValue;
                                        });
                                      },
                                      items: <String>[
                                        'Default',
                                      ].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: SizedBox(
                                height: 60, // Specify desired height
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.car_crash),
                                    labelText: 'Trip',
                                    border: OutlineInputBorder(),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedTrip,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedTrip = newValue;
                                          Settings.setGinStuHdrFgnRefCode(
                                              selectedTrip!);
                                        });
                                      },
                                      items: ginResponses.map((value) {
                                        return DropdownMenuItem<String>(
                                          value: value.ginStuHdrFgnRefCode
                                              .toString(),
                                          child: Text(value.ginStuHdrFgnRefCode
                                              .toString()),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(fontSize: 15.0, color: Colors.white),
                  ),
                  onPressed: () {
                    if (ginResponses.isNotEmpty) {
                      if (selectedBusiness == null) {
                        Get.snackbar(
                          'Warning',
                          'Please Select Business',
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                        );
                      } else if (selectedTrip == null) {
                        Get.snackbar(
                          'Warning',
                          'Please Select Trip',
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                        );
                      } else {
                        print("---====-=++_");
                        print(selectedTrip);
                        print("---====-=++_");

                        for (var ginRes in ginResponses) {
                          if (ginRes.ginStuHdrFgnRefCode == selectedTrip) {
                            updtGin(ginRes.ginStuHdrGinNo);

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const Home(),
                              ),
                            );
                          }
                        }
                      }
                    } else {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                          (Route<dynamic> route) => false);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updtGin(String? ginNo) async {
    print(ginNo);
    await Provider.of<AuthService>(context, listen: false).updateGin(ginNo!);
  }
}
