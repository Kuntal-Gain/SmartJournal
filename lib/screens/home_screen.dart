import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_dairy/screens/edit_entry.dart';
import 'package:personal_dairy/screens/memory_screen.dart';
import 'package:personal_dairy/screens/new_entry.dart';
import 'package:personal_dairy/services/journal_entry_adapter.dart';
import 'package:personal_dairy/services/journal_services.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'view_entry.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _imageController;
  late AnimationController _journalsController;
  late AnimationController _bottomButtonsController;

  late Animation<double> _fadeInImage;
  late Animation<Offset> _journalsOffset;
  late Animation<Offset> _bottomButtonsOffset;

  @override
  void initState() {
    super.initState();

    // Image Fade-in Controller
    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeInImage = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _imageController, curve: Curves.easeIn),
    );

    // Recent Journals Slide-in Controller
    _journalsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _journalsOffset =
        Tween<Offset>(begin: const Offset(1, 0), end: const Offset(0, 0))
            .animate(CurvedAnimation(
                parent: _journalsController, curve: Curves.easeOutBack));

    // Bottom Buttons Bounce-in Controller
    _bottomButtonsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bottomButtonsOffset =
        Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0))
            .animate(CurvedAnimation(
                parent: _bottomButtonsController, curve: Curves.bounceOut));

    // Start the animations sequentially
    Future.delayed(const Duration(milliseconds: 1000), () {
      _imageController.forward();
      Future.delayed(const Duration(milliseconds: 700),
          () => _journalsController.forward());
      Future.delayed(const Duration(milliseconds: 1200),
          () => _bottomButtonsController.forward());
    });
  }

  @override
  void dispose() {
    _imageController.dispose();
    _journalsController.dispose();
    _bottomButtonsController.dispose();
    super.dispose();
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
              // Typing Animation for Welcome Text
              Container(
                margin: EdgeInsets.only(
                    top: mq.height * 0.05, left: mq.width * 0.05),
                child: AnimatedTextKit(
                  isRepeatingAnimation: false,
                  animatedTexts: [
                    TypewriterAnimatedText(
                      "Welcome \nBack!",
                      textStyle: GoogleFonts.montserrat(
                        fontSize: 50,
                        fontWeight: FontWeight.w500,
                        color: const Color(0XFF5D3D3D),
                      ),
                      speed: const Duration(milliseconds: 100),
                    ),
                  ],
                ),
              ),
              SizedBox(height: mq.height * 0.01),

              // Fade-in Image Animation
              AnimatedBuilder(
                animation: _fadeInImage,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeInImage.value,
                    child: child,
                  );
                },
                child: Container(
                  height: mq.height * 0.2,
                  width: double.infinity,
                  margin: const EdgeInsets.all(12),
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
              ),

              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text("Recent Journals",
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0XFF5D3D3D),
                    )),
              ),

              // Right to Left Bounce-in Animation for Recent Journals
              SlideTransition(
                position: _journalsOffset,
                child: SizedBox(
                  height: mq.height * 0.2,
                  child: StreamBuilder<List<JournalEntry>>(
                    stream: JournalServices().journalStream,
                    initialData: JournalServices().fetchAllEntries(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No entries yet'));
                      }

                      final journals = snapshot.data!;

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: journals.length,
                        itemBuilder: (ctx, idx) {
                          final journal = journals[idx];
                          final date =
                              "${journal.createdAt.day}/${journal.createdAt.month}/${journal.createdAt.year}";
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ViewEntryScreen(entry: journal),
                                ),
                              );
                            },
                            onLongPress: () {},
                            child: Container(
                              height: mq.height * 0.15,
                              width: mq.width * 0.7,
                              margin: const EdgeInsets.all(12),
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Color(journal.color),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    journal.title,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0XFF5D3D3D),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text("last modified : $date",
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0XFF5D3D3D),
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          // Bounce-In Bottom Buttons
          SlideTransition(
            position: _bottomButtonsOffset,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildButton(
                    context, "New Entry", Icons.add, const NewEntryScreen()),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const MemoryScreen())),
                  child: Container(
                    height: mq.height * 0.07,
                    width: mq.width * 0.4,
                    margin: EdgeInsets.all(mq.height * 0.01),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xffc2c2c2),
                          blurRadius: 2,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 35,
                              width: 35,
                              child: Image.network(
                                'https://cdn-icons-png.flaticon.com/512/109/109827.png',
                                color: const Color(0XFF5D3D3D),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text("Remember",
                                style: GoogleFonts.montserrat(
                                    textStyle: const TextStyle(
                                  color: Color(0XFF5D3D3D),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ))),
                          ]),
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

  Widget _buildButton(
      BuildContext context, String text, IconData icon, Widget screen) {
    final mq = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Container(
        height: mq.height * 0.07,
        width: mq.width * 0.4,
        margin: EdgeInsets.all(mq.height * 0.01),
        decoration: BoxDecoration(
          color: const Color(0XFF5D3D3D),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(text,
                style: GoogleFonts.montserrat(
                    textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ))),
          ]),
        ),
      ),
    );
  }
}
