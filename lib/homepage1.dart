import 'dart:convert';
import 'dart:math';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:icon_badge/icon_badge.dart';
import 'package:uicons/uicons.dart';
import 'package:intl/intl.dart'; // <-- for currency formatting

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

  String userName = "";
  String cardNumber = "";
  double balance = 0.0;
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
        Uri.parse("https://dummyjson.com/c/6a2f-9535-48bc-b7ed"),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          userName = data['name'];
          cardNumber = data['cardNumber'];
          balance = (data['balance'] as num).toDouble();
          transactions = List<Map<String, dynamic>>.from(data['transactions']);
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load transactions. Please check your internet connection.'),
            backgroundColor: Colors.red,
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
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
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
                  userName.isNotEmpty ? userName : 'Guest',
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
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
                                '₹${balance.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 27,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
                    ),
                    SizedBox(height: 20),
                    // Card Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Card 3 (back-most)
                          Positioned(
                            bottom: 12,
                            left: 30,
                            right: 30,
                            child: Container(
                              height: 180,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.brown.shade400, Colors.black54],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Card 2 (middle)
                          Positioned(
                            bottom: 6,
                            left: 15,
                            right: 15,
                            child: Container(
                              height: 180,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFFFFC107), Colors.black],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Card 1 (front-most = your original card)
                          Container(
                            height: 180,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/images/coinbag1.png"),
                                fit: BoxFit.contain,
                                opacity: .2,
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [kPrimaryColor, Color(0xFF2A2A2A)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 10,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '₹${balance.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Image.asset(
                                        "assets/images/emp_bg.png",
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.contain,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(20,10,20,10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(20),
                                        bottomLeft: Radius.circular(20)),
                                    color: Color(0xFF2A2A2A).withOpacity(.2),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                            cardNumber.isNotEmpty
                                                ? cardNumber
                                                : 'XXXX XXXX XXXX XXXX',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
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
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 5),
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
                            ],
                          ),
                        ),
                        Expanded(
                          child: isLoading
                              ? Center(child: CircularProgressIndicator())
                              : ListView.builder(
                            controller: scrollController,
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                            physics: ClampingScrollPhysics(),
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              final tx = transactions[index];
                              return TransactionTile(
                                title: tx['title'],
                                date: tx['date'],
                                amount: (tx['amount'] as num).toDouble(), // <-- safe cast
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
  final double amount; // <-- use double instead of String

  TransactionTile({
    required this.title,
    required this.date,
    required this.amount,
  });

  static final List<Color> _themeColors = [
    Color(0xFFFFD700),
    Color(0xFFFFC107),
    Color(0xFFFFE082),
    Color(0xFFFFB300),
    Color(0xFFFFD54F),
    Colors.black54,
    Colors.brown,
  ];

  Color get randomColor => _themeColors[Random().nextInt(_themeColors.length)];

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

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
          )
              : null,
        ),
        child: Center(
          child: title.toLowerCase() == "empair gold"
              ? SizedBox()
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
      trailing: Text(
        currencyFormat.format(amount), // <-- formatted ₹
        style: TextStyle(
          fontSize: 14,
          color: amount < 0 ? Colors.red.shade300 : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
