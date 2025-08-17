// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:text/welcomescreen/splash.dart';

// class MyProfileScreen extends StatefulWidget {
//   @override
//   _MyProfileScreenState createState() => _MyProfileScreenState();
// }

// class _MyProfileScreenState extends State<MyProfileScreen> {


//   Widget _buildListTile(IconData icon, String title, {VoidCallback? onTap}) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.black),
//       title: Text(title),
//       trailing: Icon(Icons.arrow_forward_ios, size: 16),
//       onTap: onTap,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       body: ListView(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         children: [
//           SizedBox(height: 16),
//           Center(
//             child: Column(
//               children: [
//                 CircleAvatar(
//                   radius: size.width * 0.12,
//                   backgroundImage: AssetImage('assets/images/profile (1).png'),
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   name ?? '',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 Text(email ?? '', style: TextStyle(color: Colors.grey[700])),
//                 SizedBox(height: 10),
//               ],
//             ),
//           ),
//           Divider(),
//           _buildListTile(Icons.favorite_border, 'Favourites'),
//           _buildListTile(Icons.download_outlined,  customerId?? ''),
//           _buildListTile(Icons.language, cutrty ?? ''),
//           _buildListTile(Icons.location_on, district ?? ''),
         
//           Divider(),

//           _buildListTile(Icons.logout, 'Log Out', onTap: _clearDataAndLogout),
//           SizedBox(height: 16),
//           Center(
//             child: Text(
//               'App Version $appVersion',
//               style: TextStyle(color: Colors.grey),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text/welcomescreen/splash.dart';

// Colors
//const kBackgroundColor = Color(0xff191720);
const kTextFieldFill = Color(0xff1E1C24);
// TextStyles
const kHeadline = TextStyle(
  color: Colors.white,
  fontSize: 34,
  fontWeight: FontWeight.bold,
);

const kBodyText = TextStyle(
  color: Colors.grey,
  fontSize: 15,
);

const kButtonText = TextStyle(
  color: Colors.black87,
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

const kBodyText2 = TextStyle(fontSize: 28, fontWeight: FontWeight.w500, color: Colors.white);

const kPrimaryColor = Color(0xFF4a0a44);
const kBluePrimary = Color(0xFF32519a);
const kBlackPrimary = Color(0xFF1A1A1A);
const kBlueSecondary = Color(0xFF42a0cd);
const kOrangePrimary = Color(0xFFf2813d);
const kOrangeSecondary = Color(0xFFf1684e);
const kBackgroundColor = Color(0xFFebecf0);
const kPrimaryLightColor = Color(0xFFFFE9EC);
const kSecondaryColor = Color(0xFFFAB609);
const profileColor = Color(0xFFECECEC);
const Color primary = Color(0xB5FFFFFF);
const Color primary0 = Color(0xFFFFB820);
const Color primary1= Color(0xFFFC5A4E);
const Color primary2= Color(0xFF282828);
const Color primary3= Color(0xFFF3E26B);
const Color secondary = Color(0xFF7BB0FF);
const Color black = Color(0xFF000000);
const Color white = Color(0xFFFFFFFF);
const Color grey = Colors.grey;
const kGradient = LinearGradient(
  colors: [Color(0xFF0064F5), Color(0xFF7BB0FF)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const double defaultPadding=16.0;


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Profile UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'qs',
      ),
      home: ProfileScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  String? name = '';
  String? email = '';
  String? district = '';
  String? postcode = '';
  String? customerId = '';
  String? cutrty = '';
  String? imageUrl = '';
  String appVersion = '2.3';
  
  // API payment history data
  List<Map<String, dynamic>> paymentHistory = [];
  bool isLoadingPayments = false;

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userString = prefs.getString('user');

    if (userString != null) {
      final user = jsonDecode(userString);
      setState(() {
        name = user['name'] ?? 'Unknown';
        email = user['contactNumber'] ?? 'No email';
        district = user['district'] ?? 'Malappuram';
        customerId = user['customerId'] ?? 'No id';
        cutrty = user['country'] ?? 'No id';
        imageUrl = user['image'] ?? 'https://i.pravatar.cc/300';
      });
      print("User Data: ${jsonEncode(user)}");
      
      // Load payment history after user data is loaded
      await _loadPaymentHistory();
    }
  }

  Future<void> _loadPaymentHistory() async {
    setState(() {
      isLoadingPayments = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://empjewellery.shop/withdraw/history'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        setState(() {
          paymentHistory = data.map((item) {
            return {
              'customerId': item['customerId'] ?? '',
              'amount': '₹${item['amount'] ?? 0}',
              'customerCode': item['customerCode'] ?? '',
              'status': item['status'] ?? '',
              'id': item['_id'] ?? '',
              'createdAt': item['createdAt'] ?? '',
              'adminCode': item['adminCode'] ?? '',
              'confirmedAt': item['confirmedAt'] ?? '',
              'completedAt': item['completedAt'] ?? '',
              'date': _formatDate(item['createdAt'] ?? ''),
              'isApproved': item['status'] == 'success',
              'isLoading': item['status'] == 'pending',
              'isDeclined': item['status'] == 'failed' || item['status'] == 'cancelled',
            };
          }).toList();
          isLoadingPayments = false;
        });
      } else {
        print('Failed to load payment history: ${response.statusCode}');
        setState(() {
          isLoadingPayments = false;
        });
      }
    } catch (e) {
      print('Error loading payment history: $e');
      setState(() {
        isLoadingPayments = false;
      });
    }
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    
    try {
      DateTime date = DateTime.parse(dateString);
      List<String> months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _clearDataAndLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SplashScreen(),
      ),
    );
  }

  Map<String, dynamic> getApprovalStatus(Map<String, dynamic> payment) {
    if (payment['isApproved']) {
      return {
        'text': 'Approved',
        'color': Color(0xff5aae7c),
        'textColor': Colors.greenAccent,
      };
    } else if (payment['isLoading']) {
      return {
        'text': 'Pending...',
        'color': Colors.orange.withOpacity(0.2),
        'textColor': Colors.orangeAccent,
      };
    } else if (payment['isDeclined']) {
      return {
        'text': 'Declined',
        'color': Colors.red.withOpacity(0.2),
        'textColor': Colors.redAccent,
      };
    } else {
      return {
        'text': 'Unknown',
        'color': Colors.grey.withOpacity(0.2),
        'textColor': Colors.grey,
      };
    }
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: kBluePrimary,
            expandedHeight: 280.0,
            floating: false,
            pinned: true,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  _showLogoutConfirmation(context);
                },
              ),
            ],
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                var top = constraints.biggest.height;
                var collapseRatio = ((top - kToolbarHeight) / (280.0 - kToolbarHeight)).clamp(0.0, 1.0);

                if (collapseRatio < 0.5 && !_animationController.isAnimating) {
                  _animationController.forward();
                } else if (collapseRatio > 0.5 && !_animationController.isAnimating) {
                  _animationController.reverse();
                }

                return FlexibleSpaceBar(
                  titlePadding: EdgeInsets.zero,
                  title: collapseRatio < 0.5
                      ? AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            height: kToolbarHeight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: kBackgroundColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Image.asset(
                                      'assets/images/icon123.png',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(
                                          child: Icon(
                                            Icons.person,
                                            size: 25,
                                            color: Colors.grey[300],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Safwan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                      : null,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          image: DecorationImage(
                            image: AssetImage('assets/images/jellery-removebg-preview.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.9),
                              Colors.black.withOpacity(0.85),
                              Colors.black.withOpacity(0.4),
                              Colors.transparent
                            ],
                            stops: [0.1, 0.2, 0.7, 1.0],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: AnimatedOpacity(
                          opacity: collapseRatio,
                          duration: Duration(milliseconds: 200),
                          child: Container(
                            padding: EdgeInsets.only(bottom: 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(42),
                                    border: Border.all(
                                      color: kBackgroundColor,
                                      width: 3,
                                    ),
                                  ),
                                  child: Container(
                                    width: 90,
                                    height: 90,
                                    margin: EdgeInsets.all(2.5),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(37),
                                      child: Image.asset(
                                        'assets/images/jellery-removebg-preview.png',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Center(
                                            child: Icon(
                                              Icons.person,
                                              size: 70,
                                              color: Colors.grey[300],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Column(
                                    children: [
                                      Text(
                                        name ?? '',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        customerId ?? '',
                                        style: TextStyle(
                                          letterSpacing: .5,
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        email ?? '',
                                        style: TextStyle(
                                          letterSpacing: .5,
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                   Colors.transparent,
                    Colors.transparent
                  ],
                  stops: [0.1, 0.2],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color.fromARGB(255, 232, 232, 235), const Color.fromARGB(255, 164, 165, 165)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 40.0),
                          child: Text(
                            'You have 1 month of annual payment to pay.',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 48, 9, 121).withOpacity(0.4),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.currency_rupee_outlined,
                                    color: Colors.black,
                                    size: 13,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Pay Now',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Payment History",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isLoadingPayments)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Show loading indicator or payment history
                  if (isLoadingPayments && paymentHistory.isEmpty)
                    Container(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  else if (paymentHistory.isEmpty)
                    Container(
                      height: 100,
                      child: Center(
                        child: Text(
                          'No payment history found',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  else
                    ...paymentHistory.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> payment = entry.value;
                      final status = getApprovalStatus(payment);

                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 300 + (index * 100)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      status['color'].withOpacity(0.4),
                                      status['color'].withOpacity(0.2),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ListTile(
                                  leading: Image.asset(
                                    'assets/images/jellery-removebg-preview.png',
                                    width: 45,
                                  ),
                                  title: Text(
                                    payment['date'] ?? '',
                                    style: TextStyle(color: Colors.white, fontSize: 13),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        status['text'],
                                        style: TextStyle(
                                          color: status['textColor'],
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (payment['customerCode'] != null && payment['customerCode'].isNotEmpty)
                                        Text(
                                          'Code: ${payment['customerCode']}',
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 10,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: Text(
                                    '${payment['amount']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Confirm Logout", style: TextStyle(color: Colors.black)),
          content: Text("Are you sure you want to log out?", style: TextStyle(color: Colors.black54)),
          actions: [
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Logout", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => SplashScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}