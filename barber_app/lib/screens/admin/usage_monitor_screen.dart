import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../utils/constants.dart';
import '../../utils/firebase_config.dart';

class UsageMonitorScreen extends StatefulWidget {
  const UsageMonitorScreen({Key? key}) : super(key: key);

  @override
  State<UsageMonitorScreen> createState() => _UsageMonitorScreenState();
}

class _UsageMonitorScreenState extends State<UsageMonitorScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, dynamic> _usageStats = {};
  
  @override
  void initState() {
    super.initState();
    _loadUsageStats();
  }
  
  void _loadUsageStats() {
    setState(() {
      _usageStats = _firebaseService.getUsageStats();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text('Monitoramento de Uso'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsageStats,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Uso do Firebase',
              style: AppTextStyles.heading,
            ),
            const SizedBox(height: 8),
            const Text(
              'Monitore o uso dos recursos do Firebase para evitar custos inesperados.',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 24),
            
            // Firestore Reads
            _buildUsageCard(
              title: 'Leituras do Firestore',
              current: _usageStats['dailyReads'] ?? 0,
              max: FirebaseConfig.maxFirestoreReadsPerDay,
              percentage: double.tryParse(_usageStats['readsPercentage'] ?? '0') ?? 0,
              icon: Icons.book,
              color: Colors.blue,
            ),
            
            // Firestore Writes
            _buildUsageCard(
              title: 'Gravações do Firestore',
              current: _usageStats['dailyWrites'] ?? 0,
              max: FirebaseConfig.maxFirestoreWritesPerDay,
              percentage: double.tryParse(_usageStats['writesPercentage'] ?? '0') ?? 0,
              icon: Icons.edit,
              color: Colors.green,
            ),
            
            // Firestore Deletes
            _buildUsageCard(
              title: 'Exclusões do Firestore',
              current: _usageStats['dailyDeletes'] ?? 0,
              max: FirebaseConfig.maxFirestoreDeletesPerDay,
              percentage: double.tryParse(_usageStats['deletesPercentage'] ?? '0') ?? 0,
              icon: Icons.delete,
              color: Colors.red,
            ),
            
            // Storage Uploads
            _buildUsageCard(
              title: 'Uploads do Storage',
              current: _usageStats['dailyUploads'] ?? 0,
              max: FirebaseConfig.maxStorageUploadsPerDay,
              percentage: double.tryParse(_usageStats['uploadsPercentage'] ?? '0') ?? 0,
              icon: Icons.upload,
              color: Colors.orange,
            ),
            
            // Storage Downloads
            _buildUsageCard(
              title: 'Downloads do Storage',
              current: '${_usageStats['dailyDownloadsMB'] ?? 0} MB',
              max: '${FirebaseConfig.maxStorageDownloadsPerDayMB} MB',
              percentage: double.tryParse(_usageStats['downloadsPercentage'] ?? '0') ?? 0,
              icon: Icons.download,
              color: Colors.purple,
            ),
            
            // Authentication
            _buildUsageCard(
              title: 'Autenticações',
              current: _usageStats['monthlyAuthentications'] ?? 0,
              max: FirebaseConfig.maxAuthenticationsPerMonth,
              percentage: double.tryParse(_usageStats['authenticationsPercentage'] ?? '0') ?? 0,
              icon: Icons.person,
              color: Colors.teal,
              isMonthly: true,
            ),
            
            const SizedBox(height: 24),
            
            // Last reset
            if (_usageStats['lastReset'] != null)
              Text(
                'Última atualização: ${_formatDateTime(_usageStats['lastReset'])}',
                style: AppTextStyles.caption,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUsageCard({
    required String title,
    required dynamic current,
    required dynamic max,
    required double percentage,
    required IconData icon,
    required Color color,
    bool isMonthly = false,
  }) {
    final Color progressColor = percentage < 50 ? Colors.green :
                               percentage < 80 ? Colors.orange : Colors.red;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isMonthly ? 'Mensal' : 'Diário',
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$current / $max',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _formatDateTime(String isoString) {
    final dateTime = DateTime.parse(isoString);
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}