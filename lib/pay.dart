import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:text/payment.dart';

class UPIPaymentPage extends StatefulWidget {
  final String recipientName;
  final String amount;
  final String accountNumber;

  const UPIPaymentPage({
    Key? key,
    required this.recipientName,
    required this.amount,
    required this.accountNumber,
  }) : super(key: key);

  @override
  _UPIPaymentPageState createState() => _UPIPaymentPageState();
}

class _UPIPaymentPageState extends State<UPIPaymentPage> {
  final List<String> _pin = ['', '', '', ''];
  int _currentPinIndex = 0;
  bool _isPinComplete = false;
  String? _storedPin;
  bool _isLoading = false;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();


  @override
  void initState() {
    super.initState();
    _loadStoredPin();
  }

  Future<void> _loadStoredPin() async {
  final pin = await secureStorage.read(key: 'pin');
  setState(() {
    _storedPin = pin ?? '1234'; // Default PIN for demo
  });
}


  void _enterDigit(String digit) {
    if (_currentPinIndex < 4) {
      setState(() {
        _pin[_currentPinIndex] = digit;
        _currentPinIndex++;
        _isPinComplete = _currentPinIndex == 4;
      });
    }
  }

  void _removeDigit() {
    if (_currentPinIndex > 0) {
      setState(() {
        _currentPinIndex--;
        _pin[_currentPinIndex] = '';
        _isPinComplete = false;
      });
    }
  }

  // Function to submit payment data to the API
  Future<bool> _submitPaymentToAPI() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Replace with your actual API endpoint
      final apiUrl = 'https://empjewellery.shop/processPayment';
      
      // Prepare payment data
      final paymentData = {
        'schemeAmount': widget.amount,
        'customerId': widget.accountNumber,
      };

      // Make POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_KEY', // Replace with your API key if needed
        },
        body: jsonEncode(paymentData),
      );

      setState(() {
        _isLoading = false;
      });

      // Check response status
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Successfully submitted
        return true;
      } else {
        // API returned an error
        print('API Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      // Exception occurred
      print('Exception during API call: $e');
      setState(() {
        _isLoading = false;
      });
      return false;
    }
  }

  void _submitPin() async {
    String enteredPin = _pin.join();

    // Check if PIN matches stored PIN
    if (_storedPin != null && enteredPin == _storedPin) {
      // PIN matches, process payment via API
      final success = await _submitPaymentToAPI();
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successfully submitted!')),
        );
        Navigator.pop(context, true); // Return success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment failed. Please try again later.')),
        );
        // Reset PIN
        _resetPin();
      }
    } else {
      // PIN doesn't match
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect PIN! Please try again.')),
      );
      // Reset PIN
      _resetPin();
    }
  }

  void _resetPin() {
    setState(() {
      _pin.fillRange(0, 4, '');
      _currentPinIndex = 0;
      _isPinComplete = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    
    // Responsive sizing
    final pinDotSize = screenWidth * 0.06; // 6% of screen width
// 6% of screen height
    final fontSize = screenWidth * 0.04; // 4% of screen width

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () { 
              Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PaymentPage()),
      );
           },
          
        ),
        title: const Text(
          'CANCEL',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    // Bank info and recipient section
                    Container(
                      width: constraints.maxWidth,
                      padding: EdgeInsets.all(screenWidth * 0.04), // 4% padding
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'EMP GOLD',
                                    style: TextStyle(
                                      fontSize: fontSize * 1.1,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    widget.accountNumber.length > 4 
                                        ? 'XXXX${widget.accountNumber.substring(widget.accountNumber.length - 4)}'
                                        : widget.accountNumber,
                                    style: TextStyle(
                                      fontSize: fontSize * 1.1,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              CircleAvatar(
                                radius: screenWidth * 0.04, // 4% of screen width
                                backgroundImage: const AssetImage('assets/images/logo23.png'),
                                // If the image is not available, use a fallback
                                onBackgroundImageError: (e, s) => {},
                                child: const AssetImage('assets/images/logo23.png') == null 
                                    ? Icon(Icons.account_balance, color: Colors.white) 
                                    : null,
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02), // 2% of screen height
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('To:', style: TextStyle(fontSize: fontSize)),
                              Expanded(
                                child: Text(
                                  widget.recipientName,
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.01), // 1% of screen height
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Sending:', style: TextStyle(fontSize: fontSize)),
                              Text(
                                '₹ ${widget.amount}',
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // PIN entry section
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.06, // 6% of screen width
                          vertical: screenHeight * 0.04, // 4% of screen height
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ENTER 4-DIGIT PIN',
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.03), // 3% of screen height

                            // PIN circles row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                4,
                                (index) => Container(
                                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                                  width: pinDotSize,
                                  height: pinDotSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey.shade400),
                                    color: _pin[index].isNotEmpty
                                        ? Colors.black
                                        : Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Keypad - Using GridView for better responsiveness
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02, // 2% of screen width
                        vertical: screenHeight * 0.01, // 1% of screen height
                      ),
                      child: Column(
                        children: [
                          _buildKeypadRow(['1', '2', '3'], screenSize),
                          _buildKeypadRow(['4', '5', '6'], screenSize),
                          _buildKeypadRow(['7', '8', '9'], screenSize),
                          Row(
                            children: [
                              _buildKeypadButton(
                                'X',
                                screenSize,
                                isSpecial: true,
                                onPressed: _removeDigit,
                              ),
                              _buildKeypadButton('0', screenSize),
                              _buildKeypadButton(
                                'SUBMIT',
                                screenSize,
                                isSpecial: true,
                                enabled: _isPinComplete && !_isLoading,
                                onPressed: _isPinComplete && !_isLoading ? _submitPin : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Bottom bar
                    Container(
                      height: screenHeight * 0.005, // 0.5% of screen height
                      width: screenWidth * 0.25, // 25% of screen width
                      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.02), // 2% of screen height
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(screenHeight * 0.0025), // Half of height
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> buttons, Size screenSize) {
    return Row(
      children: buttons.map((button) => 
        _buildKeypadButton(button, screenSize)
      ).toList(),
    );
  }

  Widget _buildKeypadButton(
    String text,
    Size screenSize, {
    bool isSpecial = false,
    bool enabled = true,
    VoidCallback? onPressed,
  }) {
    final buttonHeight = screenSize.height * 0.06; // 6% of screen height
    final fontSize = screenSize.width * 0.04; // 4% of screen width
    
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(screenSize.width * 0.012), // Responsive margin
        height: buttonHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(buttonHeight / 2), // Rounded corners
          border: Border.all(color: Colors.grey.shade300, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: TextButton(
          onPressed: onPressed ?? (enabled
              ? () {
                  if (!isSpecial) _enterDigit(text);
                }
              : null),
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(buttonHeight / 2),
            ),
            padding: EdgeInsets.zero, // Removing padding to control button size better
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              style: TextStyle(
                fontSize: isSpecial ? (text == 'SUBMIT' ? fontSize * 0.85 : fontSize * 1.1) : fontSize * 1.5,
                fontWeight: isSpecial ? FontWeight.bold : FontWeight.normal,
                color: enabled ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}