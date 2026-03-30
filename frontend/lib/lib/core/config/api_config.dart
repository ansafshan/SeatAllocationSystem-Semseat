import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    
    // Check if we are on Android
    if (Platform.isAndroid) {
      // For local development on emulator, you could use:
      // return 'http://10.0.2.2:5000/api';
      
      // For presentation with Physical Device / APK, use ngrok:
      return 'https://9b0f-61-3-140-64.ngrok-free.app/api';
    }
    
    return 'http://localhost:5000/api';
  }
}

