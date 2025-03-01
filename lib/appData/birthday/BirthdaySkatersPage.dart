import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/UsersModel.dart';
import '../../utils/Controllers.dart';


class BirthdaySkatersPage extends StatefulWidget {
  @override
  _BirthdaySkatersPageState createState() => _BirthdaySkatersPageState();
}

class _BirthdaySkatersPageState extends State<BirthdaySkatersPage> {
  List<Users> allUsers = []; // Replace this with your list of users
  List<Users> filteredUsers = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filterSkatersByBirthday();
  }

// Updated filterSkatersByBirthday function
  void filterSkatersByBirthday() async {
    List<Users> users = await getAllSkaters(); // Fetch all users
    String today = DateFormat('MM-dd').format(DateTime.now()); // Format today's date as MM-dd

    setState(() {
      allUsers = users.where((user) {
        // Parse and format the user's dateOfBirth
        String formattedDOB = formatDate(user.dateOfBirth); // Use the formatDate helper
        if (formattedDOB.isEmpty) return false; // Skip users with invalid date formats

        // Extract only the MM-dd part for comparison
        String userBirthday = DateFormat('MM-dd').format(DateFormat('dd-MM-yyyy').parse(formattedDOB));

        // Compare the formatted MM-dd with today's MM-dd
        return userBirthday == today;
      }).toList();

      filteredUsers = allUsers; // Initialize the filtered list
    });
  }

  // Filter users based on search query
  void searchUsers(String query) {
    final results = allUsers
        .where((user) => user.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      filteredUsers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffcbdcf7),
      appBar: AppBar(
        title: Text('Birthday Skaters'),
        backgroundColor: Color(0xffb0ccf8),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search users',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (query) {
                searchUsers(query); // Filter users when typing in search bar
              },
            ),
          ),
          // Grid of Birthday Skaters
          Expanded(
            child: filteredUsers.isEmpty
                ? Center(child: Text('No skaters have a birthday today.'))
                : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two cards per row
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 3 /1.2,
              ),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return buildUserCard(user);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Build each user card based on the design
  Widget buildUserCard(Users user) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile image, name, and location
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: user.profileImageUrl.isNotEmpty
                      ? NetworkImage(user.profileImageUrl)
                      : AssetImage('assets/images/default_profile.png') as ImageProvider,
                  radius: 30,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${user.state}, ${user.district}',
                        style: TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Tags (club, gender, etc.)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: userTags(user),
            ),
          ],
        ),
      ),
    );
  }

  // Generate tags (you can modify this based on your data)
  List<Widget> userTags(Users user) {
    return [
      Chip(label: Text(user.club)),
      Chip(label: Text(user.contactNumber)),
      // Add more tags if needed
    ];
  }
}

