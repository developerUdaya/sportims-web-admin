import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../models/GalleryModel.dart';
import 'AddEditGalleryPage.dart';

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final DatabaseReference galleryRef = FirebaseDatabase.instance.ref().child('gallery');
  List<GalleryModel> galleryList = [];
  List<GalleryModel> filteredGallery = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchGalleryItems();
  }

  // Show confirmation dialog before deleting the image
  void _showDeleteConfirmationDialog(GalleryModel gallery) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Image'),
          content: Text('Are you sure you want to delete this image?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without deleting
              },
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                deleteImage(gallery.id); // Call delete function if confirmed
                Navigator.pop(context); // Close the dialog after delete
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Fetch gallery data from Firebase Realtime Database
  void fetchGalleryItems() async {
    galleryRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        galleryList = data.entries
            .map((e) => GalleryModel.fromJson(Map<String, dynamic>.from(e.value)))
            .where((item) => item.deleteStatus == false)
            .toList();
        filteredGallery = galleryList;
      });
    });
  }

  // Search functionality for filtering gallery images by title
  void searchGallery(String query) {
    final results = galleryList
        .where((gallery) => gallery.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      filteredGallery = results;
    });
  }

  // Soft delete image by setting deleteStatus to true
  void deleteImage(String id) {
    galleryRef.child(id).update({'deleteStatus': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffcbdcf7),

      appBar: AppBar(
        title: Text('Gallery'),
        backgroundColor: Color(0xffb0ccf8),
        actions: [
          TextButton(
            child: Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddEditGalleryPage()));
            },
          )
        ],
      ),

      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by title',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (query) {
                searchGallery(query); // Perform search as user types
              },
            ),
          ),
          // Gallery grid
          Expanded(
            child: filteredGallery.isEmpty
                ? Center(child: Text('No images available'))
                : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, // Number of items per row
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1, // Make the grid square-shaped
              ),
              itemCount: filteredGallery.length,
              itemBuilder: (context, index) {
                final galleryItem = filteredGallery[index];
                return buildGalleryItem(galleryItem);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Build each gallery item for the grid layout
  Widget buildGalleryItem(GalleryModel gallery) {
    return Stack(
      children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: Image.network(
            'https://firebasestorage.googleapis.com/v0/b/sportimsweb.appspot.com/o/newsImages%2F${gallery.imgUrl}?alt=media',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        // Overlay with delete icon
        Positioned(
          top: 5,
          right: 5,
          child: GestureDetector(
            onTap: () {
              _showDeleteConfirmationDialog(gallery); // Soft delete image
            },
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
        // Title and Alt Text (Optional to show as an overlay)
        Positioned(
          bottom: 10,
          left: 10,
          child: Container(
            padding: EdgeInsets.all(5),
            color: Colors.black54,
            child: Text(
              gallery.title,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
