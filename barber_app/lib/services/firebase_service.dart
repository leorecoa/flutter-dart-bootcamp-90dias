import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/firebase_config.dart';

class FirebaseService {
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Usage tracking
  int _dailyReads = 0;
  int _dailyWrites = 0;
  int _dailyDeletes = 0;
  int _dailyUploads = 0;
  int _dailyDownloadsMB = 0;
  int _monthlyAuthentications = 0;
  DateTime? _lastUsageReset;

  // Getters
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;
  FirebaseMessaging get messaging => _messaging;

  // Initialize Firebase services
  Future<void> init() async {
    // Configure Firestore settings for optimization
    if (FirebaseConfig.enableOfflineData) {
      _firestore.settings = Settings(
        persistenceEnabled: true,
        cacheSizeBytes: FirebaseConfig.cacheSizeBytes,
      );
    }

    // Load usage statistics
    if (FirebaseConfig.enableUsageTracking) {
      await _loadUsageStats();
    }

    // Configure FCM only if enabled
    if (FirebaseConfig.enablePushNotifications) {
      await _configureFCM();
    }
  }

  // Configure Firebase Cloud Messaging
  Future<void> _configureFCM() async {
    // Request notification permissions
    await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Get FCM token
    final fcmToken = await _messaging.getToken();
    print('FCM Token: $fcmToken');

    // Configure FCM message handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    // Handle background messages if enabled
    if (FirebaseConfig.enableBackgroundMessages) {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    }
  }

  // Load usage statistics from SharedPreferences
  Future<void> _loadUsageStats() async {
    final prefs = await SharedPreferences.getInstance();
    
    _dailyReads = prefs.getInt('firebase_daily_reads') ?? 0;
    _dailyWrites = prefs.getInt('firebase_daily_writes') ?? 0;
    _dailyDeletes = prefs.getInt('firebase_daily_deletes') ?? 0;
    _dailyUploads = prefs.getInt('firebase_daily_uploads') ?? 0;
    _dailyDownloadsMB = prefs.getInt('firebase_daily_downloads_mb') ?? 0;
    _monthlyAuthentications = prefs.getInt('firebase_monthly_authentications') ?? 0;
    
    final lastResetString = prefs.getString('firebase_last_usage_reset');
    if (lastResetString != null) {
      _lastUsageReset = DateTime.parse(lastResetString);
    } else {
      _lastUsageReset = DateTime.now();
      await _saveUsageStats();
    }
    
    // Check if we need to reset daily/monthly counters
    await _checkResetCounters();
  }

  // Save usage statistics to SharedPreferences
  Future<void> _saveUsageStats() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt('firebase_daily_reads', _dailyReads);
    await prefs.setInt('firebase_daily_writes', _dailyWrites);
    await prefs.setInt('firebase_daily_deletes', _dailyDeletes);
    await prefs.setInt('firebase_daily_uploads', _dailyUploads);
    await prefs.setInt('firebase_daily_downloads_mb', _dailyDownloadsMB);
    await prefs.setInt('firebase_monthly_authentications', _monthlyAuthentications);
    await prefs.setString('firebase_last_usage_reset', _lastUsageReset!.toIso8601String());
  }

  // Check if we need to reset counters
  Future<void> _checkResetCounters() async {
    final now = DateTime.now();
    
    // Reset daily counters if it's a new day
    if (now.day != _lastUsageReset!.day || now.month != _lastUsageReset!.month || now.year != _lastUsageReset!.year) {
      _dailyReads = 0;
      _dailyWrites = 0;
      _dailyDeletes = 0;
      _dailyUploads = 0;
      _dailyDownloadsMB = 0;
    }
    
    // Reset monthly counters if it's a new month
    if (now.month != _lastUsageReset!.month || now.year != _lastUsageReset!.year) {
      _monthlyAuthentications = 0;
    }
    
    _lastUsageReset = now;
    await _saveUsageStats();
  }

  // Track Firestore read
  Future<void> trackRead() async {
    if (!FirebaseConfig.enableUsageTracking) return;
    
    _dailyReads++;
    await _saveUsageStats();
    
    // Check if we're approaching limits
    if (FirebaseConfig.enforceUsageLimits && 
        _dailyReads >= FirebaseConfig.maxFirestoreReadsPerDay * FirebaseConfig.budgetAlertThresholdPercent / 100) {
      print('WARNING: Approaching Firestore read limit! $_dailyReads reads used out of ${FirebaseConfig.maxFirestoreReadsPerDay}');
    }
  }

  // Track Firestore write
  Future<void> trackWrite() async {
    if (!FirebaseConfig.enableUsageTracking) return;
    
    _dailyWrites++;
    await _saveUsageStats();
    
    // Check if we're approaching limits
    if (FirebaseConfig.enforceUsageLimits && 
        _dailyWrites >= FirebaseConfig.maxFirestoreWritesPerDay * FirebaseConfig.budgetAlertThresholdPercent / 100) {
      print('WARNING: Approaching Firestore write limit! $_dailyWrites writes used out of ${FirebaseConfig.maxFirestoreWritesPerDay}');
    }
  }

  // Track Firestore delete
  Future<void> trackDelete() async {
    if (!FirebaseConfig.enableUsageTracking) return;
    
    _dailyDeletes++;
    await _saveUsageStats();
    
    // Check if we're approaching limits
    if (FirebaseConfig.enforceUsageLimits && 
        _dailyDeletes >= FirebaseConfig.maxFirestoreDeletesPerDay * FirebaseConfig.budgetAlertThresholdPercent / 100) {
      print('WARNING: Approaching Firestore delete limit! $_dailyDeletes deletes used out of ${FirebaseConfig.maxFirestoreDeletesPerDay}');
    }
  }

  // Track Storage upload
  Future<void> trackUpload() async {
    if (!FirebaseConfig.enableUsageTracking) return;
    
    _dailyUploads++;
    await _saveUsageStats();
    
    // Check if we're approaching limits
    if (FirebaseConfig.enforceUsageLimits && 
        _dailyUploads >= FirebaseConfig.maxStorageUploadsPerDay * FirebaseConfig.budgetAlertThresholdPercent / 100) {
      print('WARNING: Approaching Storage upload limit! $_dailyUploads uploads used out of ${FirebaseConfig.maxStorageUploadsPerDay}');
    }
  }

  // Track Storage download
  Future<void> trackDownload(int sizeInBytes) async {
    if (!FirebaseConfig.enableUsageTracking) return;
    
    final sizeMB = sizeInBytes / (1024 * 1024);
    _dailyDownloadsMB += sizeMB.ceil();
    await _saveUsageStats();
    
    // Check if we're approaching limits
    if (FirebaseConfig.enforceUsageLimits && 
        _dailyDownloadsMB >= FirebaseConfig.maxStorageDownloadsPerDayMB * FirebaseConfig.budgetAlertThresholdPercent / 100) {
      print('WARNING: Approaching Storage download limit! $_dailyDownloadsMB MB used out of ${FirebaseConfig.maxStorageDownloadsPerDayMB} MB');
    }
  }

  // Track Authentication
  Future<void> trackAuthentication() async {
    if (!FirebaseConfig.enableUsageTracking) return;
    
    _monthlyAuthentications++;
    await _saveUsageStats();
    
    // Check if we're approaching limits
    if (FirebaseConfig.enforceUsageLimits && 
        _monthlyAuthentications >= FirebaseConfig.maxAuthenticationsPerMonth * FirebaseConfig.budgetAlertThresholdPercent / 100) {
      print('WARNING: Approaching Authentication limit! $_monthlyAuthentications authentications used out of ${FirebaseConfig.maxAuthenticationsPerMonth}');
    }
  }

  // Get usage statistics
  Map<String, dynamic> getUsageStats() {
    return {
      'dailyReads': _dailyReads,
      'dailyWrites': _dailyWrites,
      'dailyDeletes': _dailyDeletes,
      'dailyUploads': _dailyUploads,
      'dailyDownloadsMB': _dailyDownloadsMB,
      'monthlyAuthentications': _monthlyAuthentications,
      'lastReset': _lastUsageReset?.toIso8601String(),
      'readsPercentage': (_dailyReads / FirebaseConfig.maxFirestoreReadsPerDay * 100).toStringAsFixed(1),
      'writesPercentage': (_dailyWrites / FirebaseConfig.maxFirestoreWritesPerDay * 100).toStringAsFixed(1),
      'deletesPercentage': (_dailyDeletes / FirebaseConfig.maxFirestoreDeletesPerDay * 100).toStringAsFixed(1),
      'uploadsPercentage': (_dailyUploads / FirebaseConfig.maxStorageUploadsPerDay * 100).toStringAsFixed(1),
      'downloadsPercentage': (_dailyDownloadsMB / FirebaseConfig.maxStorageDownloadsPerDayMB * 100).toStringAsFixed(1),
      'authenticationsPercentage': (_monthlyAuthentications / FirebaseConfig.maxAuthenticationsPerMonth * 100).toStringAsFixed(1),
    };
  }
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}