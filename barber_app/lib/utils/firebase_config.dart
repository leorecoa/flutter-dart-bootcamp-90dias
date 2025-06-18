class FirebaseConfig {
  // Limites para o plano gratuito do Firebase
  static const int maxFirestoreReadsPerDay = 50000;
  static const int maxFirestoreWritesPerDay = 20000;
  static const int maxFirestoreDeletesPerDay = 20000;
  static const int maxStorageUploadsPerDay = 20000;
  static const int maxStorageDownloadsPerDayMB = 1024; // 1GB
  static const int maxAuthenticationsPerMonth = 50000;

  // Configurações para otimização
  static const bool enableOfflineData = true;
  static const bool enableCaching = true;
  static const int cacheSizeBytes = 10485760; // 10MB
  static const Duration cacheTTL = Duration(days: 1);
  
  // Configurações para limitar uso
  static const bool enableUsageTracking = true;
  static const bool enforceUsageLimits = true;
  static const double budgetAlertThresholdPercent = 80.0; // Alerta em 80% do limite
  
  // Configurações para FCM
  static const bool enablePushNotifications = true;
  static const bool enableBackgroundMessages = true;
}