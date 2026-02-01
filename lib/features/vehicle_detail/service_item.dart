class ServiceItem {
  final String title;
  final String date; // YYYY-MM-DD
  ServiceItem({required this.title, required this.date});

  factory ServiceItem.fromMap(Map<String, dynamic> m) => ServiceItem(
    title: m['title'] as String,
    date:  m['date']  as String,
  );
}
