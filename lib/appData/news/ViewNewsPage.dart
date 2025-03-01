import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/NewsModel.dart';

class ViewNewsPage extends StatefulWidget {
  final NewsModel news;
  final List<NewsModel> relatedNews;

  ViewNewsPage({required this.news, required this.relatedNews});

  @override
  _ViewNewsPageState createState() => _ViewNewsPageState();
}

class _ViewNewsPageState extends State<ViewNewsPage> {
  final DatabaseReference newsRef = FirebaseDatabase.instance.ref().child('news');
  List<NewsModel> relatedNews = [];

  @override
  void initState() {
    super.initState();
    fetchRelatedNews();

  }

  // Fetch remaining news articles as related news from Firebase
  void fetchRelatedNews() async {

    setState(() {
      relatedNews = widget.relatedNews;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
            widget.news.title
        ),
        backgroundColor:const Color(0xffb0ccf8),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main News Content
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding:const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // News Image
                  if (widget.news.imgUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: Image.network(
                        'https://firebasestorage.googleapis.com/v0/b/sportimsweb.appspot.com/o/newsImages%2F${widget.news.imgUrl}?alt=media',
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // News Title
                  Text(
                    widget.news.title,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Metadata
                  Row(
                    children: [
                      Text(
                        'Published: ${DateFormat('MMMM d, yyyy').format(DateTime.parse(widget.news.createdAt))}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Updated: ${DateFormat('MMMM d, yyyy').format(DateTime.parse(widget.news.updatedAt))}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // News Content
                  Text(
                    widget.news.content,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Author Information (Optional)
                  const Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      'By: Author Name', // Replace with actual author info if available
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Related Articles Section
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Related Articles',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // List of related news articles
                  relatedNews.isNotEmpty
                      ? ListView.builder(
                    shrinkWrap: true, // Ensures ListView works within Column
                    itemCount: relatedNews.length,
                    itemBuilder: (context, index) {
                      final newsItem = relatedNews[index];
                      return buildRelatedArticleTile(newsItem);
                    },
                  )
                      : const Center(child: Text('No related articles found')),

                  // See more button

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build related article tiles
  Widget buildRelatedArticleTile(NewsModel news) {
    return InkWell(
      onTap:(){
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ViewNewsPage(news: news,relatedNews: widget.relatedNews,)
            )
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            // Article Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://firebasestorage.googleapis.com/v0/b/sportimsweb.appspot.com/o/newsImages%2F${news.imgUrl}?alt=media',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),

            // Article Title
            Expanded(
              child: Text(
                news.title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
