import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:superbase_julio_butron/src/app.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://lwkpjhfdnjnffdiuknbx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx3a3BqaGZkbmpuZmZkaXVrbmJ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDQyMDkyNDEsImV4cCI6MjAxOTc4NTI0MX0.D8t3sd2aXsdwXR9QCiEa6HyVrVxUOYLoQ4e6uVKwths',
  );
  runApp(MyApp());
}

final supabase = Supabase.instance.client;
