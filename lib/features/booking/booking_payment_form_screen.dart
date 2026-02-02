import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import 'booking_form_provider.dart';
import '../profile/profile_screen.dart';

class BookingPaymentFormScreen extends StatefulWidget {
  final int vehicleId;
  final String carType;
  final String carBrand;
  final DateTime pickupDate;
  final DateTime returnDate;
  final int totalPrice;

  const BookingPaymentFormScreen({
    super.key,
    required this.vehicleId,
    required this.carType,
    required this.carBrand,
    required this.pickupDate,
    required this.returnDate,
    required this.totalPrice,
  });

  @override
  State<BookingPaymentFormScreen> createState() =>
      _BookingPaymentFormScreenState();
}

class _BookingPaymentFormScreenState extends State<BookingPaymentFormScreen> {
  String _paymentMethod = 'card'; // card | moijrive | cash
  final _cardNumberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Add listener to format expiry date as user types
    _expiryCtrl.addListener(_formatExpiryDate);
  }

  void _formatExpiryDate() {
    String input = _expiryCtrl.text.replaceAll('/', '');

    if (input.length > 4) {
      input = input.substring(0, 4);
    }

    String formatted = '';
    if (input.length >= 2) {
      formatted = '${input.substring(0, 2)}/${input.substring(2)}';
    } else {
      formatted = input;
    }

    if (_expiryCtrl.text != formatted) {
      _expiryCtrl.value = _expiryCtrl.value.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _expiryCtrl.removeListener(_formatExpiryDate);
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  void _confirmPayment() async {
    if (_paymentMethod == 'card') {
      if (_cardNumberCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter card number')),
        );
        return;
      }
      if (_cardNumberCtrl.text.length < 13) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card number must be at least 13 digits'),
          ),
        );
        return;
      }
      if (_expiryCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter expiry date (MM/YY)')),
        );
        return;
      }
      if (_cvvCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter security code')),
        );
        return;
      }
    }

    setState(() => _loading = true);

    try {
      // Simulate payment processing delay
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful! Booking confirmed.'),
            duration: Duration(seconds: 2),
          ),
        );
        // Pop back to dashboard after success
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final days = widget.returnDate.difference(widget.pickupDate).inDays + 1;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: SafeArea(
          child: Container(
            color: kNavy,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Image.asset('assets/logo/autohive_logo.png', height: 32),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Booking Payment Form',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Booking summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete Your Rental',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _summaryRow('Pickup Date', _formatDate(widget.pickupDate)),
                    _summaryRow('Return Date', _formatDate(widget.returnDate)),
                    _summaryRow('Car Type', widget.carType),
                    _summaryRow('Car Brand', widget.carBrand),
                    _summaryRow('Days', '$days'),
                    const Divider(height: 16),
                    _summaryRow(
                      'Total Price',
                      '₨ ${widget.totalPrice}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment method
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Payment Method',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _paymentMethodButton('Card', 'card'),
                _paymentMethodButton('Juice', 'moijrive'),
                _paymentMethodButton('Cash', 'cash'),
              ],
            ),
            const SizedBox(height: 16),

            // Card details (show only if card is selected)
            if (_paymentMethod == 'card') ...[
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Card Number',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _cardNumberCtrl,
                keyboardType: TextInputType.number,
                maxLength: 16,
                decoration: InputDecoration(
                  hintText: '1234 1234 1234 1234',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Expiration Date',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _expiryCtrl,
                          keyboardType: TextInputType.number,
                          maxLength: 5,
                          inputFormatters: [
                            // Only allow digits and /
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9/]'),
                            ),
                          ],
                          decoration: InputDecoration(
                            hintText: 'MM/YY',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            counterText: '',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Security Code',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _cvvCtrl,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'CVV',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            counterText: '',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ] else if (_paymentMethod == 'moijrive') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Text(
                  'You will be redirected to Juice to complete the payment.',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
            ] else if (_paymentMethod == 'cash') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Text(
                  'Payment will be collected upon pickup. Please bring exact amount.',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Confirm & Pay button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: kNavy,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _loading ? null : _confirmPayment,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Confirm & Pay',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethodButton(String label, String value) {
    final isSelected = _paymentMethod == value;
    return InkWell(
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? kCyan : const Color(0xFFEDEFF4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? kCyan : Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
