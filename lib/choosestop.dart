import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:projectmain/stuhomescreen.dart';

class Choosestop extends StatefulWidget {
  const Choosestop({super.key});

  @override
  State<Choosestop> createState() => _Choosestopstate();
}

class _Choosestopstate extends State<Choosestop> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drop-down Boxes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Choose Stop',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(
              255, 60, 60, 231), // Changed app bar color to violet
        ),
        body: const DropDownPage(),
      ),
    );
  }
}

class DropDownPage extends StatefulWidget {
  const DropDownPage({super.key});

  @override
  _DropDownPageState createState() => _DropDownPageState();
}

class _DropDownPageState extends State<DropDownPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> district = [];
  List<Map<String, dynamic>> place = [];
  String? selectedDistrict;
  String? selectedPlace;
  String title = '';

  Future<void> checkStdstpData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
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
        // Data exists, set the message accordingly
        setState(() {
          title = 'Stop already chosen';
        });
      }
    } catch (e) {
      print('Error checking tbl_stdstp data: $e');
    }
  }

  Future<void> fetchDistrict() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await db.collection('tbl_route').get();

      List<Map<String, dynamic>> dist = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'route': '${doc['startroute_name']} - ${doc['endroute_name']}'
                    .toString(),
              })
          .toList();
      setState(() {
        district = dist;
      });
    } catch (e) {
      print('Error fetching district data: $e');
    }
  }

  Future<void> fetchPlace(String id) async {
    try {
      selectedPlace = null;
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await db
          .collection('tbl_stop')
          .where('route_id', isEqualTo: id)
          .get();
      List<Map<String, dynamic>> plc = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'stop': doc['stop_name'].toString(),
              })
          .toList();
      setState(() {
        place = plc;
      });
    } catch (e) {
      print('Error fetching place data: $e');
    }
  }

  Future<void> submit() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('tbl_student')
        .where('stu_id', isEqualTo: userId)
        .limit(1)
        .get();
    String sid = querySnapshot.docs.first.id;

    // Check if there is data in tbl_stdstp where stu_id = sid
    QuerySnapshot<Map<String, dynamic>> stdstpSnapshot = await FirebaseFirestore
        .instance
        .collection('tbl_stdstp')
        .where('stu_id', isEqualTo: sid)
        .limit(1)
        .get();

    if (stdstpSnapshot.docs.isNotEmpty) {
      // Show prompt box if data exists in tbl_stdstp
      bool changeStop = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('You have already chosen a stop.'),
            content: Text('Do you want to change it?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Return true for change
                },
                child: Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(),
                      ));
                  // Return false for no change
                },
                child: Text('No'),
              ),
            ],
          );
        },
      );

      if (changeStop) {
        // Update the status of the data to 1 in tbl_stdstp
        await FirebaseFirestore.instance
            .collection('tbl_stdstp')
            .doc(stdstpSnapshot.docs.first.id)
            .update({
          'stdstp_status': 1,
          'stop_id': selectedPlace,
        });

        Fluttertoast.showToast(
          msg: 'Stop changed successfully!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ));
      }
    } else {
      // Insert into tbl_stdstp if no data exists
      await FirebaseFirestore.instance.collection('tbl_stdstp').add({
        'assign_id': '',
        'noti_status': 0,
        'stdstp_status': 0,
        'stop_id': selectedPlace,
        'stu_id': sid,
      });

      Fluttertoast.showToast(
        msg: 'Stop chosen successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDistrict();
    checkStdstpData();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        height: 330,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Route',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(title),
            SizedBox(
              height: 10,
            ),
            DropdownButtonFormField<String>(
              value: selectedDistrict,
              decoration: InputDecoration(
                labelText: 'Route',
                hintText: 'Select Route',
                hintStyle: const TextStyle(color: Colors.black26),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black12),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedDistrict = newValue;
                  fetchPlace(newValue!);
                });
              },
              items: district.map<DropdownMenuItem<String>>(
                (Map<String, dynamic> dist) {
                  return DropdownMenuItem<String>(
                    value: dist['id'],
                    child: Text(dist['route']),
                  );
                },
              ).toList(),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedPlace,
              decoration: InputDecoration(
                labelText: 'Stop',
                hintText: 'Select Stop',
                hintStyle: const TextStyle(color: Colors.black26),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black12),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedPlace = newValue;
                });
              },
              items: place.map<DropdownMenuItem<String>>(
                (Map<String, dynamic> place) {
                  return DropdownMenuItem<String>(
                    value: place['id'],
                    child: Text(place['stop']),
                  );
                },
              ).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle submit button press
                    submit();
                  },
                  child: const Text('Submit'),
                ),
                const SizedBox(width: 25),
                ElevatedButton(
                  onPressed: () {
                    // Handle cancel button press
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
