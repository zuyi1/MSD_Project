import 'package:flutter/material.dart';
import '../models/water_log.dart';
import '../services/database_service.dart';
import '../services/analytics_service.dart';
import 'package:intl/intl.dart';

class WaterLogScreen extends StatefulWidget {
  const WaterLogScreen({super.key});

  @override
  State<WaterLogScreen> createState() => _WaterLogScreenState();
}

class _WaterLogScreenState extends State<WaterLogScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<WaterLog> _logs = [];
  final double _dailyGoal = 2000.0; // ml

  @override
  void initState() {
    super.initState();
    _loadLogs();
    AnalyticsService.logScreenView('WaterLogScreen');
  }

  Future<void> _loadLogs() async {
    final logs = await _dbService.getWaterLogs();
    setState(() {
      _logs = logs;
    });
  }

  Future<void> _addWater(double amount) async {
    final log = WaterLog(amount: amount, dateTime: DateTime.now());
    await _dbService.insertWaterLog(log);
    await AnalyticsService.logEvent(name: 'add_water_log', parameters: {'amount': amount});
    _loadLogs();
  }

  @override
  Widget build(BuildContext context) {
    double todayTotal = _logs
        .where((log) =>
            log.dateTime.day == DateTime.now().day &&
            log.dateTime.month == DateTime.now().month &&
            log.dateTime.year == DateTime.now().year)
        .fold(0.0, (sum, item) => sum + item.amount);

    double progress = (todayTotal / _dailyGoal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Hydration Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.blue[900],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: Colors.blue[100],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.water_drop, size: 40, color: Colors.blue[600]),
                    Text('${todayTotal.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                    Text('of ${_dailyGoal.toStringAsFixed(0)} ml',
                        style: TextStyle(fontSize: 14, color: Colors.blue[400])),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildWaterButton(100, Icons.local_drink),
                _buildWaterButton(250, Icons.coffee),
                _buildWaterButton(500, Icons.opacity),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                    child: Text('History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[50],
                            child: Icon(Icons.water_drop, color: Colors.blue[600], size: 18),
                          ),
                          title: Text('${log.amount.toStringAsFixed(0)} ml',
                              style: const TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text(DateFormat('MMM d, h:mm a').format(log.dateTime),
                              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterButton(double amount, IconData icon) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _addWater(amount),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(icon, color: Colors.blue[600], size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text('${amount.toStringAsFixed(0)}ml',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue[900])),
      ],
    );
  }
}
