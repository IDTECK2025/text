import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// For web image handling
import 'dart:typed_data';
import 'package:cross_file/cross_file.dart';

class UserCreation12 extends StatefulWidget {
  const UserCreation12({Key? key}) : super(key: key);

  @override
  _UserCreationScreenState createState() => _UserCreationScreenState();
}

class _UserCreationScreenState extends State<UserCreation12> {
  final _formKey = GlobalKey<FormState>();

  // Available scheme amounts

  final int _registrationFee = 250;
  String userName = 'User';
  String userShareId = '';
  bool isLoading = true;

  String? _token;

  // Membership type
  final List<String> _membershipTypes = [
    'Basic',
    'Premium',
    'Gold',
    'Platinum',
  ];
  String _selectedMembershipType = 'Basic'; // Default selected membership

  // Payment mode
  String _selectedPaymentMode = 'Offline'; // Default selected payment mode

  // For scheme date selection

  // Form fields with initial values for faster testing/development
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _panNumberController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _nomineeController = TextEditingController();
  final TextEditingController _postCodeController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _aadhaarNumberController =
      TextEditingController();
  final TextEditingController _nomineeNumberController =
      TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  DateTime? _selectedDate;

  File? _signatureImage;
  Uint8List? _webSignatureImage; // For web platform
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // Group form fields for better organization
  final List<Map<String, dynamic>> _personalInfoFields = [];
  final List<Map<String, dynamic>> _contactInfoFields = [];
  final List<Map<String, dynamic>> _addressFields = [];
  final List<Map<String, dynamic>> _nomineeFields = [];

  @override
  void initState() {
    super.initState();
    _setupFieldGroups();
    _loadUserData(); // Initialize valid scheme dates
  }

  // Check if a date is valid for schema selection (10th or 20th)

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _token = prefs.getString('token') ?? '';
        userShareId = prefs.getString('userShareId') ?? '';
        isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _setupFieldGroups() {
    _personalInfoFields.addAll([
      {
        'controller': _nameController,
        'label': 'First Name',
        'icon': Icons.person,
        'required': true,
        'validator': (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter first name';
          }
          return null;
        },
      },
      {
        'controller': _lastNameController,
        'label': 'Last Name',
        'icon': Icons.person_outline,
        'required': true,
        'validator': (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter last name';
          }
          return null;
        },
      },
      {
        'controller': _panNumberController,
        'label': 'PAN Number',
        'icon': Icons.credit_card,
        'textCapitalization': TextCapitalization.characters,
        'required': false,
        'validator': null, // Optional field
      },
      {
        'controller': _aadhaarNumberController,
        'label': 'Aadhaar Number',
        'icon': Icons.badge,
        'keyboardType': TextInputType.number,
        'required': false,
        'validator': (value) {
          if (value != null && value.isNotEmpty && value.length != 12) {
            return 'Aadhaar number should be 12 digits';
          }
          return null;
        },
      },
    ]);

    // Contact information fields
    _contactInfoFields.addAll([
      {
        'controller': _emailController,
        'label': 'Email Address',
        'icon': Icons.email,
        'keyboardType': TextInputType.emailAddress,
        'required': true,
        'validator': (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter email';
          }
          if (!value.contains('@') || !value.contains('.')) {
            return 'Please enter a valid email';
          }
          return null;
        },
      },
      {
        'controller': _contactNumberController,
        'label': 'Contact Number',
        'icon': Icons.phone,
        'keyboardType': TextInputType.phone,
        'required': true,
        'validator': (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter contact number';
          }
          if (value.length < 10) {
            return 'Contact number should be at least 10 digits';
          }
          return null;
        },
      },
    ]);

    _addressFields.addAll([
      {
        'controller': _addressController,
        'label': 'Address',
        'icon': Icons.home,
        'maxLines': 2,
        'required': false,
        'validator': null, // Optional field
      },
      {
        'controller': _stateController,
        'label': 'State',
        'icon': Icons.location_city,
        'required': false,
        'validator': null, // Optional field
      },
      {
        'controller': _districtController,
        'label': 'District',
        'icon': Icons.place,
        'required': false,
        'validator': null, // Optional field
      },
      {
        'controller': _postCodeController,
        'label': 'Post Code',
        'icon': Icons.pin,
        'keyboardType': TextInputType.number,
        'required': false,
        'validator': (value) {
          if (value != null &&
              value.isNotEmpty &&
              !RegExp(r'^\d+$').hasMatch(value)) {
            return 'Post code should contain only digits';
          }
          return null;
        },
      },
      {
        'controller': _countryController,
        'label': 'Country',
        'icon': Icons.flag,
        'required': false,
        'validator': null, // Optional field
      },
    ]);

    // Nominee fields - all optional
    _nomineeFields.addAll([
      {
        'controller': _nomineeController,
        'label': 'Nominee Name',
        'icon': Icons.person_add,
        'required': false,
        'validator': null, // Optional field
      },
      {
        'controller': _nomineeNumberController,
        'label': 'Nominee Contact',
        'icon': Icons.phone_forwarded,
        'keyboardType': TextInputType.phone,
        'required': false,
        'validator': (value) {
          if (value != null && value.isNotEmpty && value.length < 10) {
            return 'Nominee contact should be at least 10 digits';
          }
          return null;
        },
      },
    ]);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          // Handle web platform
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webSignatureImage = bytes;
          });
        } else {
          // Handle mobile platforms
          setState(() {
            _signatureImage = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Check for required fields outside of standard validation
      if (_signatureImage == null && _webSignatureImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload a signature'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      // if (_schemeDate == null) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('Please select a valid scheme date'),
      //       backgroundColor: Colors.orange,
      //     ),
      //   );
      //   return;
      // }

      // // if (_schemeDate == null) {
      // //   ScaffoldMessenger.of(context).showSnackBar(
      // //     const SnackBar(
      // //       content: Text('Please select a valid scheme date'),
      // //       backgroundColor: Colors.orange,
      // //     ),
      // //   );
      //   return;
      // }

      setState(() {
        _isLoading = true;
      });

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
        final currentProfileType = userData['profileType'];
        final id = userData['id']; // 'shareholder', 'agent', etc.

        // Determine new profile type based on current user
        String newProfileType;
        if (currentProfileType == 'shareholder') {
          newProfileType = 'agent';
        } else if (currentProfileType == 'agent') {
          newProfileType = 'subagent';
        } else {
          // If subagent or unauthorized profile type tries to register others
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are not authorized to create profiles'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://empjewellery.shop/createProfile'),
        );
        request.fields['profileType'] = newProfileType;
        request.fields['amount'] = _registrationFee.toString();
        request.fields['membershipFee'] = _registrationFee.toString();

        request.fields['name'] = _nameController.text;
        request.fields['lastName'] = _lastNameController.text;
        request.fields['panNumber'] = _panNumberController.text;
        request.fields['state'] = _stateController.text;
        request.fields['address'] = _addressController.text;
        request.fields['country'] = _countryController.text;
        request.fields['nominee'] = _nomineeController.text;
        request.fields['post_code'] = _postCodeController.text;
        request.fields['district'] = _districtController.text;
        request.fields['aadhaarNumber'] = _aadhaarNumberController.text;
        request.fields['nominieeNumber'] = _nomineeNumberController.text;
        request.fields['contactNumber'] = _contactNumberController.text;
        request.fields['email'] = _emailController.text;
        request.fields['createdBy'] = id;
        // request.fields['schemeDate'] = DateFormat(
        //   'yyyy-MM-dd',
        // ).format(_dateTime!);

        if (_selectedDate != null) {
          request.fields['dob'] = DateFormat(
            'yyyy-MM-dd',
          ).format(_selectedDate!);
        }

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
            await http.MultipartFile.fromPath(
              'signature',
              _signatureImage!.path,
            ),
          );
        }

        // Add token to headers
        request.headers['Authorization'] = 'Bearer $token';

        final response = await request.send();
        final responseData = await response.stream.bytesToString();
        final result = json.decode(responseData);

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Generate PDF receipt
          if (kIsWeb) {
            // Handle web version differently since it can't use File directly
            // A more complex web PDF solution would be needed here
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Web platform: PDF would be generated here'),
                backgroundColor: Colors.blue,
              ),
            );
          } else {
            // For mobile platforms
            // await ReceiptGenerator.generateReceiptPDF(
            //   context: context,
            //   name: _nameController.text,
            //   lastName: _lastNameController.text,
            //   email: _emailController.text,
            //   contactNumber: _contactNumberController.text,
            //   address: _addressController.text,
            //   district: _districtController.text,
            //   state: _stateController.text,
            //   postCode: _postCodeController.text,
            //   schemeAmount: _selectedAmount,
            //   schemeDate: _dateTime!,
            //   membershipType: _selectedMembershipType,
            //   membershipFee: _registrationFee,
            //   panNumber:
            //       _panNumberController.text.isNotEmpty
            //           ? _panNumberController.text
            //           : null,
            //   aadhaarNumber:
            //       _aadhaarNumberController.text.isNotEmpty
            //           ? _aadhaarNumberController.text
            //           : null,
            //   nomineeName:
            //       _nomineeController.text.isNotEmpty
            //           ? _nomineeController.text
            //           : null,
            //   nomineeNumber:
            //       _nomineeNumberController.text.isNotEmpty
            //           ? _nomineeNumberController.text
            //           : null,
            //   signatureImage: _signatureImage,
            // );
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Membership created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          void _clearAllFields() {
            // Clear all text controllers
            _nameController.clear();
            _lastNameController.clear();
            _panNumberController.clear();
            _stateController.clear();
            _addressController.clear();
            _countryController.clear();
            _nomineeController.clear();
            _postCodeController.clear();
            _districtController.clear();
            _aadhaarNumberController.clear();
            _nomineeNumberController.clear();
            _contactNumberController.clear();
            _emailController.clear();

            // Reset dates
            setState(() {
              _selectedDate = null;

              // Reset signature image
              _signatureImage = null;
              _webSignatureImage = null;

              // Reset to default values
              _selectedMembershipType = 'Basic';
              _selectedPaymentMode = 'Offline';

              // Update valid scheme dates again
            });

            // Reset form validation state
            _formKey.currentState?.reset();
          }

          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => SuccessPage(
                    message: 'Customer Registration Completed Successfully!',
                  ),
            ),
          );
          // Don't navigate away immediately if receipt is shown
          // Navigator.pop(context);
        } else {
          throw Exception('Failed to create user: ${"check your details"}');
        }
      } catch (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('check all data'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      // The form has validation errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the form errors before submitting'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Widget _buildFormField(Map<String, dynamic> fieldData) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: fieldData['controller'],
        decoration: InputDecoration(
          labelText: fieldData['label'],
          hintText: 'Enter ${fieldData['label']}',
          prefixIcon: Icon(fieldData['icon']),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: fieldData['validator'],
        keyboardType: fieldData['keyboardType'],
        maxLines: fieldData['maxLines'] ?? 1,
        textCapitalization:
            fieldData['textCapitalization'] ?? TextCapitalization.none,
      ),
    );
  }

  Widget _buildFormSection(String title, List<Map<String, dynamic>> fields) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            ...fields.map((field) => _buildFormField(field)).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text('customer Registration'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'agent Registration',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Registration Fee Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Registration Fee',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade50,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.currency_rupee, color: Colors.green),
                            const SizedBox(width: 12),
                            Text(
                              '₹ $_registrationFee',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Fixed',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Membership Type Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.card_membership,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Membership Type',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade50,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedMembershipType,
                            isExpanded: true,
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: Theme.of(context).primaryColor,
                            ),
                            items:
                                _membershipTypes.map((String type) {
                                  return DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(
                                      type,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedMembershipType = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Payment Mode Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.payment,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Payment Mode',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Payment selection row with two options
                      Row(
                        children: [
                          // Option for Offline
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedPaymentMode = 'Offline';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        _selectedPaymentMode == 'Offline'
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey.shade300,
                                    width:
                                        _selectedPaymentMode == 'Offline'
                                            ? 2
                                            : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color:
                                      _selectedPaymentMode == 'Offline'
                                          ? Theme.of(
                                            context,
                                          ).primaryColor.withOpacity(0.1)
                                          : Colors.grey.shade50,
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.money,
                                      color:
                                          _selectedPaymentMode == 'Offline'
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey.shade600,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Offline',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            _selectedPaymentMode == 'Offline'
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                        color:
                                            _selectedPaymentMode == 'Offline'
                                                ? Theme.of(context).primaryColor
                                                : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Option for Online (disabled)
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Online payment is currently not available',
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade100,
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.credit_card,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Online',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Not Available',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Scheme Amount Dropdown Card
              // Card(
              //   elevation: 2,
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   margin: const EdgeInsets.only(bottom: 20),
              //   child: Padding(
              //     padding: const EdgeInsets.all(16),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Padding(
              //           padding: const EdgeInsets.only(bottom: 12),
              //           child: Text(
              //             'SCHEMA DATE',
              //             style: TextStyle(
              //               fontSize: 18,
              //               fontWeight: FontWeight.bold,
              //               color: Theme.of(context).primaryColor,
              //             ),
              //           ),
              //         ),
              //         InkWell(
              //           onTap: () => _selectscamdate(context),
              //           borderRadius: BorderRadius.circular(12),
              //           child: Container(
              //             padding: const EdgeInsets.symmetric(
              //               horizontal: 16,
              //               vertical: 15,
              //             ),
              //             decoration: BoxDecoration(
              //               border: Border.all(color: Colors.grey.shade300),
              //               borderRadius: BorderRadius.circular(12),
              //               color: Colors.grey.shade50,
              //             ),
              //             child: Row(
              //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //               children: [
              //                 Row(
              //                   children: [
              //                     Icon(Icons.cake, color: Colors.grey.shade600),
              //                     const SizedBox(width: 12),
              //                     Text(
              //                       _selectedDate == null
              //                           ? 'Select SCHAMA DATE'
              //                           : DateFormat(
              //                             'dd MMM yyyy',
              //                           ).format(_dateTime!),
              //                       style: TextStyle(
              //                         fontSize: 16,
              //                         color:
              //                             _selectedDate == null
              //                                 ? Colors.grey.shade600
              //                                 : Colors.black87,
              //                       ),
              //                     ),
              //                   ],
              //                 ),
              //                 Icon(
              //                   Icons.calendar_today,
              //                   color: Theme.of(context).primaryColor,
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              // Personal Information Section
              _buildFormSection('Personal Information', _personalInfoFields),

              // Date of Birth Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Date of Birth',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => _selectDate(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade50,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.cake, color: Colors.grey.shade600),
                                  const SizedBox(width: 12),
                                  Text(
                                    _selectedDate == null
                                        ? 'Select Date of Birth'
                                        : DateFormat(
                                          'dd MMM yyyy',
                                        ).format(_selectedDate!),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          _selectedDate == null
                                              ? Colors.grey.shade600
                                              : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.calendar_today,
                                color: Theme.of(context).primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Contact Information Section
              _buildFormSection('Contact Information', _contactInfoFields),

              // Address Section
              _buildFormSection('Address Details', _addressFields),

              // Nominee Information Section
              _buildFormSection('Nominee Information', _nomineeFields),

              // Signature Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.draw,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Signature',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: InkWell(
                          onTap: _pickImage,
                          child: Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    (_signatureImage == null &&
                                            _webSignatureImage == null)
                                        ? Colors.grey.shade300
                                        : Theme.of(context).primaryColor,
                                width:
                                    (_signatureImage == null &&
                                            _webSignatureImage == null)
                                        ? 1
                                        : 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.shade50,
                            ),
                            child:
                                (_signatureImage == null &&
                                        _webSignatureImage == null)
                                    ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.upload_file,
                                          size: 48,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Tap to upload signature',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    )
                                    : ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child:
                                          kIsWeb && _webSignatureImage != null
                                              ? Image.memory(
                                                _webSignatureImage!,
                                                fit: BoxFit.contain,
                                              )
                                              : Image.file(
                                                _signatureImage!,
                                                fit: BoxFit.contain,
                                              ),
                                    ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Submit Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline),
                              const SizedBox(width: 8),
                              Text(
                                'Submit ',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose all controllers
    _nameController.dispose();
    _lastNameController.dispose();
    _panNumberController.dispose();
    _stateController.dispose();
    _addressController.dispose();
    _countryController.dispose();
    _nomineeController.dispose();
    _postCodeController.dispose();
    _districtController.dispose();
    _aadhaarNumberController.dispose();
    _nomineeNumberController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}

class SuccessPage extends StatelessWidget {
  final String message;

  const SuccessPage({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animation container for the check mark
                Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 120,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Success message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 16),

                // Subtitle message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    "Thank you for registering with us. Your membership has been successfully created.",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 60),

                // Home button
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to home screen (replace with your home screen route)
                    // Navigator.of(context).pushAndRemoveUntil(
                    //   MaterialPageRoute(
                    //     builder: (context) =>  DesktopHomeScreen(),
                    //   ),
                    //   (route) => false, // This removes all previous routes
                    // );
                  },
                  icon: const Icon(Icons.home, size: 24),
                  label: const Text(
                    'Go to Home',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                ),

                const SizedBox(height: 20),

                // Optional: New registration button
                TextButton.icon(
                  onPressed: () {
                    // Go back to the form for a new registration
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.person_add_outlined),
                  label: const Text(
                    'New Registration',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Note: You'll need to replace 'HomePage()' with your actual home page widget
// If you don't have a HomePage class yet, create one or use your login page
// Example:
// class HomePage extends StatelessWidget {
//   const HomePage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//       ),
//       body: Center(
//         child: Text('Welcome to the home page!'),
//       ),
//     );
//   }
// }

// Update your _submitForm method to navigate to this page:
// After successful form submission, replace:
// Navigator.of(context).push(
//   MaterialPageRoute(
//     builder: (context) => SuccessPage(
//       message: 'Customer Registration Completed Successfully!',
//     ),
//   ),
// );
