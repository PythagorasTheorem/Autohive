class Booking {
  final int id;
  final String status;      // confirmed | cancelled | completed
  final String pickupDate;  // YYYY-MM-DD
  final String returnDate;  // YYYY-MM-DD

  Booking({required this.id, required this.status, required this.pickupDate, required this.returnDate});

  factory Booking.fromMap(Map<String, dynamic> m) => Booking(
    id: m['id'] as int,
    status: m['status'] as String,
    pickupDate: m['pickup_date'] as String,
    returnDate: m['return_date'] as String,
  );
}
