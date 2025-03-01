import 'package:flutter/material.dart';
import 'dart:html' as html;

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return  Container(
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black26,blurRadius: 2,spreadRadius: .5),
        ]

      ),
      padding: const EdgeInsets.only(right: 24.0,top: 5),
      child: Row(
        children: [
          Expanded(child: Container()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem('HOME', "/index2.html"),
              _buildNavItem('ABOUT US', "about.html"),
              _buildNavItem('LATEST NEWS', "news.html"),
              _buildNavItem('LOGIN', "",color: Colors.blue,textColor: Colors.white),
            ],
          ),
        ],
      ),
    );
  }


  void navigateToWebsite(String url) {
    html.window.location.href = url;
  }


  Widget _buildNavItem(String text,String url,{Color color=Colors.white, Color textColor = const Color(0xFF444444)}) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: ()=>navigateToWebsite(url),
        child: Container(

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color,

          ),
          child: Text(text,style: TextStyle(color: textColor,fontSize: 18),),
          padding: EdgeInsets.symmetric(vertical: 12,horizontal: 20),
        ),
      ),
    );
  }
}
