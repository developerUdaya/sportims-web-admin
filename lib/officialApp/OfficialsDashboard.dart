import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:sport_ims/Districtinmaster.dart';
import 'package:sport_ims/Eventraceinmaster.dart';
import 'package:sport_ims/Stateinmaster.dart';
import 'package:sport_ims/main.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RightSide(),
    );
  }
}


class RightSide extends StatefulWidget {
  @override
  State<RightSide> createState() => _RightSideState();
}

class _RightSideState extends State<RightSide> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Dashboard"),
          backgroundColor: Color(0xffb0ccf8),
        ),
        body: Center(
          child: Container(
            color: Color(0xffcbdcf7),
            padding: EdgeInsets.all(20), // Add padding for spacing
            child: Row( // Use Row instead of Column
              mainAxisAlignment: MainAxisAlignment.spaceAround, // Adjust spacing between charts
              children: [
                // Expanded(flex: 1,
                // child: Container(),
                // ),
                // Expanded(
                //   flex: 2,
                //   child: PieChart(
                //     dataMap: {
                //       'A': 25,
                //       'B': 35,
                //       'C': 20,
                //       'D': 20,
                //     },
                //     animationDuration: Duration(milliseconds: 800),
                //     chartLegendSpacing: 32,
                //     chartRadius: MediaQuery.of(context).size.width / 4,
                //     initialAngleInDegree: 0,
                //     chartType: ChartType.disc,
                //     ringStrokeWidth: 32,
                //     centerText: "Pie Chart",
                //     legendOptions: LegendOptions(
                //       showLegendsInRow: false,
                //       legendPosition: LegendPosition.bottom,
                //       showLegends: true,
                //       legendShape: BoxShape.circle,
                //       legendTextStyle: TextStyle(fontSize: 14),
                //     ),
                //     chartValuesOptions: ChartValuesOptions(
                //       showChartValueBackground: true,
                //       showChartValues: true,
                //       showChartValuesInPercentage: true,
                //       showChartValuesOutside: false,
                //     ),
                //   ),
                // ),
                // Expanded(flex: 1,
                //   child: Container(),
                // ),
                // Expanded(
                //   flex: 2,
                //   child: PieChart(
                //     dataMap: {
                //       'A': 25,
                //       'B': 35,
                //       'C': 20,
                //       'D': 20,
                //     },
                //     animationDuration: Duration(milliseconds: 800),
                //     chartLegendSpacing: 32,
                //     chartRadius: MediaQuery.of(context).size.width / 4,
                //     initialAngleInDegree: 0,
                //     chartType: ChartType.disc,
                //     ringStrokeWidth: 32,
                //     centerText: "Pie Chart",
                //     legendOptions: LegendOptions(
                //       showLegendsInRow: false,
                //       legendPosition: LegendPosition.bottom,
                //       showLegends: true,
                //       legendShape: BoxShape.circle,
                //       legendTextStyle: TextStyle(fontSize: 14),
                //     ),
                //     chartValuesOptions: ChartValuesOptions(
                //       showChartValueBackground: true,
                //       showChartValues: true,
                //       showChartValuesInPercentage: true,
                //       showChartValuesOutside: false,
                //     ),
                //   ),
                // ),
                Expanded(flex: 1,
                  child: Container(),
                ),
                Expanded(
                  flex: 2,
                  child: PieChart(
                    dataMap: {
                      'Total': 25,
                      'Verified': 15,
                      'Pending': 20,
                    },
                    animationDuration: Duration(milliseconds: 800),
                    chartLegendSpacing: 32,
                    chartRadius: MediaQuery.of(context).size.width / 4,
                    initialAngleInDegree: 0,
                    chartType: ChartType.ring,
                    ringStrokeWidth: 32,
                    centerText: "Clubs",
                    legendOptions: LegendOptions(
                      showLegendsInRow: false,
                      legendPosition: LegendPosition.bottom,
                      showLegends: true,
                      legendShape: BoxShape.rectangle,
                      legendTextStyle: TextStyle(fontSize: 14),
                    ),
                    chartValuesOptions: ChartValuesOptions(
                      showChartValueBackground: true,
                      showChartValues: true,
                      showChartValuesInPercentage: false,
                      showChartValuesOutside: true,
                      decimalPlaces: 0, // Set decimal places to 0 to display integers
                    ),
                  ),
                ),
                Expanded(flex: 1,
                  child: Container(),
                ),
                Expanded(flex: 1,
                  child: Container(),
                ),
                Expanded(
                  flex: 2,
                  child: PieChart(
                    dataMap: {

                      'Total': 5,
                      'Verified': 5,
                      'Pending': 0,
                    },
                    animationDuration: Duration(milliseconds: 800),
                    chartLegendSpacing: 32,
                    chartRadius: MediaQuery.of(context).size.width / 4,
                    initialAngleInDegree: 0,
                    chartType: ChartType.ring,
                    ringStrokeWidth: 32,
                    centerText: "Skaters",
                    legendOptions: LegendOptions(
                      showLegendsInRow: false,
                      legendPosition: LegendPosition.bottom,
                      showLegends: true,
                      legendShape: BoxShape.rectangle,
                      legendTextStyle: TextStyle(fontSize: 14),
                    ),
                    chartValuesOptions: ChartValuesOptions(
                      showChartValueBackground: true,
                      showChartValues: true,
                      showChartValuesInPercentage: false,
                      showChartValuesOutside: true,
                      decimalPlaces: 0, // Set decimal places to 0 to display integers
                    ),
                  ),
                ),
                Expanded(flex: 1,
                  child: Container(),
                ),
                Expanded(flex: 1,
                  child: Container(),
                ),
                Expanded(
                  flex: 2,
                  child: PieChart(
                    dataMap: {

                      'Total': 25,
                      'Verified': 15,
                      'Pending': 20,
                    },
                    animationDuration: Duration(milliseconds: 800),
                    chartLegendSpacing: 32,
                    chartRadius: MediaQuery.of(context).size.width / 4,
                    initialAngleInDegree: 0,
                    chartType: ChartType.ring,
                    ringStrokeWidth: 32,
                    centerText: "Events",
                    legendOptions: LegendOptions(
                      showLegendsInRow: false,
                      legendPosition: LegendPosition.bottom,
                      showLegends: true,
                      legendShape: BoxShape.rectangle,
                      legendTextStyle: TextStyle(fontSize: 14),
                    ),
                    chartValuesOptions: ChartValuesOptions(
                      showChartValueBackground: true,
                      showChartValues: true,
                      showChartValuesInPercentage: false,
                      showChartValuesOutside: true,
                      decimalPlaces: 0, // Set decimal places to 0 to display integers
                    ),
                  ),
                ),
                Expanded(flex: 1,
                  child: Container(),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}