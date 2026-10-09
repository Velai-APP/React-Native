
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'entrepreneur_intro_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      initialData: AuthService.instance.currentUser,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState ==
                ConnectionState.waiting &&
            !authSnapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = authSnapshot.data;

        if (user == null) {
          return const LoginScreen();
        }

        return FutureBuilder<
            DocumentSnapshot<Map<String, dynamic>>>(
          key: ValueKey(user.uid),
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('businessProfile')
              .doc('profile')
              .get(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Unable to load your profile:\n'
                      '${profileSnapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }

            if (!profileSnapshot.hasData) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final profileDoc = profileSnapshot.data!;

            if (profileDoc.exists &&
                profileDoc.data() != null) {
              return DashboardScreen(
                businessProfile: profileDoc.data()!,
              );
            }

            return const EntrepreneurIntroScreen();
          },
        );
      },
    );
  }
}
