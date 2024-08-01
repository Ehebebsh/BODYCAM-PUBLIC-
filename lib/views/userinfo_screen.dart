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
  bool isEditing = false;
  late StreamSubscription<User?> _authSubscription;
  User? currentUser;

  // Controllers for editing user information
  late TextEditingController _nameController;
  late TextEditingController _sexController;
  late TextEditingController _emailController;
  late TextEditingController _tallController;
  late TextEditingController _weightController;
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    _initializeUser();
    // Initialize controllers with empty values
    _nameController = TextEditingController();
    _sexController = TextEditingController();
    _emailController = TextEditingController();
    _tallController = TextEditingController();
    _weightController = TextEditingController();
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
        _updateControllers();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateControllers() {
    if (userModel != null) {
      _nameController.text = userModel!.name;
      _sexController.text = userModel!.sex;
      _emailController.text = userModel!.email;
      _tallController.text = userModel!.tall.toString();
      _weightController.text = userModel!.weight.toString();
      _birthDate = userModel!.birth;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  Future<void> _saveChanges() async {
    if (userModel == null) return;

    try {
      UserModel updatedUser = UserModel(
        name: _nameController.text,
        sex: _sexController.text,
        birth: _birthDate ?? userModel!.birth,
        email: _emailController.text,
        tall: double.tryParse(_tallController.text) ?? userModel!.tall,
        weight: double.tryParse(_weightController.text) ?? userModel!.weight,
        uid: userModel!.uid,
        platform: userModel!.platform,
      );

      await _viewModel.saveForm(
        {
          '이름': updatedUser.name,
          '성별': updatedUser.sex,
          '이메일': updatedUser.email,
          '키': updatedUser.tall,
          '몸무게': updatedUser.weight,
        },
        updatedUser.sex,
        updatedUser.birth,
      );

      setState(() {
        userModel = updatedUser;
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    DateTime initialDate = _birthDate ?? DateTime.now();
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null && selectedDate != initialDate) {
      setState(() {
        _birthDate = selectedDate;
      });
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _viewModel.dispose();
    _nameController.dispose();
    _sexController.dispose();
    _emailController.dispose();
    _tallController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text(
          '내 정보',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          currentUser != null
              ? IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          )
              : IconButton(
            icon: Icon(Icons.login, color: Colors.white),
            onPressed: _showLoginDialog,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userModel == null
              ? Center(
                  child: Text(
                    '로그인을 해주세요.',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: Colors.grey[850],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              '나의 프로필',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Divider(color: Colors.white),
                          isEditing
                              ? _buildEditForm()
                              : _buildUserInfoDisplay(),
                          SizedBox(height: 16.0),
                          // Add spacing between content and buttons
                          Row(
                            children: [
                              if (isEditing)
                                ElevatedButton(
                                  onPressed: _saveChanges,
                                  child: Text('저장'),
                                ),
                              if (!isEditing)
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isEditing = true;
                                    });
                                  },
                                  child: Text('수정'),
                                ),
                              SizedBox(
                                  width: 16.0), // Add spacing between buttons
                              if (isEditing)
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isEditing = false;
                                    });
                                  },
                                  child: Text('취소'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('이름', _nameController),
        _buildTextField('성별', _sexController),
        _buildTextField('이메일', _emailController),
        _buildTextField('키 (cm)', _tallController, isNumeric: true),
        _buildTextField('몸무게 (kg)', _weightController, isNumeric: true),
        SizedBox(height: 16.0),
        GestureDetector(
          onTap: () => _selectBirthDate(context),
          child: AbsorbPointer(
            child: TextFormField(
              controller: TextEditingController(
                text: _birthDate != null ? DateFormat('yyyy-MM-dd').format(_birthDate!) : '',
              ),
              decoration: InputDecoration(
                labelText: '생일',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.grey[800],
          border: OutlineInputBorder(),
        ),
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildUserInfoDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfoRow('이름', userModel!.name),
        _buildUserInfoRow('성별', userModel!.sex),
        _buildUserInfoRow('생일', DateFormat('yyyy-MM-dd').format(userModel!.birth)),
        _buildUserInfoRow('E-mail', userModel!.email),
        _buildUserInfoRow('키', '${userModel!.tall} cm'),
        _buildUserInfoRow('몸무게', '${userModel!.weight} kg'),
      ],
    );
  }

  Widget _buildUserInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
