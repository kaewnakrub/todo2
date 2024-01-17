import 'dart:developer';

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo2/const.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      providers: [
        EmailAuthProvider(),
      ],
      actions: [
        AuthStateChangeAction<SignedIn>((context, state) {
          log(state.user!.email.toString());

          final userId = state.user!.uid.toString();
          final emailAdress = state.user!.email.toString();
          final timeStamp = DateTime.now().millisecondsSinceEpoch;

          // check document id in users colloection
          firestore.collection('users').doc(userId).get().then((value) {
            if (value.exists) {
              log('has user data');
            } else {
              log('add new user data');
              firestore.collection('users').doc(userId).set({
                'userId': userId,
                'emailAddress': emailAdress,
                'createAt': timeStamp,
              });
            }
          });
        })
      ],
    );
  }
}
