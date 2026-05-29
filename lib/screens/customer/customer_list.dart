import 'package:flutter/material.dart';
import 'package:m_sales/Widgets/custome-components/custome_text_field.dart';
import 'package:m_sales/Widgets/full_screen_loading.dart';
import 'package:m_sales/helper/db_helper.dart';
import 'package:m_sales/helper/local_db.dart';
import 'package:m_sales/models/customer.dart';
import 'package:m_sales/screens/customer/customer_details.dart';

class CustomerList extends StatefulWidget {
  CustomerList({super.key});

  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  final List<Map<String, String>> customerData = [
    {
      'name': 'Budget Shop Super City',
      'customerCode': 'C-00026',
      'location': 'Colombo',
      'imagePath': 'images/pngline.png',
    },
    {
      'name': 'Family Choice',
      'customerCode': 'C-00027',
      'location': 'Negombo',
      'imagePath': 'images/pngline.png',
    },
    {
      'name': 'Jayani Resturant',
      'customerCode': 'C-00028',
      'location': 'Moratuwa',
      'imagePath': 'images/pngline.png',
    },
    {
      'name': 'Rajabojun (pvt) Ltd',
      'customerCode': 'C-00029',
      'location': 'Ja-Ela',
      'imagePath': 'images/pngline.png',
    },
    {
      'name': 'Dan Foods',
      'customerCode': 'C-00030',
      'location': 'Galle',
      'imagePath': 'images/pngline.png',
    },
    {
      'name': 'A V C Family Super',
      'customerCode': 'C-00031',
      'location': 'Rajagiriya',
      'imagePath': 'images/pngline.png',
    },
    {
      'name': 'Rajabojun (pvt) Ltd',
      'customerCode': 'C-00032',
      'location': 'Ja-Ela',
      'imagePath': 'images/pngline.png',
    },
    {
      'name': 'Teldeniya Traders',
      'customerCode': 'C-00033',
      'location': 'Teldeniya',
      'imagePath': 'images/pngline.png',
    },
    {
      'name': 'Harshani Stores',
      'customerCode': 'C-00034',
      'location': 'Bandaragama',
      'imagePath': 'images/pngline.png',
    },
    {
      'name': 'Premawardhana Stores',
      'customerCode': 'C-00035',
      'location': 'Horana',
      'imagePath': 'images/pngline.png',
    }
  ];

  List<Customer> customerList = [];
  bool isLoading = true;
  TextEditingController customerController = TextEditingController();
  List<Customer> customerListSearchResult = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    String userId = await Settings.getUserID() ?? '';
    customerList = await DatabaseHelper.instance.getCustomersByUserId(userId);

    customerList.sort((a, b) =>
        a.chtAccName!.toLowerCase().compareTo(b.chtAccName!.toLowerCase()));
    customerListSearchResult = customerList;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const FullScreenLoading()
          : customerList.isEmpty
              ? const Center(
                  child: Text('No Customers'),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
                      child: CustomTextField(
                        name: '',
                        controller: customerController,
                        hint: "Search",
                        onChange: (v) {
                          setState(() {
                            customerListSearchResult =
                                customerList.where((cus) {
                              return cus.chtAccName!.toLowerCase().contains(
                                  customerController.text.trim().toLowerCase());
                            }).toList();
                          });
                        },
                        prefixIcon: Icons.search,
                        textInputType: TextInputType.none,
                        obscureText: false,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    customerListSearchResult.isEmpty
                        ? SizedBox.shrink()
                        : Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: customerListSearchResult.length,
                              itemBuilder: (context, index) {
                                final customer =
                                    customerListSearchResult[index];
                                return Card(
                                  color: Colors.orange[50],
                                  child: ListTile(
                                    title: Text(
                                      customer.chtAccName ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle:
                                        Text(customer.chtAccAddress ?? ''),
                                    leading: const Image(
                                        image:
                                            AssetImage('images/pngline.png')),
                                    trailing: Text(
                                      customer.chtAccAlias?.toString() ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) => CustomerDetails(
                                          callGet: true,
                                          customer: customer,
                                        ),
                                      ));
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange[400],
        onPressed: () {
          // Add action for floating button
        },
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
    );
  }
}
