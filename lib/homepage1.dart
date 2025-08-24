import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class BankingHomePage extends StatelessWidget {
  final List<Map<String, dynamic>> transactions = [
    {
      'icon': 'assets/starbucks.png',
      'title': 'Starbucks Coffee',
      'date': 'Aug 24, 5:27 PM',
      'amount': '-\$14.99',
      'cardLast4': '4568',
      'color': Color(0xFF00704A),
    },
    {
      'icon': 'assets/dkny.png',
      'title': 'DKNY',
      'date': 'Aug 20, 2:14 PM',
      'amount': '-\$250.00',
      'cardLast4': '4568',
      'color': Colors.black,
    },
    {
      'icon': 'assets/netflix.png',
      'title': 'Netflix',
      'date': 'Aug 12, 07:25 PM',
      'amount': '-\$40.00',
      'cardLast4': '0961',
      'color': Color(0xFFE50914),
    },
    {
      'icon': 'assets/kfc.png',
      'title': 'KFC',
      'date': 'Aug 06, 06:12 PM',
      'amount': '-\$70.00',
      'cardLast4': '0961',
      'color': Color(0xFFE4002B),
    },
    {
      'icon': 'assets/amazon.png',
      'title': 'Amazon',
      'date': 'Aug 03, 02:30 PM',
      'amount': '-\$89.99',
      'cardLast4': '4568',
      'color': Color(0xFFFF9900),
    },
    {
      'icon': 'assets/netflix.png',
      'title': 'Netflix',
      'date': 'Aug 12, 07:25 PM',
      'amount': '-\$40.00',
      'cardLast4': '0961',
      'color': Color(0xFFE50914),
    },
    {
      'icon': 'assets/kfc.png',
      'title': 'KFC',
      'date': 'Aug 06, 06:12 PM',
      'amount': '-\$70.00',
      'cardLast4': '0961',
      'color': Color(0xFFE4002B),
    },
    {
      'icon': 'assets/amazon.png',
      'title': 'Amazon',
      'date': 'Aug 03, 02:30 PM',
      'amount': '-\$89.99',
      'cardLast4': '4568',
      'color': Color(0xFFFF9900),
    },
    {
      'icon': 'assets/spotify.png',
      'title': 'Spotify Premium',
      'date': 'Aug 01, 09:15 AM',
      'amount': '-\$12.99',
      'cardLast4': '0961',
      'color': Color(0xFF1DB954),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSecondaryColor,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   scrolledUnderElevation: 0,
      //   actionsPadding: EdgeInsets.symmetric(horizontal: 10),
      //   actions: [
      //     badges.Badge(
      //       position: badges.BadgePosition.topEnd(top: 8, end: 6),
      //       badgeStyle: badges.BadgeStyle(
      //         badgeColor: Colors.green.shade400,
      //         borderSide: BorderSide(color: Colors.white, width: 1.5),
      //         padding: EdgeInsets.all(4), // small dot
      //         elevation: 0,
      //       ),
      //       showBadge: true, // set false to hide
      //       child: IconButton(
      //         onPressed: () {},
      //         style: ButtonStyle(
      //           padding: MaterialStateProperty.all(EdgeInsets.zero),
      //           minimumSize: MaterialStateProperty.all(Size.square(35)),
      //           maximumSize: MaterialStateProperty.all(Size.square(35)),
      //           side: MaterialStateProperty.all(
      //             BorderSide(color: Colors.grey.shade200, width: 1),
      //           ),
      //         ),
      //         icon: Icon(UIcons.regularRounded.bell, size: 18),
      //       ),
      //     ),
      //   ],
      //   title: Row(
      //     children: [
      //       CircleAvatar(
      //         radius: 18,
      //         //backgroundImage: AssetImage('assets/profile.jpg'), // You'll need to add this asset
      //         backgroundColor: Colors.grey[200],
      //       ),
      //       SizedBox(width: 12),
      //       Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           Text(
      //             'Welcome,',
      //             style: TextStyle(
      //               fontSize: 12,
      //               color: Colors.grey[600],
      //               fontWeight: FontWeight.w400,
      //             ),
      //           ),
      //           Text(
      //             'Diane Cruz',
      //             style: TextStyle(
      //               fontSize: 15,
      //               color: Colors.black,
      //               fontWeight: FontWeight.w500,
      //             ),
      //           ),
      //         ],
      //       ),
      //     ],
      //   ),
      // ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // final screenHeight = constraints.maxHeight;
          //
          // // height of top content (AppBar + Balance + Card + spacing)
          // final topContentHeight = 350.0; // adjust if you add more widgets
          //
          // // calculate percentage of screen to start sheet
          // final initialChildSize = topContentHeight / screenHeight;

          return Stack(
            children: [
              SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    // gradient: LinearGradient(
                    //     begin: Alignment.topLeft,
                    //     end: Alignment.centerRight,
                    //     colors: [
                    //       Color(0xffeac388),
                    //       Color(0xffefe7d3),
                    //     ]),
                  ),
                  child: Column(
                    children: [
                      AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        scrolledUnderElevation: 0,
                        actionsPadding: EdgeInsets.only(right: 15),
                        actions: [
                          badges.Badge(
                            position: badges.BadgePosition.topEnd(
                                top: 15, end: 14),
                            badgeStyle: badges.BadgeStyle(
                              badgeColor: Colors.green.shade500,
                              borderSide: BorderSide(color: Color(0xffd8cbaf), width: 1.5),
                              padding: EdgeInsets.all(4), // small dot
                              elevation: 0,
                            ),
                            showBadge: true, // set false to hide
                            child: IconButton(
                              onPressed: () {},
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(EdgeInsets.zero),
                                minimumSize: MaterialStateProperty.all(Size.square(35)),
                                maximumSize: MaterialStateProperty.all(Size.square(35)),
                                side: MaterialStateProperty.all(
                                  BorderSide(color: Colors.black26, width: 1),
                                ),
                              ),
                              icon: Icon(UIcons.regularRounded.bell, size: 18),
                            ),
                          ),
                        ],
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
              ),

              // Bottom Sheet for Recent Transactions
              DraggableScrollableSheet(
                initialChildSize: (constraints.maxHeight - 380) / constraints.maxHeight,
                minChildSize: (constraints.maxHeight - 380) / constraints.maxHeight,
                maxChildSize: 0.8,
                builder: (context, scrollController) {
                  return Container(
                    padding: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      // gradient: LinearGradient(
                      //     begin: Alignment.topLeft,
                      //     end: Alignment.centerRight,
                      //     colors: [
                      //       Color(0xffF9FBE7),
                      //       Color(0xffF9FBE7),
                      //     ]
                      // ),
                      color: kSecondaryColor,
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.black.withOpacity(0.5),
                      //     blurRadius: 10,
                      //     offset: Offset(0, -5),
                      //   ),
                      // ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
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
                          child: ListView.builder(
                            controller: scrollController,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            physics: ClampingScrollPhysics(),
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              final tx = transactions[index];
                              return TransactionTile(
                                icon: tx['icon'],
                                title: tx['title'],
                                date: tx['date'],
                                amount: tx['amount'],
                                cardLast4: tx['cardLast4'],
                                color: tx['color'],
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
  final String icon;
  final String title;
  final String date;
  final String amount;
  final String cardLast4;
  final Color color;

  TransactionTile({
    required this.icon,
    required this.title,
    required this.date,
    required this.amount,
    required this.cardLast4,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.grey.shade200, width: 1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Icon(
                _getIconForTitle(title),
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (amount.isNotEmpty)
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              if (cardLast4.isNotEmpty)
                Text(
                  '•••• $cardLast4',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w300,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'starbucks coffee':
        return Icons.local_cafe;
      case 'dkny':
        return Icons.shopping_bag;
      case 'netflix':
        return Icons.play_circle_fill;
      case 'kfc':
        return Icons.fastfood;
      case 'amazon':
        return Icons.shopping_cart;
      case 'spotify premium':
        return Icons.music_note;
      case 'uber':
        return Icons.local_taxi;
      case 'mcdonald\'s':
        return Icons.fastfood;
      default:
        return Icons.store;
    }
  }
}

class WirelessIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
    Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw wireless payment arcs
    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.2,
      size.width * 0.8,
      size.height * 0.8,
    );

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    canvas.drawPath(path, paint);

    final path2 = Path();
    path2.moveTo(size.width * 0.3, size.height * 0.7);
    path2.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.4,
      size.width * 0.7,
      size.height * 0.7,
    );
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class MastercardLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final redPaint =
    Paint()
      ..color = Color(0xFFEB001B)
      ..style = PaintingStyle.fill;

    final yellowPaint =
    Paint()
      ..color = Color(0xFFF79E1B)
      ..style = PaintingStyle.fill;

    final radius = size.height / 2;

    // Left circle (red)
    canvas.drawCircle(Offset(radius, radius), radius * 0.8, redPaint);

    // Right circle (yellow)
    canvas.drawCircle(
      Offset(size.width - radius, radius),
      radius * 0.8,
      yellowPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
