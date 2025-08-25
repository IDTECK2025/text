import 'dart:convert';
import 'dart:math';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:icon_badge/icon_badge.dart';
import 'package:uicons/uicons.dart';
import 'constract.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banking App',
      theme: ThemeData(
        fontFamily: 'ls',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(letterSpacing: .5),
          bodyMedium: TextStyle(letterSpacing: .5),
          bodySmall: TextStyle(letterSpacing: .5),
          titleLarge: TextStyle(letterSpacing: .5),
          titleMedium: TextStyle(letterSpacing: .5),
          titleSmall: TextStyle(letterSpacing: .5),
          labelLarge: TextStyle(letterSpacing: .5),
          labelMedium: TextStyle(letterSpacing: .5),
          labelSmall: TextStyle(letterSpacing: .5),
        ),
      ),
      home: BankingHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BankingHomePage extends StatefulWidget {
  @override
  _BankingHomePageState createState() => _BankingHomePageState();
}

class _BankingHomePageState extends State<BankingHomePage> {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      final response = await http.get(
        Uri.parse("https://dummyjson.com/c/a2df-57a7-4d8d-8c62"),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          transactions = List<Map<String, dynamic>>.from(data['entries']);
          isLoading = false;
        });
      } else {
        print('Failed to load transactions: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching transactions: $e');
      setState(() {
        isLoading = false;
      });

      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load transactions. Please check your internet connection.'),
            backgroundColor: kPrimaryColor,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSecondaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actionsPadding: EdgeInsets.only(right: 15),
        // actions: [
        //   badges.Badge(
        //     position: badges.BadgePosition.topEnd(
        //         top: 15, end: 14),
        //     badgeStyle: badges.BadgeStyle(
        //       badgeColor: Colors.green.shade500,
        //       borderSide: BorderSide(color: Color(0xffd8cbaf), width: 1.5),
        //       padding: EdgeInsets.all(4), // small dot
        //       elevation: 0,
        //     ),
        //     showBadge: true, // set false to hide
        //     child: IconButton(
        //       onPressed: () {},
        //       style: ButtonStyle(
        //         padding: MaterialStateProperty.all(EdgeInsets.zero),
        //         minimumSize: MaterialStateProperty.all(Size.square(35)),
        //         maximumSize: MaterialStateProperty.all(Size.square(35)),
        //         side: MaterialStateProperty.all(
        //           BorderSide(color: Colors.black26, width: 1),
        //         ),
        //       ),
        //       icon: Icon(UIcons.regularRounded.bell, size: 18),
        //     ),
        //   ),
        // ],
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              //backgroundImage: AssetImage('assets/profile.jpg'), // You'll need to add this asset
              backgroundColor: Colors.black54,
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome,',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  'Diane Cruz',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Balance',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\₹10,524.15',
                                style: TextStyle(
                                  fontSize: 27,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: kPrimaryColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Card Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        height: 180,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/coinbag1.png'),
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomRight,
                            opacity: .2,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [kPrimaryColor, Color(0xFF2A2A2A)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Card balance
                            Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween,
                              children: [
                                Text(
                                  '\₹4,556.15',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Image.asset(
                                  "assets/images/emp_bg.png", width: 40,
                                  height: 40,
                                  fit: BoxFit.contain,),
                              ],
                            ),
                            // Card type and number
                            Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(
                                        'Card Number',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '1234 5678 9023 4234',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Container(
                                //   width: 40,
                                //   height: 24,
                                //   child: CustomPaint(
                                //     painter: MastercardLogoPainter(),
                                //   ),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    // Spacer to push content up
                    Expanded(child: SizedBox()),
                  ],
                ),
              ),

              // Bottom Sheet for Recent Transactions
              DraggableScrollableSheet(
                initialChildSize: (constraints.maxHeight - 290) / constraints.maxHeight,
                minChildSize: (constraints.maxHeight - 290) / constraints.maxHeight,
                maxChildSize: 0.9,
                builder: (context, scrollController) {
                  return Container(
                    padding: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      color: kSecondaryColor,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              20,10,20,5
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recent transactions',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              // GestureDetector(
                              //   onTap: () {
                              //     // Handle view all tap
                              //   },
                              //   child: Text(
                              //     'View all',
                              //     style: TextStyle(
                              //       fontSize: 14,
                              //       color: Color(0xFF4ECDC4),
                              //       fontWeight: FontWeight.w500,
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),

                        // Transaction List
                        Expanded(
                          child: isLoading
                              ? Center(child: CircularProgressIndicator())
                              :  ListView.builder(
                            controller: scrollController,
                            padding: EdgeInsets.fromLTRB(20,0,20,10),
                            physics: ClampingScrollPhysics(),
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              final tx = transactions[index];
                              return TransactionTile(
                                title: tx['title'],
                                date: tx['date'],
                                amount: tx['amount'],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final String title;
  final String date;
  final String amount;

  TransactionTile({
    required this.title,
    required this.date,
    required this.amount,
  });

  /// Define your theme color palette (gold shades + extras)
  static final List<Color> _themeColors = [
    Color(0xFFFFD700), // Pure gold
    Color(0xFFFFC107), // Amber
    Color(0xFFFFE082), // Light gold
    Color(0xFFFFB300), // Deep golden orange
    Color(0xFFFFD54F), // Soft golden yellow
    Colors.black54,
    Colors.brown,
  ];

  /// Pick a random color from the list
  Color get randomColor =>
      _themeColors[Random().nextInt(_themeColors.length)];

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 1),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: randomColor,
          borderRadius: BorderRadius.circular(30),
          image: title.toLowerCase() == "empair gold"
              ? DecorationImage(
            image: AssetImage('assets/images/empGold.jpeg'),
            fit: BoxFit.cover,
            opacity: .9,
          ) : null,
        ),
        child: Center(
          child: title.toLowerCase() == "empair gold"
              ? Text('')
              : Text(
            title.isNotEmpty ? title.substring(0, 1).toUpperCase() : '',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black,
          fontWeight: FontWeight.w400,
        ),
      ),
      subtitle: Text(
        date,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
          fontWeight: FontWeight.w300,
        ),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (amount.isNotEmpty)
            Text(
              amount,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }
}

