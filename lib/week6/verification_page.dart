// verification_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart'; // Pastikan path ini benar

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _otpRequested = false;
  bool _isLoading = false;

  // Fungsi untuk meminta OTP
  Future<void> requestOtp() async {
    const String apiUrl =
        "http://10.0.2.2/verification/otp.php"; // Sesuaikan path jika diperlukan

    String phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan isi nomor telepon Anda')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'submit-otp': 'true',
          'nomor': phoneNumber,
        },
      );

      final result = json.decode(response.body);
      if (!mounted) return;

      if (response.statusCode == 200 && result['success'] != null) {
        setState(() {
          _otpRequested = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['success'] ?? 'OTP telah dikirim!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Gagal meminta OTP.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat meminta OTP!')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk memverifikasi OTP
  Future<void> verifyOtp() async {
    const String apiUrl =
        "http://10.0.2.2/verification/otp.php"; // Sesuaikan path jika diperlukan

    String phoneNumber = _phoneController.text.trim();
    String otp = _otpController.text.trim();

    if (phoneNumber.isEmpty || otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan isi nomor telepon dan OTP')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'submit-login': 'true',
          'nomor': phoneNumber,
          'otp': otp,
        },
      );

      final result = json.decode(response.body);
      if (!mounted) return;

      if (response.statusCode == 200 && result['status'] == 'success') {
        // Navigasi ke HomePage setelah OTP diverifikasi
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'OTP tidak valid.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Terjadi kesalahan saat memverifikasi OTP!')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk mengirim ulang OTP
  Future<void> resendOtp() async {
    await requestOtp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Menghilangkan panah kembali
        elevation: 0, // Menghilangkan bayangan bawah AppBar jika diinginkan
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Gambar Logo atau Ilustrasi (Opsional)
              Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/images/otp.png'), // Pastikan path benar
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Judul
              const Text(
                'OTP Verification',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),

              // Deskripsi
              const Text(
                'We will send you a One Time OTP Code on your phone number \n And you will get an OTP via Whatsapp',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 40),

              // Input Nomor Telepon
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Enter your phone number',
                  hintText: '62XXXXXXXXXXX',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              // Tombol Get OTP atau Verify OTP
              _otpRequested
                  ? Column(
                      children: [
                        // Input OTP
                        TextField(
                          controller: _otpController,
                          decoration: const InputDecoration(
                            labelText: 'Enter OTP code',
                            hintText: 'XXXXXX',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),

                        // Tombol Verify OTP
                        _isLoading
                            ? const CircularProgressIndicator()
                            : GestureDetector(
                                onTap: verifyOtp,
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFEB221E),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Verify OTP',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        const SizedBox(height: 20),

                        // Teks Resend OTP dengan "Didn't get a code?" berwarna hitam dan "Resend" berwarna biru
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Didn't get a code? ",
                              style: TextStyle(
                                color: Colors
                                    .black, // Warna hitam untuk teks pertama
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            GestureDetector(
                              onTap:
                                  resendOtp, // Fungsi yang dipanggil saat "Resend" ditekan
                              child: const Text(
                                "Resend",
                                style: TextStyle(
                                  color:
                                      Colors.blue, // Warna biru untuk teks link
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                  decoration: TextDecoration
                                      .underline, // Garis bawah untuk menunjukkan link
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : _isLoading
                      ? const CircularProgressIndicator()
                      : GestureDetector(
                          onTap: requestOtp,
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFEB221E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Get OTP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
