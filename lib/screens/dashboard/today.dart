import 'package:flutter/material.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({Key? key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First column with 3 cards
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Top",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: buildCard("Target", "LKR100")),
                    const SizedBox(width: 10),
                    Expanded(child: buildCard("Achieved", "LKR10")),
                    const SizedBox(width: 10),
                    Expanded(child: buildCard("Balance", "LKR100")),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Second column with bar chart
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Bar Chart",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 200, // Adjust height as needed
                  color: Colors.blue, // Placeholder color for chart
                  // Replace this container with your actual bar chart
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Third column with 4 cards
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Bottom",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: buildCard("Average", "LKR1001")),
                    const SizedBox(width: 10),
                    Expanded(child: buildCard("Total", "LKR100")),
                    const SizedBox(width: 10),
                    Expanded(child: buildCard("etc", "LKR1001")),
                    const SizedBox(width: 10),
                    Expanded(child: buildCard("etc", "LKR1001")),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard(String tittle, String subtt) {
    return SizedBox(
      width: 100, // Set the width of the card
      child: Card(
        elevation: 0, // Remove elevation for flat appearance
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(8), // Add border radius for square shape
        ),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(tittle),
              const SizedBox(height: 10),
              Text(subtt),
            ],
          ),
        ),
      ),
    );
  }
}
