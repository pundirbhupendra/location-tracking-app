import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/location_point_model.dart';
import '../../data/models/route_model.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(LocationPointModelAdapter());
    Hive.registerAdapter(RouteModelAdapter());
  }
}
