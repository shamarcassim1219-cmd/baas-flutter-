import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api.dart';

final meProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return Api.i.me();
});

class OnlineNotifier extends StateNotifier<bool> {
  OnlineNotifier() : super(false);

  void set(bool v) => state = v;

  Future<void> toggle(bool want) async {
    final result = await Api.i.setOnline(want);
    state = result;
  }
}

final onlineProvider =
    StateNotifierProvider<OnlineNotifier, bool>((ref) => OnlineNotifier());
