import 'package:flutter/material.dart';
import 'package:m_sales/Widgets/custome-components/tab_item.dart';
import 'package:m_sales/screens/dashboard/thisMonth.dart';
import 'package:m_sales/screens/dashboard/today.dart';

class ChartDash extends StatefulWidget {
  const ChartDash({Key? key});

  @override
  State<ChartDash> createState() => _ChartDashState();
}

class _ChartDashState extends State<ChartDash> {
  var currentPage = DashTabs.today;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.orange.shade100,
                  ),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black54,
                    tabs: const [
                      TabItem(tittle: "Today"),
                      TabItem(tittle: "This Month"),
                    ],
                    onTap: (index) {
                      setState(() {
                        switch (index) {
                          case 0:
                            currentPage = DashTabs.today;
                            break;

                          default:
                            currentPage = DashTabs.today;
                        }
                      });
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: getPage(currentPage),
            ),
          ],
        ),
      ),
    );
  }
}

Widget getPage(DashTabs page) {
  switch (page) {
    case DashTabs.today:
      return const TodayPage();
    case DashTabs.thismonth:
      return const ThisMonthPage();
  }
}

enum DashTabs { today, thismonth }
