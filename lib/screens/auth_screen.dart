import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
    File image,
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

      final ref = FirebaseStorage.instance
          .ref()
          .child('user-image')
          .child(userCredential.user!.uid);
      await ref.putFile(image).catchError(
            () => print('An error occurred while uploading image!'),
          );
      final userImageUrl = await ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(
            userCredential.user!.uid,
          )
          .set({
        'email': email,
        'username': username,
        'userImage': userImageUrl,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(_submitAuthForm, _isLoading),
    );
  }
}
