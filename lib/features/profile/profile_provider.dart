import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final employeeProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return {};
  final snapshot = await FirebaseFirestore.instance.collection('employees').doc(user.uid).get();
  return snapshot.data() ?? {'name': user.displayName ?? user.email?.split('@').first ?? 'Employee', 'email': user.email ?? ''};
});
