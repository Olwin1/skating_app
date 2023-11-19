import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

const cacheStore = 'mapStore';

Future<void> initializeCache() async {
  await FlutterMapTileCaching.initialise();
  await FMTC.instance(cacheStore).manage.createAsync();
}

TileProvider? tileProvider = FMTC.instance(cacheStore).getTileProvider();
