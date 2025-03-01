import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sport_ims/utils/Colors.dart';

import '../models/NotificationModel.dart';

class NotificationPage extends StatefulWidget {
  NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late List<NotificationModel> notifications = [];

  Future<void> _getNotifications() async {
    List<NotificationModel> clubs = [];
    final database = FirebaseDatabase.instance;
    final ref = database.ref().child('appData/notificationData');

    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      for (final child in snapshot.children) {
        NotificationModel club = NotificationModel.fromJson(Map<String, dynamic>.from(child.value as Map));
        clubs.add(club);
        print(club.title);
      }
    } else {
      print('No data available.');
    }

    setState(() {
      notifications = clubs;
    });
  }

  Future<void> _addNotification(NotificationModel notification) async {
    final database = FirebaseDatabase.instance;
    final ref = database.ref().child('appData/notificationData').push();

    await ref.set(notification.toJson());
    _getNotifications();
  }

  Future<void> _removeNotification(String key) async {
    final database = FirebaseDatabase.instance;
    final ref = database.ref().child('appData/notificationData').child(key);

    await ref.remove();
    _getNotifications();
  }

  void _showAddNotificationDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: messageController,
              decoration: InputDecoration(labelText: 'Message'),
            ),
            TextField(
              controller: timeController,
              decoration: InputDecoration(labelText: 'Time'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newNotification = NotificationModel(
                title: titleController.text,
                message: messageController.text,
                time: timeController.text,
              );
              _addNotification(newNotification);
              Navigator.of(context).pop();
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: AppColors().bluePrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddNotificationDialog,
          ),
          Container(
            width: 10,
          )
        ],
      ),
      body: Container(
        color: Color(0xffcbdcf7),
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              elevation: 3.0,
              child: ListTile(
                contentPadding: EdgeInsets.all(10.0),
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.notifications, color: Colors.white),
                ),
                title: Text(
                  notification.title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4.0),
                    Text(
                      notification.message,
                      style: TextStyle(fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      notification.time,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                 //   _removeNotification(notification.key!);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
