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
import 'package:m_sales/services/data_save_service.dart';
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

  Future<void> getData() async {
  userId = await Settings.getUserID() ?? '';
  String? inprogressGin = await Settings.getGinStuHdrFgnRefCode();

  List<ClosedTrip> closedTripList =
      await DatabaseHelper.instance.getclosedTrips();

  List<GinResponse> fetchedGinResponses =
      await DatabaseHelper.instance.getAllGinResponsesByUserId(userId!);

  // Always rebuild the list from fresh DB data.
  ginResponses.clear();

  if (inprogressGin == null || inprogressGin.isEmpty) {
    if (closedTripList.isNotEmpty) {
      for (var ginRes in fetchedGinResponses) {
        bool isClosedGin = false;

        for (var trip in closedTripList) {
          if (ginRes.ginStuHdrFgnRefCode ==
              trip.ginStuHdrFgnRefCode) {
            isClosedGin = true;
            break;
          }
        }

        if (!isClosedGin) {
          ginResponses.add(ginRes);
        }
      }
    } else {
      ginResponses.addAll(fetchedGinResponses);
    }
  } else {
    // Only add the in-progress GIN if it exists in the refreshed data.
    final matchingGin = fetchedGinResponses.where(
      (element) =>
          element.ginStuHdrFgnRefCode == inprogressGin,
    );

    if (matchingGin.isNotEmpty) {
      ginResponses.add(matchingGin.first);
    }
  }

  // Remove duplicate GINs with the same FGN reference code.
final uniqueGinResponses = <String, GinResponse>{};

for (final gin in ginResponses) {
  final refCode = gin.ginStuHdrFgnRefCode;

  if (refCode != null && refCode.isNotEmpty) {
    uniqueGinResponses[refCode] = gin;
  }
}

ginResponses = uniqueGinResponses.values.toList();


  // Make sure the selected dropdown value still exists
  // exactly once in the current list.
  final matchingSelectedTrip = ginResponses.where(
    (gin) => gin.ginStuHdrFgnRefCode == selectedTrip,
  );

  if (selectedTrip != null && matchingSelectedTrip.length != 1) {
    selectedTrip = null;
  }

  // If there is an in-progress GIN, select it.
  if (inprogressGin != null &&
      inprogressGin.isNotEmpty &&
      ginResponses.any(
        (gin) => gin.ginStuHdrFgnRefCode == inprogressGin,
      )) {
    selectedTrip = inprogressGin;
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

  if (mounted) {
    setState(() {
      isLoading = false;
    });
  }
}

  /// Fresh tour only. Sub-GIN refresh must not call this.
  Future<bool> _syncFreshTourMasters(String userId) async {
    final CustomerProvider provider =
        Provider.of<CustomerProvider>(context, listen: false);
    final List<String> ginNos = provider.ginresponse
        .map((gin) => gin.ginStuHdrFgnRefCode)
        .whereType<String>()
        .where((code) => code.isNotEmpty)
        .toSet()
        .toList();
    if (ginNos.isEmpty) {
      print('FRESH GIN - no GIN returned');
      return false;
    }

    try {
      print('FRESH GIN - syncing master data');
      await provider.fetchCustomers(userId);
      await provider.fetchItems(userId);
      await provider.fetchBankList(userId);
      final bool docsSynced = await SaveDataService().getDocAttribute();
      if (!docsSynced) {
        print('FRESH GIN - document attributes failed');
        return false;
      }
      await provider.syncPriceTable(userId, ginNos);
      print('FRESH GIN - master data completed');
      return true;
    } catch (error, stackTrace) {
      print('FRESH GIN MASTER SYNC ERROR: $error');
      print('FRESH GIN MASTER SYNC STACK: $stackTrace');
      return false;
    }
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
                            print('REFRESH 1 - button pressed');
                            try {
                              Loading().startLoading(context);
                              final hasValidToken =
                                  await Provider.of<AuthService>(
                                context,
                                listen: false,
                              ).ensureValidAccessToken();
                              if (!hasValidToken) {
                                Get.snackbar(
                                  'Connection Required',
                                  'Refresh requires an internet connection. Please connect and try again.',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              final String? activeFgn =
                                  await Settings.getGinStuHdrFgnRefCode();
                              final bool isFreshGin =
                                  activeFgn == null || activeFgn.isEmpty;
                              print('REFRESH 2 - before syncGinStuff');
                              print('REFRESH - isFreshGin: $isFreshGin');
                              await Provider.of<CustomerProvider>(context,
                                      listen: false)
                                  .syncGinStuff(userId!);
                              print('REFRESH 3 - syncGinStuff completed');
                              if (isFreshGin) {
                                final bool mastersSynced =
                                    await _syncFreshTourMasters(userId!);
                                if (!mastersSynced) {
                                  Get.snackbar(
                                    'Sync Failed',
                                    'New tour data was not fully refreshed. Please try again.',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                  // GIN may exist locally, but masters are incomplete —
                                  // do not present the tour as fully ready.
                                  return;
                                }
                              }
                              print('REFRESH 4 - before getData');
                              await getData();
                              print('REFRESH 5 - getData completed');
                              print('REFRESH 6 - stopping loading');
                            } catch (error, stackTrace) {
                              print('REFRESH ERROR: $error');
                              print('REFRESH STACK TRACE: $stackTrace');
                            } finally {
                              Loading().stopLoading(context);
                            }
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
                  onPressed: () async {
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

                        final selectedGin = ginResponses.where(
                          (ginRes) =>
                              ginRes.ginStuHdrFgnRefCode == selectedTrip,
                        );

                        if (selectedGin.isEmpty) {
                          Get.snackbar(
                            'Warning',
                            'Please Select Trip',
                            backgroundColor: Colors.orange,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        await Settings.setGinStuHdrFgnRefCode(selectedTrip);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const Home(),
                          ),
                        );
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
}
