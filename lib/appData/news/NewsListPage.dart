import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/NewsModel.dart';
import 'AddNewNews.dart';
import 'ViewNewsPage.dart';

class NewsListPage extends StatefulWidget {
  @override
  _NewsListPageState createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  final DatabaseReference newsRef = FirebaseDatabase.instance.ref().child('appData/news');
  List<NewsModel> newsList = [];

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  // Fetch news data from Firebase Realtime Database
  void fetchNews() async {
    newsRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        newsList = data.entries
            .map((e) => NewsModel.fromJson(Map<String, dynamic>.from(e.value)))
            .where((news) => news.deleteStatus == false)
            .toList();
      });
    });
  }

  // Soft delete news by setting deleteStatus to true
  void deleteNews(String id) {
    newsRef.child(id).update({'deleteStatus': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffcbdcf7),
      appBar: AppBar(
        title: Text('News List'),
        backgroundColor: Color(0xffb0ccf8),
        actions: [
          TextButton(onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddEditNewsPage())); // Go to Add News Page
          },
              child: Icon(Icons.add))
        ],
      ),
      body: newsList.isEmpty
          ? Center(child: Text('No News Available', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)))
          : ListView.builder(
        itemCount: newsList.length,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        itemBuilder: (context, index) {
          final news = newsList[index];
          return buildNewsCard(news);
        },
      ),
    );
  }

  // Build each news item card with improved design
  Widget buildNewsCard(NewsModel news) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewNewsPage(news: news,relatedNews: newsList,))); // View news details
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image from Firebase URL
            if (news.imgUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.all(
                    Radius.circular(12)
                ),
                child: Image.network(
                  'https://firebasestorage.googleapis.com/v0/b/sportimsweb.appspot.com/o/newsImages%2F${news.imgUrl}?alt=media',
                  height: 180,
                  width: 180,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    news.subtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Author: ${news.date}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'Updated: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(news.updatedAt))}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddEditNewsPage(
                                      news: news))); // Edit news
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDeleteConfirmation(context, news.id); // Delete confirmation
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show delete confirmation dialog
  void showDeleteConfirmation(BuildContext context, String newsId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete News'),
          content: Text('Are you sure you want to delete this news item?'),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                deleteNews(newsId);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
