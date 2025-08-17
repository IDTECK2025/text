import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leaderboard App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Inter',
      ),
      home: LeaderboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LeaderboardScreen extends StatefulWidget {
  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int selectedTab = 0;
  final List<String> tabs = ['Daily', 'Weekly', 'Monthly'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9B59B6),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            CustomAppBar(),
            
            // Main Content
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Leaderboard Header
                    LeaderboardHeader(),
                    
                    // Tab Selector
                    TabSelector(
                      tabs: tabs,
                      selectedTab: selectedTab,
                      onTabChanged: (index) {
                        setState(() {
                          selectedTab = index;
                        });
                      },
                    ),
                    
                    SizedBox(height: 30),
                    
                    // Top 3 Users
                    TopThreeUsers(),
                    
                    SizedBox(height: 30),
                    
                    // Leaderboard List
                    Expanded(
                      child: LeaderboardList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '830',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            'Results',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.favorite,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 4),
              Text(
                '7',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LeaderboardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 25, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class TabSelector extends StatelessWidget {
  final List<String> tabs;
  final int selectedTab;
  final Function(int) onTabChanged;

  const TabSelector({
    Key? key,
    required this.tabs,
    required this.selectedTab,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          int index = entry.key;
          String tab = entry.value;
          bool isSelected = selectedTab == index;
          
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Color(0xFF9B59B6) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class TopThreeUsers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      child: Stack(
        children: [
          // Second Place
          Positioned(
            left: 40,
            top: 30,
            child: TopUserCard(
              position: 2,
              name: 'Marcus',
              avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
              isWinner: false,
            ),
          ),
          
          // First Place (Winner)
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 50,
            top: 0,
            child: TopUserCard(
              position: 1,
              name: 'Emma',
              avatar: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
              isWinner: true,
            ),
          ),
          
          // Third Place
          Positioned(
            right: 40,
            top: 30,
            child: TopUserCard(
              position: 3,
              name: 'Alex',
              avatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
              isWinner: false,
            ),
          ),
        ],
      ),
    );
  }
}

class TopUserCard extends StatelessWidget {
  final int position;
  final String name;
  final String avatar;
  final bool isWinner;

  const TopUserCard({
    Key? key,
    required this.position,
    required this.name,
    required this.avatar,
    required this.isWinner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double size = isWinner ? 100 : 80;
    Color borderColor = position == 1 
        ? Colors.amber 
        : position == 2 
            ? Color(0xFF9B59B6) 
            : Colors.orange;

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: borderColor.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: Container(
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.person,
                    size: size * 0.6,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
            
            if (isWinner)
              Positioned(
                top: -5,
                left: size / 2 - 15,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            
            Positioned(
              bottom: -5,
              left: size / 2 - 15,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: borderColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    position.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}

class LeaderboardList extends StatelessWidget {
  final List<LeaderboardUser> users = [
    LeaderboardUser(
      rank: 9,
      name: 'You Currently Rank',
      score: 34,
      avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&h=150&fit=crop&crop=face',
      isCurrentUser: true,
      trend: TrendType.up,
    ),
    LeaderboardUser(
      rank: 4,
      name: 'Jacob',
      score: 73,
      avatar: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=150&h=150&fit=crop&crop=face',
      isCurrentUser: false,
      trend: TrendType.up,
    ),
    LeaderboardUser(
      rank: 5,
      name: 'Dianne',
      score: 68,
      avatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
      isCurrentUser: false,
      trend: TrendType.down,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: users.length,
      itemBuilder: (context, index) {
        return LeaderboardListItem(user: users[index]);
      },
    );
  }
}

class LeaderboardListItem extends StatelessWidget {
  final LeaderboardUser user;

  const LeaderboardListItem({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: user.isCurrentUser ? Color(0xFFF3E5F5) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: user.isCurrentUser 
            ? Border.all(color: Color(0xFF9B59B6).withOpacity(0.3))
            : null,
      ),
      child: Row(
        children: [
          // Rank and Trend
          Column(
            children: [
              Text(
                '${user.rank}${_getOrdinalSuffix(user.rank)}',
                style: TextStyle(
                  color: Color(0xFF9B59B6),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4),
              Icon(
                user.trend == TrendType.up 
                    ? Icons.keyboard_arrow_up 
                    : Icons.keyboard_arrow_down,
                color: user.trend == TrendType.up 
                    ? Colors.orange 
                    : Colors.grey,
                size: 20,
              ),
            ],
          ),
          
          SizedBox(width: 16),
          
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: ClipOval(
              child: Icon(
                Icons.person,
                size: 30,
                color: Colors.grey[600],
              ),
            ),
          ),
          
          SizedBox(width: 16),
          
          // Name
          Expanded(
            child: Text(
              user.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          
          // Score
          Text(
            user.score.toString(),
            style: TextStyle(
              color: Color(0xFF9B59B6),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) {
      return 'th';
    }
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}

// Data Models
class LeaderboardUser {
  final int rank;
  final String name;
  final int score;
  final String avatar;
  final bool isCurrentUser;
  final TrendType trend;

  LeaderboardUser({
    required this.rank,
    required this.name,
    required this.score,
    required this.avatar,
    required this.isCurrentUser,
    required this.trend,
  });
}

enum TrendType { up, down }