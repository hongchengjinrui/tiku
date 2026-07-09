import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<File> resourceCacheFile() async {
  final directory = await getApplicationSupportDirectory();
  return File('${directory.path}/tiku_resource_cache_v1.json');
}

Future<void> clearResourceCache() async {
  final file = await resourceCacheFile();
  if (await file.exists()) await file.delete();
}
