import '../../domain/campaign.dart';
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

/// How a locked extra becomes the user's: with a reward pick (the same for
/// every extra since picks replaced fixed unlocks; [u] is the extra asked
/// about).
String unlockReason(AppLocalizations l, Unlockable u) =>
    l.personaUnlockWithPick;

/// When the next reward pick comes: the next route stop ("Next pick at the
/// Ebro"), else the first achievement not earned yet ("Next pick: earn The
/// Challenger"); null once every milestone is reached.
String? nextPickReason(AppLocalizations l, CampaignProgress progress) {
  final stop = progress.nextWaypoint;
  if (stop != null) return l.personaNextPickStop(l.campaignWaypoint(stop.name));
  final achievement = progress.nextAchievement;
  if (achievement != null) {
    return l.personaNextPickAchievement(achievementName(l, achievement));
  }
  return null;
}

/// The lock text of a locked extra: [unlockReason] while a reward pick is
/// left, else when the next pick comes ([nextPickReason]).
String lockedExtraNote(
  AppLocalizations l,
  Unlockable u, {
  required CampaignProgress progress,
  required int picksLeft,
}) => picksLeft > 0
    ? unlockReason(l, u)
    : nextPickReason(l, progress) ?? unlockReason(l, u);
