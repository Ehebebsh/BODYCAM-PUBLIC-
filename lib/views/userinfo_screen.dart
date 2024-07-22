import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import '../api/kakao_login.dart';
import '../models/usermodel.dart';
import '../view models/user_viewmodel.dart';
import '../widgets/google_and_kakao_login_widget.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final MultiSectionFormViewModel _viewModel = MultiSectionFormViewModel();
  UserModel? userModel;
  bool isLoading = true;
  late StreamSubscription<User?> _authSubscription;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    await _viewModel.initializeFirebase();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        currentUser = user;
        if (user == null) {
          userModel = null;
          isLoading = false;
        } else {
          _fetchUserData();
        }
      });
    });
  }

  Future<void> _fetchUserData() async {
    setState(() {
      isLoading = true;
    });
    try {
      UserModel? fetchedUser = await _viewModel.getUserData();
      setState(() {
        userModel = fetchedUser;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _showLoginDialog() async {
    await LoginDialogHelper.showLoginDialog(context);
    _fetchUserData(); // 로그인 후 사용자 정보를 다시 로드합니다.
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      await KakaoLogin().logout();
    } catch (e) {
      print('로그아웃 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 정보'),
        actions: [
          currentUser != null
              ? IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // 로그아웃 버튼 클릭 시 로그아웃을 수행합니다.
          )
              : IconButton(
            icon: Icon(Icons.login),
            onPressed: _showLoginDialog, // 로그인 버튼 클릭 시 로그인 다이얼로그를 표시합니다.
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userModel == null
          ? Center(child: Text('로그인을 해주세요.'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${userModel!.name}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Sex: ${userModel!.sex}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Birth: ${DateFormat('yyyy-MM-dd').format(userModel!.birth)}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Email: ${userModel!.email}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Height: ${userModel!.tall}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Weight: ${userModel!.weight}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
