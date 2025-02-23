import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_dairy/screens/memory_screen.dart';
import 'package:personal_dairy/screens/new_entry.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Color> colors = [
    Colors.red.shade100,
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.purple.shade100,
    Colors.orange.shade100,
    Colors.yellow.shade100,
    Colors.pink.shade100,
    Colors.teal.shade100,
    Colors.indigo.shade100,
  ];

  List<String> entries = [
    "I am feeling so happy today. I had a great day at work and I am so proud of myself.",
    "I am feeling so sad today. I had a bad day at work and I am so disappointed in myself.",
  ];

  Color getColor() {
    int idx = Random().nextInt(colors.length);

    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(
                    top: mq.height * 0.05, left: mq.width * 0.05),
                child: Text(
                  "Welcome \nBack!",
                  style: GoogleFonts.montserrat(
                    fontSize: 50,
                    fontWeight: FontWeight.w500,
                    color: Color(0XFF5D3D3D),
                  ),
                ),
              ),
              SizedBox(height: mq.height * 0.01),
              Container(
                height: mq.height * 0.2,
                width: double.infinity,
                margin: EdgeInsets.all(12),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        "assets/catalog.jpg",
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black.withOpacity(0.4),
                      ),
                      width: double.infinity,
                      height: double.infinity,
                      child: Center(
                        child: Text(
                          "Reflect Yourself\nIt's time for healing",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text("Recent Journals",
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0XFF5D3D3D),
                    )),
              ),

              // recent entries
              Container(
                height: mq.height * 0.2,
                child: Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (ctx, idx) {
                      return Container(
                          height: mq.height * 0.15,
                          width: mq.width * 0.7,
                          margin: EdgeInsets.all(12),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: getColor(),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                entries[idx],
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0XFF5D3D3D),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text("1/12/2021",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0XFF5D3D3D),
                                    )),
                              )
                            ],
                          ));
                    },
                    itemCount: entries.length,
                  ),
                ),
              ),
            ],
          ),
          // New Entry

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => NewEntryScreen()));
                },
                child: Container(
                    height: mq.height * 0.08,
                    width: mq.width * 0.4,
                    margin: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0XFF5D3D3D),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 25,
                        ),
                        Text(
                          "New Entry",
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => MemoryScreen()));
                },
                child: Container(
                    height: mq.height * 0.08,
                    width: mq.width * 0.4,
                    margin: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade300,
                            offset: Offset(0, 3),
                            blurRadius: 5,
                            spreadRadius: 1)
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.network(
                          "https://cdn-icons-png.flaticon.com/512/109/109827.png",
                          height: 30,
                          color: Color(0XFF5D3D3D),
                        ),
                        Text(
                          "Remember",
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0XFF5D3D3D),
                          ),
                        ),
                      ],
                    )),
              ),
            ],
          )
          // Brain
        ],
      ),
    );
  }
}
