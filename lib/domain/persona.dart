/// The user's persona: an avatar they compose themselves, shown in You, the
/// Campaign and Today. Cosmetic and user-chosen only — never inferred, never a
/// label for the person. Appearance (skin, face, hair, glasses, marks,
/// headwear for faith or style) is always free; only decorative extras
/// (banners, some colours and ornaments) unlock along the Campaign, and only
/// while the game layer is on. Nothing once unlocked or worn is taken away.
///
/// Inclusive by design: no gender choice (every option is open to everyone),
/// no default skin tone (null = a neutral silhouette until the user picks
/// one), skin tones presented in a mixed order (not light → dark), hair
/// textures from straight to coily, locs and braids, religious headwear, and
/// visible differences (glasses, freckles, vitiligo).
library;

import 'campaign.dart';

/// Skin tones (named after earth and wood, never ranked).
enum SkinTone { sand, honey, clay, copper, chestnut, walnut, umber, ebony }

/// The order the builder shows skin tones in: mixed, not light → dark.
const List<SkinTone> kSkinTonePresentation = [
  SkinTone.copper,
  SkinTone.sand,
  SkinTone.walnut,
  SkinTone.honey,
  SkinTone.ebony,
  SkinTone.clay,
  SkinTone.umber,
  SkinTone.chestnut,
];

enum FaceShape { oval, round, square, long }

enum HairStyle {
  bald,
  buzz,
  short,
  wavy,
  curly,
  coily,
  afro,
  locs,
  braids,
  bun,
  long,
  ponytail,
}

enum HairColor { black, darkBrown, brown, auburn, copper, blonde, grey, white }

enum FacialHair { none, stubble, moustache, beard, fullBeard }

enum Eyewear { none, round, square }

/// Visible differences, drawn with respect, never as a "flaw".
enum SkinMark { none, freckles, beautyMark, vitiligo }

enum Expression { calm, smile, focused }

/// Headwear: faith and style options are free; [circlet] and [laurel] are
/// Campaign unlocks.
enum Headwear { none, headscarf, turban, hood, circlet, laurel }

enum Garment { tunic, cloak, robe, wrap }

/// Garment colours: four free, four Campaign unlocks.
enum GarmentColor { forest, olive, sand, ivory, sage, indigo, crimson, bronze }

/// Carried items: [scroll], [compass] and [amulet] (the sign of Tanit) are
/// Campaign unlocks.
enum Accessory { none, satchel, scroll, compass, amulet }

/// The banner behind the portrait: two free, four Campaign unlocks.
enum Sigil { none, elephant, sun, path, compass, star, laurel }

/// Decorative extras earned along the Campaign. Each comes from one route
/// stop or one achievement (see [unlockSource]).
enum Unlockable {
  sigilPath,
  garmentSage,
  headwearCirclet,
  accessoryCompass,
  sigilStar,
  headwearLaurel,
  accessoryScroll,
  sigilCompass,
  garmentIndigo,
  garmentCrimson,
  accessoryAmulet,
  garmentBronze,
  sigilLaurel,
}

/// Where an [Unlockable] comes from: reaching a route stop, or an
/// achievement. Exactly one of the two is set.
class UnlockSource {
  const UnlockSource.stop(Waypoint this.waypoint) : achievement = null;
  const UnlockSource.achievement(Achievement this.achievement)
    : waypoint = null;

  final Waypoint? waypoint;
  final Achievement? achievement;
}

/// The single table of what unlocks what.
UnlockSource unlockSource(Unlockable u) => switch (u) {
  Unlockable.sigilPath => const UnlockSource.stop(Waypoint.newCarthage),
  Unlockable.garmentSage => const UnlockSource.stop(Waypoint.ebro),
  Unlockable.headwearCirclet => const UnlockSource.stop(Waypoint.pyrenees),
  Unlockable.accessoryCompass => const UnlockSource.stop(Waypoint.rhone),
  Unlockable.sigilStar => const UnlockSource.stop(Waypoint.alps),
  Unlockable.headwearLaurel => const UnlockSource.stop(Waypoint.italy),
  Unlockable.accessoryScroll => const UnlockSource.achievement(
    Achievement.observer,
  ),
  Unlockable.sigilCompass => const UnlockSource.achievement(
    Achievement.pathfinder,
  ),
  Unlockable.garmentIndigo => const UnlockSource.achievement(
    Achievement.visionary,
  ),
  Unlockable.garmentCrimson => const UnlockSource.achievement(
    Achievement.watchful,
  ),
  Unlockable.accessoryAmulet => const UnlockSource.achievement(
    Achievement.strategist,
  ),
  Unlockable.garmentBronze => const UnlockSource.achievement(
    Achievement.practitioner,
  ),
  Unlockable.sigilLaurel => const UnlockSource.achievement(
    Achievement.challenger,
  ),
};

/// What [progress] has unlocked. With the game layer off, everything is
/// open: opting out of the game never costs a choice.
Set<Unlockable> unlockedBy(CampaignProgress progress, {required bool gameOn}) {
  if (!gameOn) return Unlockable.values.toSet();
  return {
    for (final u in Unlockable.values)
      if (switch (unlockSource(u)) {
        UnlockSource(waypoint: final w?) => progress.waypoint.index >= w.index,
        UnlockSource(achievement: final a?) => progress.earned.contains(a),
        _ => false,
      })
        u,
  };
}

/// Every extra in the order the Campaign points to them: the route stops
/// along Hannibal's road first (XP always moves the user along it), then the
/// achievements in the article's order.
final List<Unlockable> kUnlockOrder = List.unmodifiable(
  [...Unlockable.values]..sort((a, b) {
    int rank(Unlockable u) => switch (unlockSource(u)) {
      UnlockSource(waypoint: final w?) => w.index,
      UnlockSource(achievement: final earned?) =>
        Waypoint.values.length + earned.index,
      _ => 1 << 20,
    };
    return rank(a).compareTo(rank(b));
  }),
);

/// The next extra the Campaign can still open (game layer on), in
/// [kUnlockOrder], skipping those already open or in [owned] (worn before
/// the game layer was turned on: never taken away). Null once every extra is
/// open.
Unlockable? nextUnlock(
  CampaignProgress progress, {
  Set<Unlockable> owned = const {},
}) {
  final open = unlockedBy(progress, gameOn: true);
  for (final u in kUnlockOrder) {
    if (!open.contains(u) && !owned.contains(u)) return u;
  }
  return null;
}

/// The unlock an item needs, or null when it is free.
Unlockable? requirementOf(Enum item) => switch (item) {
  Headwear.circlet => Unlockable.headwearCirclet,
  Headwear.laurel => Unlockable.headwearLaurel,
  GarmentColor.sage => Unlockable.garmentSage,
  GarmentColor.indigo => Unlockable.garmentIndigo,
  GarmentColor.crimson => Unlockable.garmentCrimson,
  GarmentColor.bronze => Unlockable.garmentBronze,
  Accessory.scroll => Unlockable.accessoryScroll,
  Accessory.compass => Unlockable.accessoryCompass,
  Accessory.amulet => Unlockable.accessoryAmulet,
  Sigil.path => Unlockable.sigilPath,
  Sigil.compass => Unlockable.sigilCompass,
  Sigil.star => Unlockable.sigilStar,
  Sigil.laurel => Unlockable.sigilLaurel,
  _ => null,
};

/// The avatar's parts. [skinTone] null = a neutral silhouette (no default
/// skin is ever assumed for the user).
class Avatar {
  const Avatar({
    this.skinTone,
    this.face = FaceShape.oval,
    this.hair = HairStyle.short,
    this.hairColor = HairColor.black,
    this.facialHair = FacialHair.none,
    this.eyewear = Eyewear.none,
    this.mark = SkinMark.none,
    this.expression = Expression.calm,
    this.headwear = Headwear.none,
    this.garment = Garment.tunic,
    this.garmentColor = GarmentColor.forest,
    this.accessory = Accessory.none,
    this.sigil = Sigil.elephant,
  });

  final SkinTone? skinTone;
  final FaceShape face;
  final HairStyle hair;
  final HairColor hairColor;
  final FacialHair facialHair;
  final Eyewear eyewear;
  final SkinMark mark;
  final Expression expression;
  final Headwear headwear;
  final Garment garment;
  final GarmentColor garmentColor;
  final Accessory accessory;
  final Sigil sigil;

  /// Every chosen part, for unlock checks and labels.
  List<Enum> get parts => [
    ?skinTone,
    face,
    hair,
    hairColor,
    facialHair,
    eyewear,
    mark,
    expression,
    headwear,
    garment,
    garmentColor,
    accessory,
    sigil,
  ];

  /// Whether this avatar wears or carries [u].
  bool uses(Unlockable u) => parts.any((p) => requirementOf(p) == u);

  Avatar copyWith({
    SkinTone? Function()? skinTone,
    FaceShape? face,
    HairStyle? hair,
    HairColor? hairColor,
    FacialHair? facialHair,
    Eyewear? eyewear,
    SkinMark? mark,
    Expression? expression,
    Headwear? headwear,
    Garment? garment,
    GarmentColor? garmentColor,
    Accessory? accessory,
    Sigil? sigil,
  }) => Avatar(
    skinTone: skinTone != null ? skinTone() : this.skinTone,
    face: face ?? this.face,
    hair: hair ?? this.hair,
    hairColor: hairColor ?? this.hairColor,
    facialHair: facialHair ?? this.facialHair,
    eyewear: eyewear ?? this.eyewear,
    mark: mark ?? this.mark,
    expression: expression ?? this.expression,
    headwear: headwear ?? this.headwear,
    garment: garment ?? this.garment,
    garmentColor: garmentColor ?? this.garmentColor,
    accessory: accessory ?? this.accessory,
    sigil: sigil ?? this.sigil,
  );

  Map<String, Object?> toJson() => {
    'skinTone': skinTone?.name,
    'face': face.name,
    'hair': hair.name,
    'hairColor': hairColor.name,
    'facialHair': facialHair.name,
    'eyewear': eyewear.name,
    'mark': mark.name,
    'expression': expression.name,
    'headwear': headwear.name,
    'garment': garment.name,
    'garmentColor': garmentColor.name,
    'accessory': accessory.name,
    'sigil': sigil.name,
  };

  /// Unknown part names (from a newer version) fall back to the default part.
  factory Avatar.fromJson(Map<String, Object?> j) {
    T pick<T extends Enum>(List<T> values, String key, T fallback) {
      final v = j[key];
      if (v == null) return fallback;
      if (v is! String) throw FormatException('Expected string for "$key"');
      for (final e in values) {
        if (e.name == v) return e;
      }
      return fallback;
    }

    final tone = j['skinTone'];
    SkinTone? skin;
    if (tone != null) {
      if (tone is! String) throw const FormatException('Bad skinTone');
      for (final t in SkinTone.values) {
        if (t.name == tone) skin = t;
      }
    }
    const d = Avatar();
    return Avatar(
      skinTone: skin,
      face: pick(FaceShape.values, 'face', d.face),
      hair: pick(HairStyle.values, 'hair', d.hair),
      hairColor: pick(HairColor.values, 'hairColor', d.hairColor),
      facialHair: pick(FacialHair.values, 'facialHair', d.facialHair),
      eyewear: pick(Eyewear.values, 'eyewear', d.eyewear),
      mark: pick(SkinMark.values, 'mark', d.mark),
      expression: pick(Expression.values, 'expression', d.expression),
      headwear: pick(Headwear.values, 'headwear', d.headwear),
      garment: pick(Garment.values, 'garment', d.garment),
      garmentColor: pick(GarmentColor.values, 'garmentColor', d.garmentColor),
      accessory: pick(Accessory.values, 'accessory', d.accessory),
      sigil: pick(Sigil.values, 'sigil', d.sigil),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Avatar &&
      other.skinTone == skinTone &&
      other.face == face &&
      other.hair == hair &&
      other.hairColor == hairColor &&
      other.facialHair == facialHair &&
      other.eyewear == eyewear &&
      other.mark == mark &&
      other.expression == expression &&
      other.headwear == headwear &&
      other.garment == garment &&
      other.garmentColor == garmentColor &&
      other.accessory == accessory &&
      other.sigil == sigil;

  @override
  int get hashCode => Object.hashAll(parts);
}

/// Most characters in a persona's motto.
const int kPersonaMottoMax = 60;

/// The user's persona: their avatar and an optional motto in their own words
/// (stored exactly as typed).
class Persona {
  const Persona({
    required this.avatar,
    required this.updatedAt,
    this.motto = '',
  });

  final Avatar avatar;
  final String motto;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => {
    'avatar': avatar.toJson(),
    'motto': motto,
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  factory Persona.fromJson(Object? json) {
    if (json is! Map) {
      throw const FormatException('Expected object for persona');
    }
    final j = json.map((k, v) => MapEntry(k.toString(), v));
    final avatar = j['avatar'];
    if (avatar is! Map) throw const FormatException('Expected avatar');
    final motto = j['motto'] ?? '';
    if (motto is! String) throw const FormatException('Bad motto');
    final at = j['updatedAt'];
    final time = at is String ? DateTime.tryParse(at) : null;
    if (time == null) throw const FormatException('Bad updatedAt');
    return Persona(
      avatar: Avatar.fromJson(avatar.map((k, v) => MapEntry(k.toString(), v))),
      motto: motto,
      updatedAt: time,
    );
  }
}
