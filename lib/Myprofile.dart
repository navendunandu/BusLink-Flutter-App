import 'changepassword.dart';
import 'editprofile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  @override
  void initState() {
    super.initState();
    loadData();
  }

  String name = 'Loading...';
  String email = 'Loading...';
  String contact = 'Loading...';
  String address = 'Loading...';
  String image = '';

  Future<void> loadData() async {
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
        final doc = querySnapshot.docs.first;
        setState(() {
          name = doc['stu_name'] ?? 'Error Loading Data';
          email = doc['stu_mail'] ?? 'Error Loading Data';
          contact = doc['stucon'] ?? 'Error Loading Data';
          address = doc['stu_city'] ?? 'Error Loading Data';
          image = doc['stu_img'];
        });
      } else {
        setState(() {
          name = 'Error Loading Data';
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          width: 500,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: ListView(
            children: [
              CircleAvatar(
                radius: 75,
                backgroundColor: const Color(0xff4c505b),
                backgroundImage: image.isNotEmpty
                    ? NetworkImage(image) as ImageProvider
                    : const AssetImage('assets/dummy.jpg'),
              ),
              const SizedBox(
                height: 50,
              ),
              const Text(
                'My Profile',
                style: TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Text('Name: $name'),
              const SizedBox(
                height: 20,
              ),
              Text('Email: $email'),
              const SizedBox(
                height: 20,
              ),
              Text('Contact: $contact'),
              const SizedBox(
                height: 20,
              ),
              Text('Address: $address'),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: gotoEditProfile,
                child: const Text('Edit Profile'),
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: gotoChangePassword,
                child: const Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void gotoEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Editprofile(),
      ),
    );
  }

  void gotoChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChangePassword(),
      ),
    );
  }
}
