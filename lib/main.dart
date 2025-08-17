import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text/add.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:text/cusberadd.dart';
import 'package:text/custobercreation.dart';
import 'package:text/eoror.dart';
import 'package:text/payment.dart';
import 'package:text/profile.dart';
import 'package:text/welcomescreen/addagentsub.dart';
import 'package:text/welcomescreen/onboardmain.dart';
import 'package:text/welcomescreen/splash.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bank UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
        textTheme: Theme.of(context).textTheme.apply(fontSizeFactor: 1.0),
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: MediaQuery.of(
              context,
            ).textScaleFactor.clamp(0.8, 1.2),
          ),
          child: child!,
        );
      },
    );
  }
}

class BottomNavController extends StatefulWidget {
  const BottomNavController({Key? key}) : super(key: key);

  @override
  State<BottomNavController> createState() => _BottomNavControllerState();
}

class _BottomNavControllerState extends State<BottomNavController>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  String? profileType;

  // Different page lists based on profile type
  List<Widget> get _pages {
    if (profileType == 'customer') {
      // Only Home and Profile for customers
      return [
        const HomePage(id: "68232c56728da7bda7fb46c9"),
        ProfileScreen(),
      ];
    } else {
      // Full navigation for other users
      return [
        const HomePage(id: "68232c56728da7bda7fb46c9"),
        if (profileType == 'shareholder')
          PaymentPage()
        else if (profileType == 'agent')
          PaymentPage()
        else if (profileType == 'subagent')
          PaymentPage()
        else
          ErrorPage(errorMessage: 'Access Denied'),
        ProfileScreen(),
        ProfileScreen(),
      ];
    }
  }



  @override
  void initState() {
    super.initState();
    _loadProfileType();
  }

  Future<void> _loadProfileType() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      final user = jsonDecode(userJson);
      setState(() {
        profileType = user['profileType'];
        // Reset selected index if customer and currently on a hidden tab
        if (profileType == 'customer' && _selectedIndex > 1) {
          _selectedIndex = 0;
        }
      });
    }
  }

  void _onItemTapped(int index) {
    if (profileType == 'customer') {
      // For customers, only handle Home (0) and Profile (1)
      setState(() {
        _selectedIndex = index;
      });
    } else {
      // For other users, handle all tabs including Add functionality
      if (index == 2) {
        _showAddOptions();
      } else {
        setState(() {
          _selectedIndex = index;
        });
      }
    }
  }

  void _showAddOptions() {
    // Don't show add options for customers (this shouldn't be called for customers anyway)
    if (profileType == 'customer') {
      return;
    }

    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: screenSize.height * 0.6,
        minHeight: screenSize.height * 0.3,
      ),
      builder: (context) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 20,
                  vertical: isSmallScreen ? 20 : 25,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 20),

                    // Title
                    Text(
                      'Add New',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 25),

                    // Add Customer Option
                    if (profileType == 'shareholder' ||
                        profileType == 'agent' ||
                        profileType == 'subagent')
                      _buildAnimatedOption(
                        icon: Icons.person_add_alt_1,
                        title: 'Add Customer',
                        subtitle: 'Register a new customer',
                        gradientColors: [Colors.blue[400]!, Colors.blue[600]!],
                        onTap: () {
                          Navigator.pop(context);
                          if (profileType == 'shareholder' ||
                              profileType == 'agent' ||
                              profileType == 'subagent') {
                            _navigateWithAnimation(RegistrationFlow());
                          } else {
                            _navigateWithAnimation(
                              ErrorPage(errorMessage: 'Access Denied'),
                            );
                          }
                        },
                        delay: 100,
                      ),

                    if (profileType == 'shareholder' ||
                        profileType == 'agent' ||
                        profileType == 'subagent')
                      SizedBox(height: isSmallScreen ? 12 : 15),

                    // Add Agent Option
                    if (profileType == 'shareholder' || profileType == 'agent')
                      _buildAnimatedOption(
                        icon: Icons.group_add,
                        title: 'Add Agent',
                        subtitle: 'Register a new agent',
                        gradientColors: [
                          Colors.green[400]!,
                          Colors.green[600]!,
                        ],
                        onTap: () {
                          Navigator.pop(context);
                          _navigateWithAnimation(const UserCreation12());
                        },
                        delay: 200,
                      ),

                    SizedBox(height: isSmallScreen ? 16 : 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    required int delay,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 360;

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 600 + delay),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            final clampedValue = value.clamp(0.0, 1.0);
            return Transform.scale(
              scale: clampedValue,
              child: Transform.translate(
                offset: Offset(0, 50 * (1 - clampedValue)),
                child: Opacity(opacity: clampedValue, child: child),
              ),
            );
          },
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: isSmallScreen ? 60 : 70,
                maxHeight: isSmallScreen ? 80 : 90,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: onTap,
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            icon,
                            color: Colors.white,
                            size: isSmallScreen ? 20 : 24,
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 12 : 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: isSmallScreen ? 10 : 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white.withOpacity(0.8),
                          size: isSmallScreen ? 14 : 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateWithAnimation(Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic background based on profile tab (index 3 for others, index 1 for customers)
    int profileIndex = profileType == 'customer' ? 1 : 3;
    Color scaffoldBackground = _selectedIndex == profileIndex ? Color(0xFF1A1A1A) : Colors.white;
    Color navBarBackground = _selectedIndex == profileIndex ? Color(0xFF1A1A1A) : Colors.white;
    
    return Scaffold(
      backgroundColor: scaffoldBackground,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        color: navBarBackground,
        child: BottomNavigationBar(
          backgroundColor: navBarBackground,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Color.fromARGB(255, 7, 7, 7),
          unselectedItemColor: Color.fromARGB(255, 155, 155, 155),
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 10,
          selectedLabelStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600
          ),
          unselectedLabelStyle: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500
          ),
          items: profileType == 'customer' ? [
            // Customer navigation - only Home and Profile
            BottomNavigationBarItem(
              icon: Image.asset(
                color: _selectedIndex == 1 ? Colors.white : Colors.black,
                'assets/images/home (1).png',
                width: 18,
                height: 18,
              ),
              activeIcon: Image.asset(
                color: _selectedIndex == 1 ? Colors.white : Colors.black,
                'assets/images/home (1).png',
                width: 20,
                height: 20,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                color: _selectedIndex == 1 ? Colors.white : Colors.black,
                'assets/images/profile (1).png',
                width: 20,
                height: 20,
              ),
              activeIcon: Image.asset(
                color: _selectedIndex == 1 ? Colors.white : Colors.white,
                'assets/images/profile (1).png',
                width: 24,
                height: 24,
              ),
              label: 'Profile',
            ),
          ] : [
            // Full navigation for other users
            BottomNavigationBarItem(
              icon: Image.asset(
                color: _selectedIndex == 3 ? Colors.white : Colors.black,
                'assets/images/home (1).png',
                width: 18,
                height: 18,
              ),
              activeIcon: Image.asset(
                color: _selectedIndex == 3 ? Colors.white : Colors.black,
                'assets/images/home (1).png',
                width: 20,
                height: 20,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                color: _selectedIndex == 3 ? Colors.white : Colors.black,
                'assets/images/wallet.png',
                width: 20,
                height: 20,
              ),
              activeIcon: Image.asset(
                color: _selectedIndex == 3 ? Colors.white : Colors.black,
                'assets/images/wallet.png',
                width: 24,
                height: 24,
              ),
              label: 'Pay',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                color: _selectedIndex == 3 ? Colors.white : Colors.grey,
                'assets/images/add-user.png',
                width: 20,
                height: 20,
              ),
              activeIcon: Image.asset(
                color: _selectedIndex == 3 ? Colors.white : Colors.grey,
                'assets/images/add-user.png',
                width: 24,
                height: 24,
              ),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                color: _selectedIndex == 3 ? Colors.white : Colors.black,
                'assets/images/profile (1).png',
                width: 20,
                height: 20,
              ),
              activeIcon: Image.asset(
                color: _selectedIndex == 3 ? Colors.white : Colors.white,
                'assets/images/profile (1).png',
                width: 24,
                height: 24,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
class HomePage extends StatefulWidget {
  final String? id;
  const HomePage({Key? key, this.id}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Profile? profile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString == null) return;

    final userData = jsonDecode(userString);
    final id = userData['id'];

    final response = await http.get(
      Uri.parse("https://empjewellery.shop/profilesDetails?id=$id"),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        profile = Profile.fromJson(jsonData['profiles'][0]);
        isLoading = false;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  ErrorPage(errorMessage: 'Server error or internet issue'),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final padding = EdgeInsets.symmetric(
      horizontal: isSmallScreen ? 12 : 16,
      vertical: 8,
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child:
            isLoading
                ? SingleChildScrollView(
                  padding: padding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerProfileHeader(),
                      const SizedBox(height: 16),
                      _buildShimmerCardWidget(),
                      const SizedBox(height: 16),
                      _buildShimmerAdCarousel(),
                      const SizedBox(height: 16),
                      _buildShimmerTransactionsHeader(),
                      const SizedBox(height: 16),
                      _buildShimmerTransactionsList(),
                    ],
                  ),
                )
                : RefreshIndicator(
                  onRefresh: fetchProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: padding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HEADER WITH PROFILE NAME
                        _buildProfileHeader(),
                        const SizedBox(height: 16),

                        _buildCardWidget(profile),
                        const SizedBox(height: 16),

                        // Ad Carousel()
                        AdCarouselApp(),
                        const SizedBox(height: 16),

                        // Transactions
                        if (profile?.paymentDetails.isNotEmpty ?? false) ...[
                          _buildTransactionsHeader(),
                          const SizedBox(height: 12),
                          _buildTransactionsList(),
                        ] else
                          _buildNoTransactions(),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Row(
      children: [
        CircleAvatar(
          backgroundImage: const AssetImage("assets/images/profile (1).png"),
          radius: isSmallScreen ? 20 : 16,
        ),
        SizedBox(width: isSmallScreen ? 8 : 12),
        Expanded(
          child: Text(
            "Hello, ${profile?.name ?? 'User'}!",
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Mulish',
              color: Colors.grey[900]
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

 

  Widget _buildTransactionsHeader() {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 241, 230, 230),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 8 : 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                "trasactions",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Mulish',
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Container(
     
      padding: const EdgeInsets.all(12),
      child: Column(
        children:
            profile!.paymentDetails
                .map(
                  (detail) => _buildTransactionTile(
                    detail.title,
                    detail.date,
                    detail.amount,
                    Icons.account_balance_wallet,
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildNoTransactions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(Icons.receipt_long, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No transactions found",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(
    String title,
    String subtitle,
    String amount,
    IconData icon,
  ) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 241, 230, 230),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: isSmallScreen ? 24 : 30, color: Colors.black54),
          SizedBox(width: isSmallScreen ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: isSmallScreen ? 10 : 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
        ],
      ),
    );
  }

  // Shimmer Widgets
  Widget _buildShimmerProfileHeader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Colors.white, radius: 25),
          const SizedBox(width: 12),
          Container(
            width: 150,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCardWidget() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildShimmerAdCarousel() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildShimmerTransactionsHeader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: 100,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildShimmerTransactionsList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: List.generate(
          5,
          (index) => Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildCardWidget(Profile? profile) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final screenSize = MediaQuery.of(context).size;
      final screenWidth = screenSize.width;
      final screenHeight = screenSize.height;

      // Responsive calculations
      final isSmallScreen = screenWidth < 360;
      final isMediumScreen = screenWidth >= 360 && screenWidth < 400;
      final isLargeScreen = screenWidth >= 400;

      // Dynamic sizing based on screen dimensions
      double cardHeight;
      double fontSize;
      double amountFontSize;
      double horizontalPadding;
      double verticalPadding;
      double titleFontSize;

      if (isSmallScreen) {
        cardHeight = screenHeight * 0.20; // 20% of screen height
        fontSize = 11;
        titleFontSize = 10;
        amountFontSize = 22;
        horizontalPadding = 14;
        verticalPadding = 14;
      } else if (isMediumScreen) {
        cardHeight = screenHeight * 0.22;
        fontSize = 12;
        titleFontSize = 11;
        amountFontSize = 26;
        horizontalPadding = 16;
        verticalPadding = 16;
      } else {
        cardHeight = screenHeight * 0.24;
        fontSize = 14;
        titleFontSize = 12;
        amountFontSize = 30;
        horizontalPadding = 20;
        verticalPadding = 20;
      }

      // Calculate total amount
      final filteredDetails =
          profile?.paymentDetails
              .where(
                (detail) => double.tryParse(detail.amount.toString()) != 0000,
              )
              .toList() ??
          [];

      final totalAmount = filteredDetails.fold<double>(
        0.0,
        (sum, detail) =>
            sum + (double.tryParse(detail.amount.toString()) ?? 0.0),
      );

      return Container(
        constraints: BoxConstraints(
          minHeight: 150,
          maxHeight: cardHeight.clamp(150, 220),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Card background with gradient
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color.fromARGB(255, 60, 59, 59), Color.fromARGB(255, 104, 99, 99)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'EMPGOLD',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 6 : 10,
                            vertical: isSmallScreen ? 2 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "ICONIC",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: titleFontSize,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Amount
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '₹${totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: amountFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),

                    // Bottom Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 2,
                          child: Text(
                            "ID: ${profile?.aadhaarNumber ?? ''}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: fontSize,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                profile?.dob.split("T")[0] ?? "",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: fontSize,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Decorative elements - scaled based on card size
              Positioned(
                top: -20,
                right: -10,
                child: Container(
                  width: cardHeight * 0.4,
                  height: cardHeight * 0.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: -25,
                left: -15,
                child: Container(
                  width: cardHeight * 0.5,
                  height: cardHeight * 0.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// AdCarouselWidget placeholder - replace with your actual implementation

class Profile {
  final String name;
  final String lastName;
  final String aadhaarNumber;
  final String panNumber;
  final String contactNumber;
  final String email;
  final String address;
  final String district;
  final String state;
  final String country;
  final String dob;
  final String signatureUrl;
  final List<PaymentDetail> paymentDetails;

  Profile({
    required this.name,
    required this.lastName,
    required this.aadhaarNumber,
    required this.panNumber,
    required this.contactNumber,
    required this.email,
    required this.address,
    required this.district,
    required this.state,
    required this.country,
    required this.dob,
    required this.signatureUrl,
    required this.paymentDetails,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: json['name'] ?? '',
      lastName: json['lastName'] ?? '',
      aadhaarNumber: json['aadhaarNumber'] ?? '',
      panNumber: json['panNumber'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      district: json['district'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      dob: json['dob'] ?? '',
      signatureUrl: json['signatureUrl'] ?? '',
      paymentDetails:
          (json['paymentDetails'] as List<dynamic>?)
              ?.map((e) => PaymentDetail.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PaymentDetail {
  final String title;
  final String date;
  final String amount;

  PaymentDetail({
    required this.title,
    required this.date,
    required this.amount,
  });

  factory PaymentDetail.fromJson(Map<String, dynamic> json) {
    return PaymentDetail(
      title: json['title'] ?? 'Transaction',
      date: json['date'] ?? '',
      amount: json['amount']?.toString() ?? '₹0.00',
    );
  }
}
