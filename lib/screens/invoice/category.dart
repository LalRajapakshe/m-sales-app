import 'package:flutter/material.dart';

class CategoryPage extends StatefulWidget {
  final Function callBack;
  const CategoryPage({Key? key, required this.callBack}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  // Define your array of data items
  final List<Map<String, dynamic>> gridData = [
    {'title': 'Old', 'imagePath': 'images/fcategory.png'},
    // {'title': 'Category 2', 'imagePath': 'images/fspeaker.png'},
    // {'title': 'Category 3', 'imagePath': 'images/profile.png'},
    // Add more data items as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.orange[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                hintText: "Search",
                prefixIcon: const Icon(Icons.search),
                prefixIconColor: Colors.orange,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check_circle_rounded),
                  color: Colors.orange,
                  onPressed: () {
                    // Clear search text
                  },
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0), // Add padding here
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 4.0, // Adjust the spacing between rows
                crossAxisSpacing: 4.0, // Adjust the spacing between columns
                children: List.generate(
                  gridData.length, // Use the length of your data array
                  (index) => Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey), // Add grey border
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Card(
                      elevation: 0, // Remove shadow
                      child: InkWell(
                        onTap: () {
                          widget.callBack();
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              gridData[index]
                                  ['imagePath'], // Use imagePath from data
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              gridData[index]['title'], // Use title from data
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
