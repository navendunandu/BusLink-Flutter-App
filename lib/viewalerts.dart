import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import the intl package

class Viewalerts extends StatefulWidget {
  const Viewalerts({super.key});

  @override
  State<Viewalerts> createState() => _Viewalertstate();
}

class _Viewalertstate extends State<Viewalerts> {
  List<Map<String, dynamic>> alerts = [];

  @override
  void initState() {
    super.initState();
    fetchAlerts();
  }

  Future<void> fetchAlerts() async {
    try {
      print('started');
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('tbl_student')
              .where('stu_id', isEqualTo: userId)
              .limit(1)
              .get();
      if (querySnapshot.docs.isNotEmpty) {
      print('user');
        String sid = querySnapshot.docs.first.id;
        QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
            .instance
            .collection('tbl_stdstp')
            .where('stu_id', isEqualTo: sid)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
      print('stop');
          String stopId = snapshot.docs.first['stop_id'];
          DocumentSnapshot<Map<String, dynamic>> snapshot1 =
              await FirebaseFirestore.instance
                  .collection('tbl_stop')
                  .doc(stopId)
                  .get();

          if (snapshot1.exists) {
      print('route');
            String routeId = snapshot1.data()?['route_id'];
            QuerySnapshot<Map<String, dynamic>> snapshot =
                await FirebaseFirestore.instance
                    .collection('tbl_alerts')
                    .where('route_id', isEqualTo: routeId)
                    .get();

            if (snapshot.docs.isNotEmpty) {
      print('alert');
              List<Map<String, dynamic>> alertsList = [];
              for (QueryDocumentSnapshot<Map<String, dynamic>> doc
                  in snapshot.docs) {
                Map<String, dynamic> alertData = doc.data();
                // Convert Timestamp to String and format it
                String alertDatetime = (DateFormat('dd/MM/yyyy').format(
                        (alertData['alert_datetime'] as Timestamp).toDate()))
                    .toString();
                alertData['alert_datetime'] = alertDatetime;
                alertsList.add(alertData);
                print('Alerts: $alertsList');
              }
              setState(() {
                alerts = alertsList;
              });
            }
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Alerts',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 60, 60, 231),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              alerts[index]['alert_detail'] ?? '',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              alerts[index]['alert_datetime'] ?? '',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          );
        },
      ),
    );
  }
}
