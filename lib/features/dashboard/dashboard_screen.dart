import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/app_drawer.dart';
import 'dashboard_provider.dart';
import '../profile/profile_screen.dart';
import 'chart_generator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DashboardProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<DashboardProvider>();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: SafeArea(
          child: Container(
            color: kNavy,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
                Image.asset('assets/logo/autohive_logo.png', height: 32),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Dashboard',
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
      body: RefreshIndicator(
        onRefresh: p.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Top row: KPI card + Pie chart
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _KpiCard(
                      available: p.available,
                      inUse: p.inUse,
                      maintenance: p.maintenance,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PieCard(
                      available: p.available,
                      inUse: p.inUse,
                      maintenance: p.maintenance,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Middle: charts
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _ChartCard(
                      title: 'Bookings per Day',
                      child: LineChart(
                        dataPoints: const [5, 8, 12, 15, 18, 22, 25],
                        title: 'Trend',
                        lineColor: const Color(0xFF1976D2),
                        fillColor: const Color(0xff1976d235),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ChartCard(
                      title: 'Revenue Trend',
                      child: LineChart(
                        dataPoints: const [
                          2000,
                          2500,
                          3200,
                          3800,
                          4500,
                          5200,
                          6000,
                        ],
                        title: 'Amount (\$)',
                        lineColor: const Color(0xFF2E7D32),
                        fillColor: const Color(0xff2e7d3235),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final int available, inUse, maintenance;
  const _KpiCard({
    required this.available,
    required this.inUse,
    required this.maintenance,
  });

  @override
  Widget build(BuildContext context) {
    Text row(String label, int value, Color color) => Text(
      '$label   $value',
      style: TextStyle(
        color: color,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.6,
      ),
    );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        padding: const EdgeInsets.all(12),
        color: const Color(0xFFEDEDED),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(icon: Icons.dashboard, title: 'Fleet KPIs'),
            const SizedBox(height: 8),
            row('Available', available, const Color(0xFF2E7D32)),
            row('In use', inUse, const Color(0xFFEF6C00)),
            row('Maintenance', maintenance, const Color(0xFFC62828)),
          ],
        ),
      ),
    );
  }
}

class _PieCard extends StatelessWidget {
  final int available, inUse, maintenance;
  const _PieCard({
    required this.available,
    required this.inUse,
    required this.maintenance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        color: const Color(0xFFEDEDED),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              icon: Icons.pie_chart,
              title: 'Fleet Distribution',
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 160,
              child: Center(
                child: _PieChart(
                  values: [
                    available.toDouble(),
                    inUse.toDouble(),
                    maintenance.toDouble(),
                  ],
                  colors: const [
                    Color(0xFF2E7D32),
                    Color(0xFFEF6C00),
                    Color(0xFFC62828),
                  ],
                  labels: const ['Available', 'In Use', 'Maintenance'],
                ),
              ),
            ),
            const SizedBox(height: 8),
            _PieLegend(
              items: [
                _LegendItem('Available', available, const Color(0xFF2E7D32)),
                _LegendItem('In Use', inUse, const Color(0xFFEF6C00)),
                _LegendItem(
                  'Maintenance',
                  maintenance,
                  const Color(0xFFC62828),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        color: const Color(0xFFEDEDED),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(icon: Icons.insights, title: title),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _PieChart extends StatelessWidget {
  final List<double> values;
  final List<Color> colors;
  final List<String>? labels;
  const _PieChart({required this.values, required this.colors, this.labels});

  @override
  Widget build(BuildContext context) {
    final total = values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) {
      return Container(
        width: 140,
        height: 140,
        alignment: Alignment.center,
        child: const Text('No data'),
      );
    }
    return CustomPaint(
      size: const Size.square(140),
      painter: _PiePainter(values, colors),
    );
  }
}

class _PiePainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  _PiePainter(this.values, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()..style = PaintingStyle.fill;
    final total = values.fold<double>(0, (a, b) => a + b);
    double start = -90.0;

    for (int i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 360;
      paint.color = i < colors.length ? colors[i] : Colors.grey;
      canvas.drawArc(rect, radians(start), radians(sweep), true, paint);

      final borderPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawArc(rect, radians(start), radians(sweep), true, borderPaint);

      start += sweep;
    }

    final centerPaint = Paint()
      ..color = const Color(0xFFEDEDED)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 35, centerPaint);
  }

  double radians(double deg) => deg * 3.1415926535 / 180.0;

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.colors != colors;
}

class _LegendItem {
  final String label;
  final int value;
  final Color color;
  _LegendItem(this.label, this.value, this.color);
}

class _PieLegend extends StatelessWidget {
  final List<_LegendItem> items;
  const _PieLegend({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: items
          .map(
            (item) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${item.label}: ${item.value}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}
