import 'package:finzoo/core/profile/economy.dart';
import 'package:finzoo/core/profile/budget_plan.dart';
import 'package:finzoo/core/profile/game_controller.dart';
import 'package:finzoo/core/profile/player_profile.dart';
import 'package:finzoo/core/profile/player_profile_store.dart';
import 'package:finzoo/features/home/presentation/practice/practice_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

class _Mem extends PlayerProfileStore {
  PlayerProfile? _p;
  @override
  Future<PlayerProfile> load() async => _p ?? PlayerProfile.fresh();
  @override
  Future<void> save(PlayerProfile profile) async => _p = profile;
}

void main() {
  test('six practice tasks cover TZ themes', () {
    expect(PracticeCatalog.all, hasLength(6));
    final themes = PracticeCatalog.all.map((e) => e.theme).toSet();
    expect(themes, containsAll(PracticeTheme.values));
  });

  test('marking practice does not rewrite old park ids away', () async {
    final c = GameController(
      profile: PlayerProfile.fresh().copyWith(
        onboardingDone: true,
        availableBalance: 200,
        parkCompletedIds: const ['park_bike'],
        periodIncomeGranted: true,
        periodIncomeAmount: EconomyRules.periodIncome,
      ),
      store: _Mem(),
    );
    await c.markParkExerciseDone(PracticeCatalog.lunch);
    expect(c.profile.parkCompletedIds, contains('park_bike'));
    expect(c.profile.parkCompletedIds, contains(PracticeCatalog.lunch));
    expect(
      PracticeCatalog.completedIds(c.profile.parkCompletedIds),
      equals({PracticeCatalog.lunch}),
    );
    expect(c.profile.periodPracticeCompletedIds, {PracticeCatalog.lunch});
  });

  test('practice progress resets for the next game day but keeps history',
      () async {
    final c = GameController(
      profile: PlayerProfile.fresh().copyWith(
        onboardingDone: true,
        availableBalance: 200,
        periodIndex: 1,
        periodPhase: PeriodPhase.results,
        periodIncomeGranted: true,
        periodIncomeAmount: EconomyRules.periodIncome,
        parkCompletedIds: const [PracticeCatalog.lunch],
        periodPracticeCompletedIds: const [PracticeCatalog.lunch],
      ),
      store: _Mem(),
    );

    expect(await c.startNextPeriod(), isTrue);
    expect(c.profile.periodPracticeCompletedIds, isEmpty);
    expect(c.profile.parkCompletedIds, contains(PracticeCatalog.lunch));
    expect(PracticeCatalog.levelForPeriod(c.profile.periodIndex), 2);
  });
}
