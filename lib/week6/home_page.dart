// home_page.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'login_page.dart'; // Import login page untuk navigasi setelah logout
import 'profile_page.dart'; // Import halaman profil
import 'dart:math';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kawaii Ramen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomePage(),
    );
  }
}

class MidtransService {
  static const String _baseUrl = "https://app.sandbox.midtrans.com";
  // Ganti dengan Server Key Anda
  static const String _serverKey =
      "SB-Mid-server-i4pgFCgKq3Or5tRtrnTQl1gn"; // ganti server key

  static Future<String?> getSnapToken(
      Map<String, dynamic> transactionDetails) async {
    final url = Uri.parse("$_baseUrl/snap/v1/transactions");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Basic ${base64Encode(utf8.encode('$_serverKey:'))}",
        },
        body: jsonEncode(transactionDetails),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (kDebugMode) {
          print(response.statusCode);
        }
        if (kDebugMode) {
          print(response.body);
        }
        return data['token']; // Kembalikan Snap Token
      } else {
        if (kDebugMode) {
          print("Error: ${response.body}");
        }
        if (kDebugMode) {
          print(response.statusCode);
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception: $e");
      }
      return null;
    }
  }
}

class User {
  final String name;

  User(this.name);
}

// Fungsi untuk mengambil username dari shared_preferences
Future<User> fetchUser() async {
  final prefs = await SharedPreferences.getInstance();
  final username = prefs.getString('username') ?? 'Guest';
  return User(username);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<String, int> _orderCounts = {};
  final Map<String, int> _menuPrices = {
    'Curry Ramen': 40000,
    'Ramen Udon': 34000,
    'Kurume Ramen': 45000,
    'Shoyu Ramen': 48000,
    'Spicy Ramen': 50000,
    'Ocha': 15000,
    'Ice Tea': 10000,
    'Lemon Tea': 15000,
    'Teh Tarik': 16000,
    'Strawberry Juice': 20000,
    'Mineral Water': 8000,
  };
  int _totalPrice = 0;

  void _addOrder(String name) {
    setState(() {
      _orderCounts[name] = (_orderCounts[name] ?? 0) + 1;
      _totalPrice += _menuPrices[name]!;
    });
  }

  void _removeOrder(String name) {
    setState(() {
      if ((_orderCounts[name] ?? 0) > 0) {
        _orderCounts[name] = _orderCounts[name]! - 1;
        _totalPrice -= _menuPrices[name]!;
      }
    });
  }

  void _navigateToOrderConfirmation() {
    if (_totalPrice == 0) {
      // Tampilkan pesan jika tidak ada pesanan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda belum memesan apapun.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationScreen(
          orders: _orderCounts,
          totalPrice: _totalPrice,
          menuPrices: _menuPrices,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<User>(
          future: fetchUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error fetching user data'));
            } else {
              final user = snapshot.data!;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Bagian Top Bar
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Tombol Profile menggantikan CircleAvatar
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ProfilePage()),
                                  );
                                },
                                icon:
                                    const Icon(Icons.person, color: Colors.red),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Halo, ${user.name}!',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              // Tombol Log out
                              IconButton(
                                onPressed: () async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.remove('username');
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LogInPage()),
                                  );
                                },
                                icon:
                                    const Icon(Icons.logout, color: Colors.red),
                                tooltip: 'Logout',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Promo Banner
                    Image.asset(
                      'assets/images/banner.png',
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 150,
                          color: const Color(0xFFA61B1B),
                          child: const Center(
                            child: Text(
                              'Banner Image Not Found',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),

                    // Menu Section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: const Text(
                              'Our Menu',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: _menuPrices.keys.map((menu) {
                              return _buildMenuItem(menu, _menuPrices[menu]!);
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    'Rp$_totalPrice',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _navigateToOrderConfirmation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Checkout',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String name, int price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            _getImagePath(name),
            width: 72,
            height: 72,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey[300],
                child: const Icon(Icons.restaurant, color: Colors.grey),
              );
            },
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'Rp$price',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _removeOrder(name),
              icon: const Icon(Icons.remove, color: Colors.red),
            ),
            Text(_orderCounts[name]?.toString() ?? '0'),
            IconButton(
              onPressed: () => _addOrder(name),
              icon: const Icon(Icons.add, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  String _getImagePath(String name) {
    switch (name) {
      case 'Curry Ramen':
        return 'assets/images/curry.png';
      case 'Ramen Udon':
        return 'assets/images/udon.png';
      case 'Kurume Ramen':
        return 'assets/images/kurume.png';
      case 'Shoyu Ramen':
        return 'assets/images/shoyu.png';
      case 'Spicy Ramen':
        return 'assets/images/spicy.png';
      case 'Ocha':
        return 'assets/images/ocha.png';
      case 'Ice Tea':
        return 'assets/images/tea.png';
      case 'Lemon Tea':
        return 'assets/images/lemon.png';
      case 'Teh Tarik':
        return 'assets/images/tehtarik.png';
      case 'Strawberry Juice':
        return 'assets/images/strawberry.png';
      case 'Mineral Water':
        return 'assets/images/water.png';
      default:
        return 'assets/images/default.png';
    }
  }
}

// Ubah OrderConfirmationScreen menjadi StatefulWidget
class OrderConfirmationScreen extends StatefulWidget {
  final Map<String, int> orders;
  final int totalPrice;
  final Map<String, int> menuPrices;

  OrderConfirmationScreen({
    super.key,
    required this.orders,
    required this.totalPrice,
    required this.menuPrices,
  });

  @override
  _OrderConfirmationScreenState createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  late WebViewController _webViewController;
  bool _isLoading = false;

  // Data transaksi
  Map<String, dynamic> getTransactionDetails() {
    return {
      "transaction_details": {
        "order_id": "order-${DateTime.now().millisecondsSinceEpoch}", // Unik
        "gross_amount": widget.totalPrice, // Jumlah pembayaran
      },
      "customer_details": {
        "first_name": widget.orders.keys.first, // Contoh nama pelanggan
        "email":
            "jenruby@xyz.com", // Ganti dengan email pelanggan yang sebenarnya
      }
    };
  }

  void handlePayment() async {
    setState(() {
      _isLoading = true;
    });

    // Panggil API Midtrans untuk mendapatkan Snap Token
    final snapToken =
        await MidtransService.getSnapToken(getTransactionDetails());

    setState(() {
      _isLoading = false;
    });

    if (snapToken != null) {
      openPaymentWebView(snapToken);
    } else {
      if (kDebugMode) {
        print("Gagal mendapatkan Snap Token");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memproses pembayaran.')),
      );
    }
  }

  void openPaymentWebView(String snapToken) {
    final snapUrl = "https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken";

    // Inisialisasi WebViewController
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // Logika setelah halaman selesai dimuat
            if (url.contains("payment-success")) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderReceivedScreen(
                    tableNumber:
                        Random().nextInt(20) + 1, // Generate nomor meja baru
                  ),
                ),
              );
            } else if (url.contains("payment-error")) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pembayaran gagal.')),
              );
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(snapUrl));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text("Midtrans Payment"),
          ),
          body: WebViewWidget(
            controller: _webViewController,
          ),
        ),
      ),
    );
  }

  // Add new method to filter orders
  Map<String, int> get filteredOrders {
    return Map.fromEntries(
        widget.orders.entries.where((entry) => entry.value > 0));
  }

  @override
  Widget build(BuildContext context) {
    final activeOrders = filteredOrders; // Get only active orders

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Order Confirmation'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.table_restaurant, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        'Table Number: ${Random().nextInt(20) + 1}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Order Details:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                activeOrders.isEmpty
                    ? const Center(
                        child: Text(
                          'No items ordered yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView(
                          children: activeOrders.entries.map((entry) {
                            final totalItemPrice =
                                entry.value * widget.menuPrices[entry.key]!;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(
                                  entry.key,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('Quantity: ${entry.value}'),
                                trailing: Text(
                                  'Rp$totalItemPrice',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                const Divider(thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Payment:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
                    Text('Rp${widget.totalPrice}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        )),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              handlePayment();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Confirm Order',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

// OrderReceivedScreen remains the same
class OrderReceivedScreen extends StatelessWidget {
  final int tableNumber;

  const OrderReceivedScreen({
    super.key,
    required this.tableNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Order Received',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Table Number: $tableNumber',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your order has been received\nand will be coming soon prepared\nplease wait...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
