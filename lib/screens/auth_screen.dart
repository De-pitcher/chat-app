import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import '../widgets/auth/auth_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  Future<void> _submitAuthForm(
    String email,
    String username,
    String password,
    bool isLogin,
    BuildContext ctx,
  ) async {
    UserCredential userCredential;

    final scaffold = ScaffoldMessenger.of(ctx);
    SnackBar snackbar(String msg) => SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
        );
    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(
            userCredential.user!.uid,
          )
          .set({
        'email': email,
        'username': username,
      });
    } on PlatformException catch (error) {
      setState(() {
        _isLoading = false;
      });
      var errorMessage =
          error.message ?? 'An error occurred, please check your credientials';

      scaffold.showSnackBar(
        snackbar(errorMessage),
      );
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print(error);

      scaffold.showSnackBar(snackbar(error.toString()));
    }
    // setState(() {
    //   _isLoading = false;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(_submitAuthForm, _isLoading),
    );
  }
}
