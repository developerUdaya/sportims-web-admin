import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EventCard extends StatelessWidget {
  final String eventName;
  final String location;
  final String eventDate;
  final String chestNumber;
  final String raceDetails;
  final String imgUrl;
  final String eventId;
  final String skaterID;

  EventCard({
    required this.eventName,
    required this.location,
    required this.eventDate,
    required this.chestNumber,
    required this.raceDetails,
    required this.imgUrl,
    required this.eventId,
    required this.skaterID
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Right Section with Event Details
          Positioned(
            left: 150,
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Location: $location',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  Text(
                    'Event Date: $eventDate',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Chest No: $chestNumber',
                    style: TextStyle(fontSize: 14, color: Colors.blue[900]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Race Details: $raceDetails',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () {
                        // Add your functionality for viewing the certificate

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('View Certificate', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Left Section with Wavy Background and Profile Image
          Container(
            width: 150,
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
              gradient: LinearGradient(
                colors: [Color(0xFFDD5E89), Color(0xFFF7BB97)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 50,
                  left: 25,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(imgUrl),
                  ),
                ),
                // Decorative Waves
                Positioned(
                  top: 0,
                  left: 100,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipPath(
                      clipper: WavyClipper(),
                      child: Container(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WavyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.75, size.width * 0.5, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
