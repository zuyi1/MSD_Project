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
  double _previousTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _loadLogs();
    AnalyticsService.logScreenView('WaterLogScreen');
  }

  Future<void> _loadLogs() async {
    final logs = await _dbService.getWaterLogs();
    if (mounted) {
      setState(() {
        _previousTotal = _calculateTodayTotal(_logs);
        _logs = logs;
      });
    }
  }

  double _calculateTodayTotal(List<WaterLog> logs) {
    return logs
        .where((log) =>
            log.dateTime.day == DateTime.now().day &&
            log.dateTime.month == DateTime.now().month &&
            log.dateTime.year == DateTime.now().year)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> _addWater(double amount) async {
    final log = WaterLog(amount: amount, dateTime: DateTime.now());
    await _dbService.insertWaterLog(log);
    await AnalyticsService.logEvent(name: 'add_water_log', parameters: {'amount': amount});
    
    final oldTotal = _calculateTodayTotal(_logs);
    await _loadLogs();
    final newTotal = _calculateTodayTotal(_logs);

    if (newTotal >= _dailyGoal && oldTotal < _dailyGoal) {
      if (mounted) {
        _showGoalReachedDialog();
      }
    }
  }

  void _showGoalReachedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Center(
          child: Text('🎉 Good Job!', 
            style: TextStyle(color: Color(0xFF6A5AE0), fontWeight: FontWeight.bold, fontSize: 24)
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.stars, color: Color(0xFFEFFF5E), size: 80),
            SizedBox(height: 16),
            Text('You have reached your daily hydration goal. Stay healthy!', 
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF2D2E42), fontSize: 16),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A5AE0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep it up!'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double todayTotal = _calculateTodayTotal(_logs);
    double progress = (todayTotal / _dailyGoal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Hydration Tracker', style: TextStyle(color: Color(0xFF2D2E42), fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: _previousTotal / _dailyGoal, end: progress),
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeOutCirc,
                  builder: (context, value, child) {
                    return SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 15,
                        strokeCap: StrokeCap.round,
                        backgroundColor: const Color(0xFFF8F9FE),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6A5AE0)),
                      ),
                    );
                  },
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.water_drop, size: 40, color: Color(0xFF6A5AE0)),
                    Text('${todayTotal.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Color(0xFF2D2E42))),
                    Text('of ${_dailyGoal.toStringAsFixed(0)} ml',
                        style: TextStyle(fontSize: 14, color: Colors.grey[400])),
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
          const SizedBox(height: 40),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 24),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FE),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 8),
                    child: Text('Recent History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D2E42))),
                  ),
                  Expanded(
                    child: _logs.isEmpty 
                      ? const Center(child: Text('No water logged today', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            final log = _logs[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF6A5AE0).withOpacity(0.1),
                                  child: const Icon(Icons.water_drop, color: Color(0xFF6A5AE0), size: 18),
                                ),
                                title: Text('${log.amount.toStringAsFixed(0)} ml',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D2E42))),
                                subtitle: Text(DateFormat('h:mm a').format(log.dateTime),
                                    style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                              ),
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
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 6)),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF6A5AE0), size: 28),
          ),
        ),
        const SizedBox(height: 10),
        Text('${amount.toStringAsFixed(0)}ml',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2D2E42))),
      ],
    );
  }
}
