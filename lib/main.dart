import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

void main() {
  runApp(IIBApp());
}

class IIBApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IIB - International Innovator Bridge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: AgentHomePage(),
    );
  }
}

class AgentHomePage extends StatefulWidget {
  @override
  _AgentHomePageState createState() => _AgentHomePageState();
}

class _AgentHomePageState extends State<AgentHomePage> {
  late Razorpay _razorpay;
  int totalEarnings = 0;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void openCheckout({required int amount, required String planName}) {
    // TODO: உங்கள் Razorpay LIVE Key-ஐ இங்கே போடுங்கள்
    // Razorpay Dashboard -> Settings -> API Keys -> Live Key
    var options = {
      'key': 'rzp_live_YOUR_KEY_HERE', 
      'amount': amount * 100, // 999 Rs = 99900 paise
      'name': 'IIB - International Innovator Bridge',
      'description': planName,
      'prefill': {'contact': '9876543210', 'email': 'agent@iib.com'},
      'external': {'wallets': ['paytm']}
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() {
      totalEarnings += 500; // Agent commission example
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Success: ${response.paymentId} - Amount will go to YOUR Bank Account!"), backgroundColor: Colors.green),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}"), backgroundColor: Colors.red),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("IIB Agent App"), centerTitle: true, backgroundColor: Color(0xFF0A1931), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Color(0xFF0A1931),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("Total Earnings", style: TextStyle(color: Colors.white70)),
                      SizedBox(height: 5),
                      Text("₹ $totalEarnings", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    ]),
                    Icon(Icons.account_balance_wallet, color: Colors.white, size: 40)
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text("IIB Premium Plans - Client Pay to YOU", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _planCard("IIB Starter", "For Students - USA, UK, Canada", 999, Icons.school),
            _planCard("IIB Innovator", "For Job Seekers - Germany, Australia", 1999, Icons.work),
            _planCard("IIB Global", "For Investors - Full Support", 4999, Icons.public),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8)),
              child: Text("Note: Razorpay Live Key add செய்த பிறகு, Client Pay செய்யும் பணம் நேரடியாக உங்கள் Razorpay-ல் இணைக்கப்பட்ட Bank Account-க்கு வரும்.", style: TextStyle(fontSize: 12)),
            )
          ],
        ),
      ),
    );
  }

  Widget _planCard(String title, String desc, int price, IconData icon) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF0A1931), size: 32),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
        trailing: ElevatedButton(
          onPressed: () => openCheckout(amount: price, planName: title),
          child: Text("Pay ₹$price"),
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0A1931), foregroundColor: Colors.white),
        ),
      ),
    );
  }
}
