import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(AdCarouselApp());
}

class AdCarouselApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AdCarouselWidget(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AdCarouselWidget extends StatefulWidget {
  @override
  _AdCarouselWidgetState createState() => _AdCarouselWidgetState();
}

class _AdCarouselWidgetState extends State<AdCarouselWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> adImages = [
        'assets/images/Brown Classy Jewelry Collection Facebook Ad.png', // Add more asset images as needed

    'assets/images/ads1.png',
    'assets/images/Brown Classy Jewelry Collection Facebook Ad.png', // Add more asset images as needed
    'assets/images/Brown Classy Jewelry Collection Facebook Ad.png',
  ];

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < adImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130, // Increased height to accommodate dots
      child: Column(
        children: [
          // Carousel images
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: adImages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage(adImages[index]),
                      fit: BoxFit.fill,
                    ),
                  ),
                );
              },
            ),
          ),

          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              adImages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 10 : 6,
                height: _currentPage == index ? 10 : 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index ? Colors.black : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}