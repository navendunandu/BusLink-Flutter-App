import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class QRResult extends StatefulWidget {
  final Map<String, dynamic> qrData;
  const QRResult({Key? key, required this.qrData});

  @override
  State<QRResult> createState() => _QRResultState();
}

class _QRResultState extends State<QRResult> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  DateTime now = DateTime.now();
  bool isLoading = false;
  bool attendanceRegistered = false;
  late ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    loadData();
    _progressDialog = ProgressDialog(context);
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      print(userId);
      QuerySnapshot<Map<String, dynamic>> studSnapshot = await FirebaseFirestore
          .instance
          .collection('tbl_student')
          .where('stu_id', isEqualTo: userId)
          .limit(1)
          .get();
      if (studSnapshot.docs.isNotEmpty) {
        String sid = studSnapshot.docs.first.id;
        String formattedDate = "${now.year}-${now.month}-${now.day}";
        QuerySnapshot querySnapshot = await db
            .collection('tbl_attendance')
            .where('stu_id', isEqualTo: sid)
            .where('att_date', isEqualTo: formattedDate)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            attendanceRegistered = true;
          });
        } else {
          setState(() {
            attendanceRegistered = false;
          });
        }
      } else {
        print('No student data found for the current user');
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> register() async {
    _progressDialog.show();

    setState(() {
      isLoading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('tbl_student')
              .where('stu_id', isEqualTo: userId)
              .limit(1)
              .get();
      if (querySnapshot.docs.isNotEmpty) {
        String sid = querySnapshot.docs.first.id;
        String formattedDate = "${now.year}-${now.month}-${now.day}";
        final data = <String, dynamic>{
          'stu_id': sid,
          'att_date': formattedDate,
          'assign_id': widget.qrData['id'],
        };
        await db
            .collection('tbl_attendance')
            .add(data)
            .then((DocumentReference doc) => Fluttertoast.showToast(
                  msg: 'Attendance Registered',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                ));
        _progressDialog.hide();

        Navigator.pop(context);
      } else {
        print('No student data found for the current user');
      }
    } catch (e) {
      _progressDialog.hide();

      print(e);
      Fluttertoast.showToast(
        msg: 'Failed',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Data'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator() // Show loader while loading
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Click Button to mark your attendance'),
                  attendanceRegistered
                      ? const Text(
                          'Today\'s attendance already registered',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            register();
                          },
                          child: const Text('Register Attendance'),
                        ),
                  // Add more fields as needed
                ],
              ),
      ),
    );
  }
}
