import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'qr_scanner.dart';
import 'choosestop.dart';
import 'Payment_card.dart';
import 'Myprofile.dart';
import 'viewalerts.dart';

// import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String name = 'Loading...';
  String mail = 'Loading...';
  String profile = 'assets/profile.png';
  String formattedDate = '';
  String dayOfWeek = '';
  String currentTime = '';
  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      //   DateTime now = DateTime.now();
      //   formattedDate = "${now.year}-${now.month}-${now.day}";
      //   String dayOfWeek = DateFormat('EEEE').format(now);
      // String currentTime = "${now.hour}:${now.minute}:${now.second}";
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('tbl_student')
              .where('stu_id', isEqualTo: userId)
              .limit(1)
              .get();
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          name = querySnapshot.docs.first['stu_name'];
          mail = querySnapshot.docs.first['stu_mail'];
          profile = querySnapshot.docs.first['stu_img'];
        });
      } else {
        setState(() {
          name = 'Error Loading Data';
          mail = 'Error Loading Data';
          profile = 'assets/profile.png';
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> gotoPaymentCard() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('tbl_student')
            .where('stu_id', isEqualTo: userId)
            .limit(1)
            .get();
    String sid = querySnapshot.docs.first.id;

    QuerySnapshot<Map<String, dynamic>> stdstpSnapshot =
        await FirebaseFirestore.instance
            .collection('tbl_stdstp')
            .where('stu_id', isEqualTo: sid)
            .limit(1)
            .get();
    
    if (stdstpSnapshot.docs.isNotEmpty) {
      // Navigate to the next page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Paymentcard()),
      );
    } else {
      // Show Flutter toast message
      Fluttertoast.showToast(
        msg: "Stop not chosen",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  } catch (e) {
    // Handle any errors
    print('Error: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home Screen',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 60, 60, 231),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Viewalerts(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            color: Colors.white,
            iconSize: 40,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyProfile(),
                  ));
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(name),
              accountEmail: Text(mail),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 27, 24, 187),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage('assets/dummy.jpg'),
              ),
            ),
            ListTile(
              title: const Text('View Attendance'),
              onTap: () {
                // Handle menu item 1 tap
              },
            ),
            ListTile(
              title: const Text('Payment Card'),
              onTap: () {
                // Handle menu item 2 tap
              },
            ),
            // Add more list tiles for additional menu items
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: const Color.fromARGB(255, 60, 60, 231),
          ),
          ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                height: 100,
                child: Text(dayOfWeek),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50.0),
                    topRight: Radius.circular(50.0),
                  ),
                ),
                height: 550,
                width: double.infinity,
                padding: const EdgeInsets.only(top: 40, bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const QRScanner()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.square(120),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/assign.png', // Replace 'your_image.png' with your image path
                                width: 64, // Adjust the width as needed
                                height: 64, // Adjust the height as needed
                              ),
                              const SizedBox(
                                  height:
                                      8), // Add some space between image and text
                              const Text(
                                'Attendance',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Choosestop()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.square(120),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/decision.png', // Replace 'your_image.png' with your image path
                                width: 64, // Adjust the width as needed
                                height: 64, // Adjust the height as needed
                              ),
                              const SizedBox(
                                  height:
                                      8), // Add some space between image and text
                              const Text(
                                'Choose Stop',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            gotoPaymentCard();
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) => const Paymentcard()),
                            // );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.square(120),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/cashless-payment.png', // Replace 'your_image.png' with your image path
                                width: 64, // Adjust the width as needed
                                height: 64, // Adjust the height as needed
                              ),
                              const SizedBox(
                                  height:
                                      8), // Add some space between image and text
                              const Text(
                                'Payment Card',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Viewalerts()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.square(120),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/alert.png', // Replace 'your_image.png' with your image path
                                width: 64, // Adjust the width as needed
                                height: 64, // Adjust the height as needed
                              ),
                              const SizedBox(
                                  height:
                                      8), // Add some space between image and text
                              const Text(
                                'View Alerts',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: HomeScreen(),
  ));
}
