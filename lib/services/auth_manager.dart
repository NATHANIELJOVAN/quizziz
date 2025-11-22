import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthManager {

  Future<Map<String, String?>> login(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user == null) {
        return {'username': null, 'role': null, 'email': null};
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        return {
          'username': data['name'] ?? 'Tanpa Nama',
          'role': data['role'] ?? 'student',
          'email': email,
        };
      } else {
        print("User login sukses, tapi data role tidak ditemukan di Firestore. Menggunakan default.");
        return {
          'username': email.split('@')[0],
          'role': 'student',
          'email': email
        };
      }

    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error: ${e.code} - ${e.message}");
      return {'username': null, 'role': null, 'email': null};
    } catch (e) {
      print("General Error: $e");
      return {'username': null, 'role': null, 'email': null};
    }
  }
}