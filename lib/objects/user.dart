import 'package:skating_app/common_logger.dart';
import 'package:stash/stash_api.dart';
import 'package:stash_memory/stash_memory.dart';
import 'package:skating_app/api/social.dart';

Future<Map<String, dynamic>> getUserCache(String userId) async {
  final store = await newMemoryCacheStore();

  // Creates a cache with a capacity of 10 from the previously created store
  final cache = await store.cache<Map<String, dynamic>>(
      name: 'users',
      maxEntries: 30,
      eventListenerMode: EventListenerMode.synchronous)
    ..on<CacheEntryCreatedEvent<Map<String, dynamic>>>().listen((event) =>
        commonLogger.v('Key "${event.entry.key}" added to the cache'));
  Map<String, dynamic>? user = await cache.get(userId);
  user ??= await getUser(userId);
  return user;
  //       await cache.put(
  // 'task1', Task(id: 1, title: 'Run cache store example', completed: true));
}
