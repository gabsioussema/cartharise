import '../../domain/persona.dart';
import '../../l10n/app_localizations.dart';
import '../campaign/campaign_copy.dart';

/// Localized names for avatar parts and unlocks (shared by the builder, the
/// Campaign and the avatar's screen-reader label).

/// The name of one part value, e.g. "Laurel wreath" or "Coily".
String partName(AppLocalizations l, Enum part) => switch (part) {
  SkinTone() => l.personaSkinTone(part.name),
  FaceShape() => l.personaFace(part.name),
  HairStyle() => l.personaHair(part.name),
  HairColor() => l.personaHairColor(part.name),
  FacialHair() => l.personaFacialHair(part.name),
  Eyewear() => l.personaEyewear(part.name),
  SkinMark() => l.personaMark(part.name),
  Expression() => l.personaExpression(part.name),
  Headwear() => l.personaHeadwear(part.name),
  Garment() => l.personaGarment(part.name),
  GarmentColor() => l.personaGarmentColor(part.name),
  Accessory() => l.personaAccessory(part.name),
  Sigil() => l.personaSigil(part.name),
  _ => part.name,
};

/// The item an [Unlockable] opens, by name.
String unlockableName(AppLocalizations l, Unlockable u) => switch (u) {
  Unlockable.sigilPath => partName(l, Sigil.path),
  Unlockable.garmentSage => partName(l, GarmentColor.sage),
  Unlockable.headwearCirclet => partName(l, Headwear.circlet),
  Unlockable.accessoryCompass => partName(l, Accessory.compass),
  Unlockable.sigilStar => partName(l, Sigil.star),
  Unlockable.headwearLaurel => partName(l, Headwear.laurel),
  Unlockable.accessoryScroll => partName(l, Accessory.scroll),
  Unlockable.sigilCompass => partName(l, Sigil.compass),
  Unlockable.garmentIndigo => partName(l, GarmentColor.indigo),
  Unlockable.garmentCrimson => partName(l, GarmentColor.crimson),
  Unlockable.accessoryAmulet => partName(l, Accessory.amulet),
  Unlockable.garmentBronze => partName(l, GarmentColor.bronze),
  Unlockable.sigilLaurel => partName(l, Sigil.laurel),
};

/// How to unlock [u], e.g. "Reach the Alps" or "Earn The Strategist".
String unlockReason(AppLocalizations l, Unlockable u) =>
    switch (unlockSource(u)) {
      UnlockSource(waypoint: final w?) => l.personaUnlockStop(
        l.campaignWaypoint(w.name),
      ),
      UnlockSource(achievement: final a?) => l.personaUnlockAchievement(
        achievementName(l, a),
      ),
      _ => '',
    };
