import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/UsersModel.dart';




class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int skatersCount = 0;
  int clubsCount = 0;
  int districtSecretariesCount = 0;

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  // Fetch data for skaters, clubs, and district secretaries
  Future<void> fetchCounts() async {
    await fetchSkatersCount();
    await fetchClubsCount();
    await fetchDistrictSecretariesCount();
  }
  // Fetch skaters count from Firebase
  Future<void> fetchSkatersCount() async {
    final ref = FirebaseDatabase.instance.ref('skaters');
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      setState(() {
        skatersCount = snapshot.children.length;
      });
    }
  }

  // Fetch clubs count from Firebase
  Future<void> fetchClubsCount() async {
    final ref = FirebaseDatabase.instance.ref('clubs');
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      setState(() {
        clubsCount = snapshot.children.length;
      });
    }
  }


  // Fetch district secretaries count from Firebase, excluding those where deleteStatus is true
  Future<void> fetchDistrictSecretariesCount() async {
    final ref = FirebaseDatabase.instance.ref('districtSecretaries');
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      int count = 0;
      for (var districtSecretary in snapshot.children) {
        var secretaryData = districtSecretary.value as Map<dynamic, dynamic>;
        // Check if deleteStatus is either null or false
        if (secretaryData['deleteStatus'] == null || secretaryData['deleteStatus'] == false) {
          count++;
        }
      }

      setState(() {
        districtSecretariesCount = count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffcbdcf7),

      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Color(0xffb0ccf8),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the count of Skaters
            CountCard(
              title: 'Total Skaters',
              count: skatersCount,
              icon: Icons.person,
              backgroundColor: Colors.green[300]!,
            ),
            SizedBox(height: 20),

            // Display the count of Clubs
            CountCard(
              title: 'Total Clubs',
              count: clubsCount,
              icon: Icons.group,
              backgroundColor: Colors.orange[300]!,
            ),
            SizedBox(height: 20),

            // Display the count of District Secretaries
            CountCard(
              title: 'Total District Secretaries',
              count: districtSecretariesCount,
              icon: Icons.admin_panel_settings,
              backgroundColor: Colors.purple[300]!,
            ),
          ],
        ),
      ),
    );
  }
}

// Widget to display a count card with title, count, and an icon
class CountCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color backgroundColor;

  CountCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              size: 50,
              color: Colors.white,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
