import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:text/main.dart';
import 'package:text/pay.dart';

// Import the UPIPaymentPage



class Profile {
  final String id;
  final String customerId;
  final String name;
  final String lastName;
  final String contactNumber;
  final String? signatureUrl;
  final String email;
  final String state;
  final String district;
  final String? profileType;
  final String schemeType;

  Profile({
    required this.schemeType,
    required this.id,
    required this.customerId,
    required this.name,
    required this.lastName,
    required this.contactNumber,
    this.signatureUrl,
    required this.email,
    required this.state,
    required this.district,
    this.profileType,
  });

  String get fullName => '$name ${lastName != name ? lastName : ""}';

  String get initial => name.isNotEmpty ? name[0] : "";

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['_id'] ?? '',
      customerId: json['customerId'] ?? '',
      name: json['name'] ?? '',
      lastName: json['lastName'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      signatureUrl: json['signatureUrl'],
      email: json['email'] ?? '',
      state: json['state'] ?? '',
      district: json['district'] ?? '',
      profileType: json['profileType'],
      schemeType:json['schemeType']??'',
    );
  }
}

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Profile> _allProfiles = [];
  List<Profile> _filteredProfiles = [];
  bool _isLoading = true;
  String _errorMessage = '';
  // Add a controller for the amount
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProfiles();
    _searchController.addListener(_filterProfiles);
    // Set a default amount
    _amountController.text = '0.00';
  }

  Future<void> fetchProfiles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost:2025/profilesDetails?profileType=customer',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData.containsKey('profiles') && jsonData['profiles'] is List) {
          final List<dynamic> profilesData = jsonData['profiles'];
          setState(() {
            _allProfiles =
                profilesData.map((data) => Profile.fromJson(data)).toList();
            _filteredProfiles = List.from(_allProfiles);
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Invalid data ';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {

        _isLoading = false;
      });
    }
  }

  void _filterProfiles() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProfiles = List.from(_allProfiles);
      } else {
        _filteredProfiles =
            _allProfiles
                .where(
                  (profile) =>
                      profile.fullName.toLowerCase().contains(query) ||
                      profile.contactNumber.contains(query) ||
                      profile.customerId.toLowerCase().contains(query) ||
                      profile.email.toLowerCase().contains(query),
                )
                .toList();
      }
    });
  }

  // Function to show amount input dialog
  // Future<void> _showAmountDialog(Profile profile) async {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false, // User must tap button to close dialog
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Enter Amount'),
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: <Widget>[
  //               Text('Enter the amount to pay to ${profile.fullName}'),
  //               TextField(
  //                 controller: _amountController,
  //                 keyboardType: TextInputType.numberWithOptions(decimal: true),
  //                 decoration: const InputDecoration(
  //                   hintText: 'Amount',
  //                   prefixText: '₹ ',
  //                 ),
  //                 autofocus: true,
  //               ),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: const Text('Proceed'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               // Navigate to UPI payment page with entered amount
  //               _navigateToUpiPayment(profile, _amountController.text);
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Function to navigate to UPI payment page

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Color getAvatarColor(String id) {
    // Generate consistent colors based on the ID
    final int hashCode = id.hashCode;
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.blueGrey,
      Colors.deepOrange,
    ];
    return colors[hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
 Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavController()),
      );          },
        ),
        // title: const Text('Pay ', style: TextStyle(color: Colors.black87)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, phone or customer ID',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),

          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_errorMessage.isNotEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: fetchProfiles,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (_filteredProfiles.isEmpty)
            const Expanded(child: Center(child: Text('No profiles found')))
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: fetchProfiles,
                child: ListView.builder(
                  itemCount: _filteredProfiles.length,
                  itemBuilder: (context, index) {
                    final profile = _filteredProfiles[index];
                    return Card(
                              color: const Color.fromARGB(255, 241, 230, 230),

                      elevation: 0.5,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        
                        
                        leading: CircleAvatar(
                          backgroundColor: getAvatarColor(profile.id),
                          child:
                              profile.signatureUrl != null
                                  ? null
                                  : Text(
                                    profile.initial,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                        ),
                        title: Text(
                          profile.fullName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profile.contactNumber),
                            Text(
                              'ID: ${profile.customerId}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => UPIPaymentPage(
              recipientName: profile.fullName,
              amount: profile.schemeType,
              accountNumber: profile.customerId,
            ),
      ),
    );
  
                          // Show amount input dialog when a profile is tapped
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
