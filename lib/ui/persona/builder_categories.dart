import 'dart:math';

import '../../domain/persona.dart';
import '../../l10n/app_localizations.dart';
import 'persona_copy.dart';

/// The builder's categories, in the order they are offered (persona plan
/// § B): appearance first, then clothing, then the decorative extras.
enum BuilderCategory {
  skin,
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
  sigil;

  /// The category's short name ("Hair colour", "Banner").
  String label(AppLocalizations l) => switch (this) {
    skin => l.personaCategorySkin,
    face => l.personaCategoryFace,
    hair => l.personaCategoryHair,
    hairColor => l.personaCategoryHairColor,
    facialHair => l.personaCategoryFacialHair,
    eyewear => l.personaCategoryEyewear,
    mark => l.personaCategoryMark,
    expression => l.personaCategoryExpression,
    headwear => l.personaCategoryHeadwear,
    garment => l.personaCategoryGarment,
    garmentColor => l.personaCategoryGarmentColor,
    accessory => l.personaCategoryAccessory,
    sigil => l.personaCategorySigil,
  };

  /// Every choice, in display order. Skin starts with the silhouette (null:
  /// no skin is assumed), then the tones in [kSkinTonePresentation]'s mixed
  /// order (never light → dark).
  List<Enum?> get options => switch (this) {
    skin => [null, ...kSkinTonePresentation],
    face => FaceShape.values,
    hair => HairStyle.values,
    hairColor => HairColor.values,
    facialHair => FacialHair.values,
    eyewear => Eyewear.values,
    mark => SkinMark.values,
    expression => Expression.values,
    headwear => Headwear.values,
    garment => Garment.values,
    garmentColor => GarmentColor.values,
    accessory => Accessory.values,
    sigil => Sigil.values,
  };

  /// What [avatar] has in this category (null only for the silhouette).
  Enum? valueOf(Avatar avatar) => switch (this) {
    skin => avatar.skinTone,
    face => avatar.face,
    hair => avatar.hair,
    hairColor => avatar.hairColor,
    facialHair => avatar.facialHair,
    eyewear => avatar.eyewear,
    mark => avatar.mark,
    expression => avatar.expression,
    headwear => avatar.headwear,
    garment => avatar.garment,
    garmentColor => avatar.garmentColor,
    accessory => avatar.accessory,
    sigil => avatar.sigil,
  };

  /// [avatar] with [value] chosen in this category.
  Avatar apply(Avatar avatar, Enum? value) => switch (this) {
    skin => avatar.copyWith(skinTone: () => value as SkinTone?),
    face => avatar.copyWith(face: value! as FaceShape),
    hair => avatar.copyWith(hair: value! as HairStyle),
    hairColor => avatar.copyWith(hairColor: value! as HairColor),
    facialHair => avatar.copyWith(facialHair: value! as FacialHair),
    eyewear => avatar.copyWith(eyewear: value! as Eyewear),
    mark => avatar.copyWith(mark: value! as SkinMark),
    expression => avatar.copyWith(expression: value! as Expression),
    headwear => avatar.copyWith(headwear: value! as Headwear),
    garment => avatar.copyWith(garment: value! as Garment),
    garmentColor => avatar.copyWith(garmentColor: value! as GarmentColor),
    accessory => avatar.copyWith(accessory: value! as Accessory),
    sigil => avatar.copyWith(sigil: value! as Sigil),
  };

  /// Whether any choice here can be a Campaign extra.
  bool get hasExtras =>
      options.any((o) => o != null && requirementOf(o) != null);
}

/// The name of one choice ("Silhouette" for the null skin tone).
String optionName(AppLocalizations l, Enum? value) =>
    value == null ? l.personaSilhouette : partName(l, value);

/// Values that mean "nothing here", left out of the preview's description.
bool _isNone(Enum value) => value.name == 'none';

/// The large preview's screen-reader description: "Avatar preview. Skin:
/// Copper, Face: Oval, Hair: Locs, …" (empty choices such as "no glasses"
/// are left out so it stays short).
String previewDescription(AppLocalizations l, Avatar avatar) {
  final parts = [
    for (final c in BuilderCategory.values)
      if (c.valueOf(avatar) case final v when v == null || !_isNone(v))
        l.personaBuilderPartLabel(c.label(l), optionName(l, v)),
  ];
  return l.personaBuilderPreviewLabel(parts.join(', '));
}

/// "Surprise me": a random avatar built only from parts [canUse] allows.
/// The skin is always a tone (a surprise silhouette would hide the face);
/// the result differs from [current] whenever another choice exists.
Avatar surpriseAvatar(
  Random random,
  bool Function(Enum part) canUse, {
  Avatar? current,
}) {
  Avatar roll() {
    var avatar = const Avatar();
    for (final c in BuilderCategory.values) {
      final usable = [
        for (final o in c.options)
          if (o != null && canUse(o)) o,
      ];
      if (usable.isEmpty) continue;
      avatar = c.apply(avatar, usable[random.nextInt(usable.length)]);
    }
    return avatar;
  }

  var next = roll();
  for (var i = 0; i < 8 && next == current; i++) {
    next = roll();
  }
  return next;
}
