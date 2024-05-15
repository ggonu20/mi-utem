import 'package:flutter_dotenv/flutter_dotenv.dart';

final apiUrl = bool.fromEnvironment('dart.vm.product') ? 'https://api.exdev.cl' : (dotenv.env['MI_UTEM_API_DEBUG'] ?? 'https://api.exdev.cl');
const String sentryDsn = 'https://c03edae5839c62f95de91c1cbabb65d7@o4506938204553216.ingest.us.sentry.io/4506938205470720';
const String uxCamDevKey = '0y6p88obpgiug1g';
const String uxCamProdKey = 'fxkjj5ulr7vb4yf';
