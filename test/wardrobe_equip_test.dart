import 'package:finzoo/core/profile/game_controller.dart';
import 'package:finzoo/core/profile/house_catalog.dart';
import 'package:finzoo/core/profile/player_profile.dart';
import 'package:finzoo/core/profile/player_profile_store.dart';
import 'package:finzoo/core/wardrobe/wardrobe_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('equip body and head independently; mood once', () async {
    final c = GameController(
      profile: PlayerProfile.fresh().copyWith(
        onboardingDone: true,
        availableBalance: 500,
        mood: 80,
        inventory: const {'c1': 1, 'c4': 1, 'c5': 1},
      ),
      store: _Mem(),
    );

    final tee = await c.equipClothes(1);
    expect(tee.ok, isTrue);
    expect(tee.firstBoost, isTrue);
    expect(tee.moodGain, 5);
    expect(c.profile.equippedBodyKey, 'c1');
    expect(c.profile.mood, 85);

    final bow = await c.equipClothes(4);
    expect(bow.ok, isTrue);
    expect(bow.firstBoost, isTrue);
    expect(c.profile.equippedBodyKey, 'c1');
    expect(c.profile.equippedHeadKey, 'c4');
    expect(c.profile.mood, 90);

    final hoodie = await c.equipClothes(5);
    expect(hoodie.ok, isTrue);
    expect(hoodie.firstBoost, isTrue);
    expect(c.profile.equippedBodyKey, 'c5');
    expect(c.profile.equippedHeadKey, 'c4');
    expect(c.profile.mood, 95);

    final teeAgain = await c.equipClothes(1);
    expect(teeAgain.firstBoost, isFalse);
    expect(teeAgain.moodGain, 0);
    expect(c.profile.mood, 95);

    await c.unequipClothesSlot(WardrobeSlot.head);
    expect(c.profile.equippedHeadKey, isNull);
    expect(c.profile.equippedBodyKey, 'c1');
    expect(c.profile.mood, 95);

    // повторная покупка постоянной вещи недоступна
    final bought = await c.buyHouseItem(
      category: HouseItemCategory.clothes,
      index: 1,
    );
    expect(bought, isFalse);
  });
}

class _Mem extends PlayerProfileStore {
  PlayerProfile? _p;
  @override
  Future<PlayerProfile> load() async => _p ?? PlayerProfile.fresh();
  @override
  Future<void> save(PlayerProfile profile) async => _p = profile;
}
