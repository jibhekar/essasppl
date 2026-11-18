import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());
final authStateProvider = StreamProvider<User?>((ref) =>
    ref.watch(authRepositoryProvider).authStateChanges);

class AuthRepository {
  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;
  final FirebaseAuth _auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
  }

  Future<void> createAccount(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
  }

  Future<void> signOut() => _auth.signOut();
}
