import 'package:bonkers/controller/auth.dart';
import 'package:bonkers/controller/database.dart';
import 'package:bonkers/repositories/bon_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bon.dart';

class BonService {
  BonService({required this.ref, required this.bonRepository});

  final Ref ref;
  final BonRepository bonRepository;

  Future updateBon(Bon bon) async {
    final user = ref.read(authStateChangesProvider).value;
    try {
      await ref.read(databaseProvider).updateBon(user!, bon);
    } catch (e) {
      return e.toString();
    }
  }

  Future addBon(Bon bon) async {
    final user = ref.read(authStateChangesProvider).value;
    try {
      await ref.read(databaseProvider).addBon(user!, bon);
    } catch (e) {
      return e.toString();
    }
  }
}

final bonServiceProvider = Provider<BonService>((ref) {
  final BonRepository bonRepository = ref.watch(bonRepositoryProvider);
  return BonService(ref: ref, bonRepository: bonRepository);
});

final bonListStreamProvider = StreamProvider.autoDispose<List<Bon>>((ref) {
  final user = ref.read(authStateChangesProvider).value;

  if (user != null) {
    return ref.read(bonRepositoryProvider).getAllBons(uid: user.uid);
  } else {
    return const Stream.empty();
  }
});

final bonStreamProvider =
    StreamProvider.family.autoDispose<Bon, String>((ref, bonId) {
  final user = ref.read(authStateChangesProvider).value;

  if (user != null) {
    return ref.read(bonRepositoryProvider).getBon(uid: user.uid, bonUid: bonId);
  } else {
    return const Stream.empty();
  }
});

class BonController extends StateNotifier<AsyncValue<void>> {
  BonController({required this.bonService}) : super(const AsyncData(null));
  final BonService bonService;
}
