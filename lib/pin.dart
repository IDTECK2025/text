import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:text/main.dart'; // Change if your main controller file has a different path

class PinVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const PinVerificationScreen({Key? key, required this.phoneNumber})
      : super(key: key);

  @override
  _PinVerificationScreenState createState() => _PinVerificationScreenState();
}

class _PinVerificationScreenState extends State<PinVerificationScreen> {
  String pin = '';
  bool _isLoading = false;
  final secureStorage = FlutterSecureStorage();

  void _onKeyboardTap(String value) {
    if (pin.length < 4) {
      setState(() {
        pin += value;
      });
    }

    if (pin.length == 4) {
      _verifyPinAndLogin();
    }
  }

  void _onBackspace() {
    if (pin.isNotEmpty) {
      setState(() {
        pin = pin.substring(0, pin.length - 1);
      });
    }
  }

  Future<void> _verifyPinAndLogin() async {
    setState(() => _isLoading = true);

    final url = Uri.parse('http://localhost:2025/alllogin');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contactNumber": widget.phoneNumber,
          "pin": pin,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check for missing or invalid user data
        if (data['user'] == null || data['token'] == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Account not found or incomplete data')),
          );
          setState(() {
            pin = '';
            _isLoading = false;
          });
          return;
        }

        // Save data locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('login_response', jsonEncode(data));
        await prefs.setString('token', data['token']);
        await prefs.setString('user', jsonEncode(data['user']));
        await secureStorage.write(key: 'pin', value: pin);

        // Navigate to Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavController()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid PIN or Phone number')),
        );
        setState(() => pin = '');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong. Please try again.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        bool filled = index < pin.length;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: filled ? Colors.white : Colors.transparent,
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }

  Widget _buildKeyboard() {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '←'];
    return GridView.builder(
      shrinkWrap: true,
      itemCount: keys.length,
      padding: EdgeInsets.symmetric(horizontal: 32),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final key = keys[index];
        if (key.isEmpty) return SizedBox();
        return ElevatedButton(
          onPressed: key == '←' ? _onBackspace : () => _onKeyboardTap(key),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white10,
            shape: CircleBorder(),
          ),
          child: Text(
            key,
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 29, 28, 28),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 9, 9, 9),
                Color.fromARGB(255, 51, 51, 52),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: height * 0.1),
              Text(
                'PIN VERIFICATION',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 32),
              Text('Enter your PIN', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 20),
              _buildPinDots(),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Handle forgot PIN action here
                },
                child: Text(
                  'Forgot PIN',
                  style: TextStyle(color: Colors.white60),
                ),
              ),
              Spacer(),
              _isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.white))
                  : _buildKeyboard(),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
