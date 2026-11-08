
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'blocs/sensor_bloc.dart';
import 'database/database_helper.dart';
import 'pages/dashboard_page.dart';
import 'pages/riwayat_sensor_page.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  // Inisialisasi database SQLite sebelum aplikasi dijalankan
  await DatabaseHelper.instance.database;

  runApp(const AiotPeringatanDiniApp());
}

class AiotPeringatanDiniApp extends StatelessWidget {
  const AiotPeringatanDiniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SensorBloc(),
      child: MaterialApp(
        title: 'AIoT Peringatan Dini Bencana',
        debugShowCheckedModeBanner: false,

        // Menggunakan tema terpusat
        theme: AppTheme.lightTheme,

        // Halaman pertama aplikasi
        initialRoute: '/',

        // Konfigurasi navigasi
        routes: {
          '/': (context) => const DashboardPage(),
          '/riwayat': (context) => const RiwayatSensorPage(),
        },
      ),
    );
  }
}
