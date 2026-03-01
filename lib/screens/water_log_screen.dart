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

    return Scaffold(
      appBar: AppBar(title: const Text('Water Intake Log')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Today\'s Total: ${todayTotal.toStringAsFixed(0)} ml',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: () => _addWater(250), child: const Text('+250ml')),
              ElevatedButton(onPressed: () => _addWater(500), child: const Text('+500ml')),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                return ListTile(
                  leading: const Icon(Icons.water_drop, color: Colors.blue),
                  title: Text('${log.amount.toStringAsFixed(0)} ml'),
                  subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(log.dateTime)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
