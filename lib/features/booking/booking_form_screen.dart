import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import 'booking_form_provider.dart';
import 'booking_payment_form_screen.dart';
import '../profile/profile_screen.dart';

class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({super.key});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final p = context.read<BookingFormProvider>();
      p.reset();
      p.loadVehicles();
    });
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<BookingFormProvider>();

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
                    'Car Rental Booking Form',
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
            // Chips (visual only - Check-in only)
            Row(children: [_pill('Check-in', const Color(0xFF2E7D32))]),
            const SizedBox(height: 16),

            _section('Car Type'),
            _roundedField(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: p.carType,
                  hint: const Text('Select type'),
                  isExpanded: true,
                  items: const ['Sedan', 'SUV', 'Hatchback']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: p.setCarType,
                ),
              ),
            ),
            const SizedBox(height: 12),

            _section('Car Brand'),
            _roundedField(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: p.vehicleId,
                  hint: const Text('Select vehicle'),
                  isExpanded: true,
                  items: p.vehicles
                      .map(
                        (m) => DropdownMenuItem<int>(
                          value: m['id'] as int,
                          child: Text(m['label'] as String),
                        ),
                      )
                      .toList(),
                  onChanged: p.setVehicle,
                ),
              ),
            ),
            const SizedBox(height: 16),

            _section('Available Dates'),
            Row(
              children: [
                Expanded(
                  child: _dateField(
                    label: 'Start Date',
                    value: p.startDate,
                    onPick: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: p.startDate ?? now,
                        firstDate: DateTime(now.year, now.month, now.day),
                        lastDate: DateTime(now.year + 2),
                      );
                      if (picked != null) {
                        p.setStart(
                          DateTime(picked.year, picked.month, picked.day),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dateField(
                    label: 'End Date',
                    value: p.endDate,
                    onPick: () async {
                      final start = p.startDate ?? DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: p.endDate ?? start,
                        firstDate: start,
                        lastDate: DateTime(DateTime.now().year + 2),
                      );
                      if (picked != null) {
                        p.setEnd(
                          DateTime(picked.year, picked.month, picked.day),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _section('Your Details'),
            _roundedField(
              child: TextField(
                controller: nameCtrl,
                onChanged: p.setName,
                decoration: const InputDecoration(
                  hintText: 'Full name',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _roundedField(
              child: TextField(
                controller: emailCtrl,
                onChanged: p.setEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email Address',
                  border: InputBorder.none,
                  errorText: p.getEmailError(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _roundedField(
              child: TextField(
                controller: phoneCtrl,
                onChanged: p.setPhone,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'Phone number (8 digits)',
                  border: InputBorder.none,
                  errorText: p.getPhoneError(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Price preview
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Estimated Price: ${p.days} day(s) × ${BookingFormProvider.dailyRate} = ${p.price}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: kCyan,
                  foregroundColor: Colors.white,
                ),
                onPressed: !p.loading
                    ? () async {
                        // Validate name and dates
                        if (nameCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter your full name'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }
                        if (p.startDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a start date'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }
                        if (p.endDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select an end date'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }

                        // overlap check
                        if (await p.hasOverlap()) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'This vehicle is already booked for the selected dates.',
                              ),
                            ),
                          );
                          return;
                        }
                        // Navigate to payment form instead of immediately submitting
                        if (!mounted) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BookingPaymentFormScreen(
                              vehicleId: p.vehicleId!,
                              carType: p.carType ?? 'Unknown',
                              carBrand:
                                  p.vehicles.firstWhere(
                                    (v) => v['id'] == p.vehicleId,
                                    orElse: () => {},
                                  )['label'] ??
                                  'Unknown',
                              pickupDate: p.startDate!,
                              returnDate: p.endDate!,
                              totalPrice: p.price,
                            ),
                          ),
                        );
                      }
                    : null,
                child: p.loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Proceed to Check-out'),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(.15),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontWeight: FontWeight.w700),
    ),
  );

  Widget _section(String title) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
    ),
  );

  Widget _roundedField({required Widget child}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFEDEFF4),
      borderRadius: BorderRadius.circular(12),
    ),
    child: child,
  );

  Widget _dateField({
    required String label,
    required DateTime? value,
    required VoidCallback onPick,
  }) {
    String txt(DateTime? d) {
      if (d == null) return label;
      final y = d.year.toString().padLeft(4, '0');
      final m = d.month.toString().padLeft(2, '0');
      final dd = d.day.toString().padLeft(2, '0');
      return '$dd/$m/$y';
    }

    return _roundedField(
      child: InkWell(
        onTap: onPick,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 18),
              const SizedBox(width: 8),
              Text(txt(value)),
            ],
          ),
        ),
      ),
    );
  }
}
