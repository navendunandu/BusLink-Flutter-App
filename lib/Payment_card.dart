import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'paymentpage.dart';

class Paymentcard extends StatefulWidget {
  const Paymentcard({super.key});

  @override
  State<Paymentcard> createState() => _PayScreenState();
}

class _PayScreenState extends State<Paymentcard> {
  late List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    fetchPayments();
    fetchRoute();
  }

  String routeAmt = '0';

  Future<void> fetchRoute() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      List<Map<String, dynamic>> PayList = [];
      if (userId == null) {
        print('User ID is null');
        return;
      }

      String sid = '';
      String route = ''; // Assuming route is a variable in your context

      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('tbl_student')
              .where('stu_id', isEqualTo: userId)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        sid = querySnapshot.docs.first.id;
        QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
            .instance
            .collection('tbl_stdstp')
            .where('stu_id', isEqualTo: sid)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          String stopId = snapshot.docs.first['stop_id'];

          DocumentSnapshot<Map<String, dynamic>> snapshot1 =
              await FirebaseFirestore.instance
                  .collection('tbl_stop')
                  .doc(stopId)
                  .get();

          if (snapshot1.exists) {
            String routeId = snapshot1.data()?['route_id'];
            String stopNo = snapshot1.data()?['stop_no'];

            DocumentSnapshot<Map<String, dynamic>> routeSnapshot =
                await FirebaseFirestore.instance
                    .collection('tbl_route')
                    .doc(routeId)
                    .get();

            if (routeSnapshot.exists) {
              String routeRate = routeSnapshot.data()?['route_rate'];

              int routerate = int.tryParse(routeRate) ?? 0;
              int stopNumber =
                  int.tryParse(stopNo) ?? 0; // Convert stopNo to an integer
              if (stopNumber >= 5) {
                num result = ((stopNumber) - 5) * 100 + routerate;
                route = result.toString();
              } else {
                route = routeRate
                    .toString(); // Set route to routeRate if stopNumber is less than 5
              }
              print("Rate: $route");
              setState(() {
                routeAmt = route;
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching route data: $e');
    }
  }

  void fetchPayments() async {
    List<Map<String, dynamic>> contextList = [];
    int currentMonth = DateTime.now().month;
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    List<String> months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];

    FirebaseFirestore db = FirebaseFirestore.instance;
    String sid = '';

    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('tbl_student')
        .where('stu_id', isEqualTo: userId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      sid = querySnapshot.docs.first
          .id; // Assuming 'id' is the field that contains the user's ID
    }

    for (String month in months) {
      QuerySnapshot paymentsRef = await db
          .collection("tbl_payment")
          .where("stu_id", isEqualTo: sid)
          .where("pay_month", isEqualTo: month)
          .get();

      int status; // Changed the type to int here
      if (paymentsRef.docs.isNotEmpty) {
        status = 1; // Using integers directly
      } else {
        status = 0;
      }

      if (months.indexOf(month) + 1 > currentMonth) {
        status = 2;
      }

      contextList.add(
          {"month": month, "status": status, "current_month": currentMonth});
    }

    setState(() {
      data = contextList;
    });
    print(contextList);
  }

  String getStatusText(int status) {
    switch (status) {
      case 1:
        return 'Paid';
      case 2:
        return 'Upcoming';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentYear = DateTime.now().year;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 60, 231),
        title: const Text(
          'Payment Card',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                Text(
                  'Payment Card - $currentYear',
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold),
                ),
                Text("Route Amount: $routeAmt"),
                DataTable(
                  columns: const [
                    DataColumn(
                      label: Text(
                        'SL.No',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Month',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Status',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: List<DataRow>.generate(
                    data.length,
                    (index) => DataRow(
                      cells: [
                        DataCell(Text((index + 1).toString())),
                        DataCell(Text(data[index]['month'])),
                        DataCell(
                          data[index]['status'] == 0
                              ? ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PaymentPage(
                                            month: data[index]['month'],
                                            rate: routeAmt),
                                      ),
                                    );
                                  },
                                  child: const Text('Pay'),
                                )
                              : Text(
                                  getStatusText(data[index][
                                      'status']), // Empty cell if status is not 0
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
