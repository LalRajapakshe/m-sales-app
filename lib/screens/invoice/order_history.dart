import 'package:flutter/material.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("Order History"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.question_mark),
            tooltip: '??',
            onPressed: () {
              // handle the press
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tempory pvt.ltd',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      'TCKJDKKJKJKJK55JD',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      'TCKJDKKJKJKJK55JD',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Card(
                color: Colors.orange[50],
                child: Column(
                  children: List.generate(
                    20,
                    (index) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: index % 2 == 0
                            ? Colors.orange[50]
                            : Colors.orange[80],
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: const ListTile(
                          title: Text(
                            "WG/MT/PO",
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("9874516652255"),
                          trailing: Text(
                            "LKR302356.00",
                            style: TextStyle(fontSize: 13),
                          )),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Weight',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(
                          width: 80,
                        ),
                        Text(
                          ":    " + '8.6',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Gross Total',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(
                          width: 80,
                        ),
                        Text(
                          ":    " + '10000000000.00',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Discount',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(
                          width: 80,
                        ),
                        Text(
                          ":    " + '1000.00',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Tax',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(
                          width: 80,
                        ),
                        Text(
                          ":    " + '6000.00',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'New Total',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(
                          width: 80,
                        ),
                        Text(
                          ":    " + '6000.00',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding:
            const EdgeInsets.only(bottom: 8.0), // Padding only from the bottom
        child: Row(
          mainAxisAlignment: MainAxisAlignment
              .spaceAround, // Evenly space the buttons with small space between
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 4.0), // Small padding on left and right
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12.0), // Slightly rounded edges
                    ),
                  ),
                  child: const Text(
                    'Print',
                    style: TextStyle(fontSize: 15.0, color: Colors.white),
                  ),
                  onPressed: () {},
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 4.0), // Small padding on left and right
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12.0), // Slightly rounded edges
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 15.0, color: Colors.white),
                  ),
                  onPressed: () {},
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 4.0), // Small padding on left and right
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12.0), // Slightly rounded edges
                    ),
                  ),
                  child: const Text(
                    'Repeat',
                    style: TextStyle(fontSize: 15.0, color: Colors.white),
                  ),
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
