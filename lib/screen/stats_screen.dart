import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wolfmobile/API/APIService.dart';
import 'package:wolfmobile/screen/home_screen.dart';

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final APIService _apiService = APIService();
  Map<String, dynamic> _stats = {};
  String _statusMessage = '';
  Color _statusMessageColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final stats = await _apiService.getStats();  // Assuming getStats returns a Map
      setState(() {
        _stats = stats;  // Update state with stats data
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro ao carregar os dados: $e';
        _statusMessageColor = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Indicadores',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI - Total
            _buildKpiCard('Total', _stats['total']?.toString() ?? '0', Colors.teal, Icons.bar_chart),
            const SizedBox(height: 16),

            // KPI - Last Month
            _buildKpiCard('Último Mês', _stats['last_month']?.toString() ?? '0', Colors.orange, Icons.calendar_today),
            const SizedBox(height: 16),

            // KPI - Last Week
            _buildKpiCard('Última Semana', _stats['last_week']?.toString() ?? '0', Colors.blue, Icons.access_time),
            const SizedBox(height: 16),

            // KPI - Last Day
            _buildKpiCard('Último Dia', _stats['last_day']?.toString() ?? '0', Colors.green, Icons.today),
            const SizedBox(height: 16),

            // Last Occurrence Field (Modified to use Wrap)
            Wrap(
              children: [
                Text(
                  'Última Ocorrência: ',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  _stats['last_occurrence'] ?? 'N/A',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status Message
            Text(
              _statusMessage,
              style: TextStyle(
                color: _statusMessageColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build a KPI card with styling
  Widget _buildKpiCard(String label, String value, Color color, IconData icon) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}