import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:signature/signature.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui' as ui;

class RegistrationFlow extends StatefulWidget {
  @override
  _RegistrationFlowState createState() => _RegistrationFlowState();
}

class _RegistrationFlowState extends State<RegistrationFlow> {
  int currentPage = 1;
  final PageController _pageController = PageController();
  bool isLoading = false;

  // Form data
  String firstName = '';
  String lastName = '';
  String day = '';
  String month = '';
  String year = '';
  String country = '';
  String city = '';
  String adharNumber = '';
  String panNumber = '';
  String address1 = '';
  String address2 = '';
  String selectedDate = '';
  String email = '';
  String password = '';
  String confirmPassword = '';

  // Signature data
  SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  Uint8List? _webSignatureImage;
  File? _signatureImage;
  bool _hasSignature = false;

  // Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dayController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController adharController = TextEditingController();
  final TextEditingController panController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmEmailController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Add listeners to update state
    firstNameController.addListener(
      () => setState(() => firstName = firstNameController.text),
    );
    lastNameController.addListener(
      () => setState(() => lastName = lastNameController.text),
    );
    dayController.addListener(() => setState(() => day = dayController.text));
    monthController.addListener(
      () => setState(() => month = monthController.text),
    );
    yearController.addListener(
      () => setState(() => year = yearController.text),
    );
    cityController.addListener(
      () => setState(() => city = cityController.text),
    );
    adharController.addListener(
      () => setState(() => adharNumber = adharController.text),
    );
    panController.addListener(
      () => setState(() => panNumber = panController.text),
    );
    address1Controller.addListener(
      () => setState(() => address1 = address1Controller.text),
    );
    address2Controller.addListener(
      () => setState(() => address2 = address2Controller.text),
    );
    emailController.addListener(
      () => setState(() => email = emailController.text),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();
    cityController.dispose();
    adharController.dispose();
    panController.dispose();
    address1Controller.dispose();
    address2Controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _pageController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  bool canContinue() {
    switch (currentPage) {
      case 1:
        return firstName.trim().isNotEmpty && lastName.trim().isNotEmpty;
      case 2:
        return day.isNotEmpty && month.isNotEmpty && year.isNotEmpty;
      case 3:
        return country.isNotEmpty && city.trim().isNotEmpty;
      case 4:
        return adharNumber.trim().isNotEmpty && panNumber.trim().isNotEmpty;
      case 5:
        return address1.trim().isNotEmpty && address2.trim().isNotEmpty;
      case 6:
        return selectedDate.isNotEmpty;
      case 7:
        return email.trim().isNotEmpty;
      case 8:
        return _hasSignature;
      default:
        return false;
    }
  }

  void handleContinue() {
    if (currentPage < 8) {
      setState(() => currentPage++);
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Submit form on last page
      submitRegistration();
    }
  }

  Future<void> _saveSignature() async {
    if (_signatureController.isNotEmpty) {
      try {
        if (kIsWeb) {
          // For web platform
          final signature = await _signatureController.toPngBytes();
          if (signature != null) {
            setState(() {
              _webSignatureImage = signature;
              _hasSignature = true;
            });
          }
        } else {
          // For mobile platform
          final signature = await _signatureController.toPngBytes();
          if (signature != null) {
            // Save to temporary file
            final tempDir = Directory.systemTemp;
            final file =
                await File(
                  '${tempDir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png',
                ).create();
            await file.writeAsBytes(signature);
            setState(() {
              _signatureImage = file;
              _hasSignature = true;
            });
          }
        }
      } catch (e) {
        print('Error saving signature: $e');
        _showErrorDialog('Failed to save signature. Please try again.');
      }
    }
  }

  Future<void> _uploadSignatureFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _webSignatureImage = bytes;
            _hasSignature = true;
          });
        } else {
          setState(() {
            _signatureImage = File(image.path);
            _hasSignature = true;
          });
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      _showErrorDialog('Failed to pick image. Please try again.');
    }
  }

  void _clearSignature() {
    _signatureController.clear();
    setState(() {
      _webSignatureImage = null;
      _signatureImage = null;
      _hasSignature = false;
    });
  }

  Future<void> submitRegistration() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final userDataString = prefs.getString('user');

      if (token.isEmpty || userDataString == null) {
        throw Exception(
          'Authentication token or user data not found. Please log in again.',
        );
      }
      final userData = json.decode(userDataString);
      final id = userData['id'];
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:2025/createProfile'),
      );

      // Add form fields
      request.fields['name'] = firstName;
      request.fields['profileType'] = "customer";

      request.fields['lastName'] = lastName;
      request.fields['dob'] = '$year-$month-$day';
      request.fields['country'] = "india";
      request.fields['state'] = "kerala";
      request.fields['district'] = "malappuram";
      request.fields['createdBy'] = id;

      request.fields['schemeAmount'] = country;

      request.fields['contactNumber'] = city;
      request.fields['adharNumber'] = adharNumber;
      request.fields['panNumber'] = panNumber;
      request.fields['address'] = address1;
      request.fields['address'] = address2;
      request.fields['email'] = email;
      request.fields['schemeDate'] = selectedDate;
      request.headers['Authorization'] = 'Bearer $token';

      //      request.fields['password'] = password;

      // Add signature file
      if (kIsWeb && _webSignatureImage != null) {
        // For web
        final fileName =
            'signature_${DateTime.now().millisecondsSinceEpoch}.png';
        request.files.add(
          http.MultipartFile.fromBytes(
            'signature',
            _webSignatureImage!,
            filename: fileName,
          ),
        );
      } else if (_signatureImage != null) {
        // For mobile
        request.files.add(
          await http.MultipartFile.fromPath('signature', _signatureImage!.path),
        );
      }

      // Send request
      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Registration successful
        _showSuccessDialog();
      } else {
        // Registration failed
        _showErrorDialog('Registration failed. Please try again.');
      }
    } catch (e) {
      // Network error
      _showErrorDialog(
        'Network error. Please check your connection and try again.',
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text('Registration Successful!'),
            content: Text(
              'Your registration has been submitted successfully. You will receive a confirmation email shortly.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Return to previous screen
                },
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            // title: Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  List<String> getAvailableDates() {
    DateTime now = DateTime.now();
    int currentDay = now.day;
    int currentMonth = now.month;
    int currentYear = now.year;

    List<String> dates = [];

    if (currentDay <= 10) {
      dates.add('${currentYear}-${currentMonth.toString().padLeft(2, '0')}-10');
      dates.add('${currentYear}-${currentMonth.toString().padLeft(2, '0')}-20');
    } else if (currentDay <= 20) {
      dates.add('${currentYear}-${currentMonth.toString().padLeft(2, '0')}-20');
      int nextMonth = currentMonth + 1;
      int nextYear = currentYear;
      if (nextMonth > 12) {
        nextMonth = 1;
        nextYear++;
      }
      dates.add('${nextYear}-${nextMonth.toString().padLeft(2, '0')}-10');
    } else {
      int nextMonth = currentMonth + 1;
      int nextYear = currentYear;
      if (nextMonth > 12) {
        nextMonth = 1;
        nextYear++;
      }
      dates.add('${nextYear}-${nextMonth.toString().padLeft(2, '0')}-10');
      dates.add('${nextYear}-${nextMonth.toString().padLeft(2, '0')}-20');
    }

    return dates;
  }

  String formatDateForDisplay(String dateString) {
    DateTime date = DateTime.parse(dateString);
    List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  void handleBack() {
    if (currentPage > 1) {
      setState(() => currentPage--);
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget buildHeader(String stepText) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: handleBack,
            child: Icon(
              Icons.arrow_back_ios,
              size: 24,
              color: Colors.grey[600],
            ),
          ),
          Text(
            stepText,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget buildCustomTextField({
    required String placeholder,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    bool obscureText = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green[400]!),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          counterText: '',
        ),
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget buildContinueButton() {
    bool enabled = canContinue();
    String buttonText = currentPage == 8 ? 'SUBMIT' : 'CONTINUE';

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ElevatedButton(
        onPressed: enabled && !isLoading ? handleContinue : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? Colors.green[400] : Colors.grey[300],
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child:
            isLoading
                ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  buttonText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }

  // Page 1: Name
  Widget buildPage1() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildHeader('Step 1 of 8'),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  'What\'s your name?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'So that we know how to call you.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                buildCustomTextField(
                  placeholder: 'Your first name',
                  controller: firstNameController,
                ),
                buildCustomTextField(
                  placeholder: 'Your last name',
                  controller: lastNameController,
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          buildContinueButton(),
        ],
      ),
    );
  }

  // Page 2: Date of Birth
  Widget buildPage2() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildHeader('Step 2 of 8'),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  'When were you born, $firstName?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'So that we\'ll never forget your birthday.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: buildCustomTextField(
                        placeholder: 'Day',
                        controller: dayController,
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: buildCustomTextField(
                        placeholder: 'Month',
                        controller: monthController,
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: buildCustomTextField(
                        placeholder: 'Year',
                        controller: yearController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'This won\'t be set public by default. But you must be 18 or older to join.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          buildContinueButton(),
        ],
      ),
    );
  }

  // Page 3: Location
  Widget buildPage3() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildHeader('Step 3 of 8'),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  'Where are you living, $firstName?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'So that you connect easier with people nearby.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  child: DropdownButtonFormField<String>(
                    value: country.isEmpty ? null : country,
                    hint: Text('Select Schema'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.green[400]!),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    items:
                        [
                          '1000',
                          '2000',
                          '3000',
                          '4000',
                          '5000',
                          '6000',
                          '7000',
                          '8000',
                          '9000',
                          '10000',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        country = newValue ?? '';
                      });
                    },
                  ),
                ),
                buildCustomTextField(
                  placeholder: 'Phone number',
                  controller: cityController,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          buildContinueButton(),
        ],
      ),
    );
  }

  // Page 4: Identity Verification
  Widget buildPage4() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildHeader('Step 4 of 8'),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  'Identity Verification',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'Please provide your identity documents.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                buildCustomTextField(
                  placeholder: 'Aadhaar Number (12 digits)',
                  controller: adharController,
                  keyboardType: TextInputType.number,
                  maxLength: 12,
                ),
                buildCustomTextField(
                  placeholder: 'PAN Card Number',
                  controller: panController,
                  keyboardType: TextInputType.text,
                  maxLength: 10,
                ),
                SizedBox(height: 16),
                Text(
                  'Your information is secure and will be used only for verification purposes.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          buildContinueButton(),
        ],
      ),
    );
  }

  // Page 5: Address Details
  Widget buildPage5() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildHeader('Step 5 of 8'),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  'Address Details',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'Please provide your address information.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                buildCustomTextField(
                  placeholder: 'Address Line 1',
                  controller: address1Controller,
                ),
                buildCustomTextField(
                  placeholder: 'Address Line 2',
                  controller: address2Controller,
                ),
                SizedBox(height: 16),
                Text(
                  'Please provide your complete address for verification.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          buildContinueButton(),
        ],
      ),
    );
  }

  // Page 6: Schedule Date
  Widget buildPage6() {
    List<String> availableDates = getAvailableDates();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildHeader('Step 6 of 8'),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  'Select a Schedule Date',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'Choose your preferred appointment date.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                Column(
                  children:
                      availableDates.map((date) {
                        bool isSelected = selectedDate == date;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate = date;
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 16),
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Colors.green[50]
                                      : Colors.grey[50],
                              border: Border.all(
                                color:
                                    isSelected
                                        ? Colors.green[400]!
                                        : Colors.grey[300]!,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  color:
                                      isSelected
                                          ? Colors.green[400]
                                          : Colors.grey[400],
                                ),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      formatDateForDisplay(date),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            isSelected
                                                ? Colors.green[700]
                                                : Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Available for appointment',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          buildContinueButton(),
        ],
      ),
    );
  }

  // Page 7: Account Setup
 Widget buildPage7() {
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeader('Step 7 of 8'),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                'Email Verification',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'Please enter your email address twice to confirm.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),

              // ✅ Email Field
              buildCustomTextField(
                placeholder: 'Email Address',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              // ✅ Confirm Email Field
              buildCustomTextField(
                placeholder: 'Confirm Email Address',
                controller: confirmEmailController,
                keyboardType: TextInputType.emailAddress,
              ),

              SizedBox(height: 16),

              // ❗ Email mismatch validation
              if (emailController.text.isNotEmpty &&
                  confirmEmailController.text.isNotEmpty &&
                  emailController.text != confirmEmailController.text)
                Text(
                  'Email addresses do not match',
                  style: TextStyle(fontSize: 14, color: Colors.red),
                ),

              SizedBox(height: 8),
              Text(
                'Make sure you enter a valid email address. This will be used for account-related communication.',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
        buildContinueButton(),
      ],
    ),
  );
}

  // Page 8: Signature
  // Page 8: Digital Signature
  Widget buildPage8() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildHeader('Step 8 of 8'),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  'Digital Signature',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'Please provide your digital signature to complete the registration.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),

                // Signature Canvas
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Signature(
                      controller: _signatureController,
                      height: 200,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Signature Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _clearSignature,
                        icon: Icon(Icons.clear, size: 16),
                        label: Text('Clear'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey[400]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _saveSignature,
                        icon: Icon(Icons.save, size: 16),
                        label: Text('Save'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.green[400]!),
                          foregroundColor: Colors.green[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Upload from Gallery Option
                Container(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _uploadSignatureFromGallery,
                    icon: Icon(Icons.photo_library, size: 16),
                    label: Text('Upload from Gallery'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.blue[400]!),
                      foregroundColor: Colors.blue[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Signature Preview (if available)
                if (_hasSignature) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      border: Border.all(color: Colors.green[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green[600],
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Signature saved successfully',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Display signature preview
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          kIsWeb && _webSignatureImage != null
                              ? Image.memory(
                                _webSignatureImage!,
                                fit: BoxFit.contain,
                              )
                              : _signatureImage != null
                              ? Image.file(
                                _signatureImage!,
                                fit: BoxFit.contain,
                              )
                              : Container(
                                child: Center(
                                  child: Text(
                                    'Signature Preview',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                    ),
                  ),
                ],

                SizedBox(height: 16),

                // Instructions
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue[600], size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Instructions',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Draw your signature in the box above\n'
                        '• Click "Save" to confirm your signature\n'
                        '• Or upload a signature image from your gallery\n'
                        '• Your signature will be used for document verification',
                        style: TextStyle(fontSize: 14, color: Colors.blue[600]),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
          buildContinueButton(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFCE4EC), Color(0xFFFFF3E0)],
          ),
        ),
        child: SafeArea(
          child: Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                buildPage1(),
                buildPage2(),
                buildPage3(),
                buildPage4(),
                buildPage5(),
                buildPage6(),
                buildPage7(),
                buildPage8(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
