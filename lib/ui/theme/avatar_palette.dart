import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../../domain/persona.dart';

/// The avatar's raw colours: skin tones, hair colours, garment colours and
/// the few materials (ink, metal, leather, parchment) of the portrait.
///
/// This is the only place these colours live (`test/ui_base_test.dart` keeps
/// raw colours inside `lib/ui/theme/`). They are the same in every app theme
/// and brightness: a person's skin or hair colour doesn't change with the
/// theme. The disc, rim, banner and the silhouette come from the theme's
/// palette tokens instead (`AvatarScene` in `persona/avatar_painter.dart`).
///
/// Warm and natural on purpose: skin tones are named after earth and wood,
/// never ranked; garment colours sit next to the brand's forest, olive,
/// sage, ivory and bronze.
abstract final class AvatarColors {
  // Skin (base, shade, lips).
  static const sand = Color(0xFFF0CFAE);
  static const sandShade = Color(0xFFDDB18D);
  static const sandLip = Color(0xFFC27E70);
  static const honey = Color(0xFFE0AF80);
  static const honeyShade = Color(0xFFC8925F);
  static const honeyLip = Color(0xFFAF6A58);
  static const clay = Color(0xFFC98F67);
  static const clayShade = Color(0xFFAE744F);
  static const clayLip = Color(0xFF995848);
  static const copper = Color(0xFFB57A50);
  static const copperShade = Color(0xFF99613C);
  static const copperLip = Color(0xFF874A3A);
  static const chestnut = Color(0xFF9A6543);
  static const chestnutShade = Color(0xFF7F5034);
  static const chestnutLip = Color(0xFF6E3D2F);
  static const walnut = Color(0xFF825238);
  static const walnutShade = Color(0xFF69402B);
  static const walnutLip = Color(0xFF5C3226);
  static const umber = Color(0xFF6C4430);
  static const umberShade = Color(0xFF563424);
  static const umberLip = Color(0xFF4A2B21);
  static const ebony = Color(0xFF573829);
  static const ebonyShade = Color(0xFF45291D);
  static const ebonyLip = Color(0xFF3B2219);

  /// Warm light the skin highlight leans towards.
  static const glow = Color(0xFFFFF1E2);

  /// Rose the cheeks lean towards when smiling.
  static const rose = Color(0xFFE07C6C);

  /// Depigmented skin (vitiligo patches lean towards it, softly).
  static const depigmented = Color(0xFFF4DFCF);

  // Hair (base, shade, shine).
  static const hairBlack = Color(0xFF2B2522);
  static const hairBlackShade = Color(0xFF191514);
  static const hairBlackShine = Color(0xFF51463F);
  static const hairDarkBrown = Color(0xFF4B3327);
  static const hairDarkBrownShade = Color(0xFF33221A);
  static const hairDarkBrownShine = Color(0xFF6E4E3C);
  static const hairBrown = Color(0xFF7B5337);
  static const hairBrownShade = Color(0xFF5D3E29);
  static const hairBrownShine = Color(0xFF9C7050);
  static const hairAuburn = Color(0xFF8F4127);
  static const hairAuburnShade = Color(0xFF6E301D);
  static const hairAuburnShine = Color(0xFFB15D3D);
  static const hairCopper = Color(0xFFC06A32);
  static const hairCopperShade = Color(0xFF9A5124);
  static const hairCopperShine = Color(0xFFDD8C52);
  static const hairBlonde = Color(0xFFD8B36E);
  static const hairBlondeShade = Color(0xFFB79253);
  static const hairBlondeShine = Color(0xFFEDD293);
  static const hairGrey = Color(0xFF9C9A95);
  static const hairGreyShade = Color(0xFF7C7A76);
  static const hairGreyShine = Color(0xFFBDBBB5);
  static const hairWhite = Color(0xFFE7E3DA);
  static const hairWhiteShade = Color(0xFFC6C0B4);
  static const hairWhiteShine = Color(0xFFF8F5EF);

  // Garments (base, shade, trim) and the linen worn under cloaks and wraps.
  static const forest = Color(0xFF2F5B45);
  static const forestShade = Color(0xFF224536);
  static const olive = Color(0xFF5F6B2F);
  static const oliveShade = Color(0xFF485220);
  static const sand2 = Color(0xFFCBB089);
  static const sand2Shade = Color(0xFFAA8F69);
  static const ivory = Color(0xFFEFE8D8);
  static const ivoryShade = Color(0xFFD2C7B1);
  static const sage = Color(0xFF94A27F);
  static const sageShade = Color(0xFF778562);
  static const indigo = Color(0xFF3C4B7A);
  static const indigoShade = Color(0xFF2D3961);
  static const crimson = Color(0xFF902F2A);
  static const crimsonShade = Color(0xFF70221F);
  static const bronze = Color(0xFFB08D57);
  static const bronzeShade = Color(0xFF8E6E41);
  static const trimGold = Color(0xFFD4B57B);
  static const trimBronze = Color(0xFF8A6534);
  static const trimDeep = Color(0xFF4E3A22);
  static const linen = Color(0xFFDCD0B6);
  static const linenShade = Color(0xFFC2B497);
  static const earthLinen = Color(0xFF6F5B45);
  static const earthLinenShade = Color(0xFF594735);

  // Materials.
  static const ink = Color(0xFF231915);
  static const catchlight = Color(0xFFFFF8EE);
  static const metal = Color(0xFFCDA96C);
  static const metalShade = Color(0xFF9B7847);
  static const metalShine = Color(0xFFEBD39E);
  static const leather = Color(0xFF7A5133);
  static const leatherShade = Color(0xFF5A3B25);
  static const leatherStitch = Color(0xFFB58C62);
  static const parchment = Color(0xFFECE1C8);
  static const parchmentShade = Color(0xFFCDBE9D);
  static const ribbon = Color(0xFF9E3A30);
  static const frameDark = Color(0xFF2C2420);
  static const lens = Color(0xFFFFFFFF);
}

/// A skin tone's colours. [light], [blush] and [patch] lean the base gently
/// towards light, rose and depigmented skin.
@immutable
class SkinColors {
  const SkinColors({
    required this.base,
    required this.shade,
    required this.lip,
  });

  final Color base;
  final Color shade;
  final Color lip;

  Color get light => Color.lerp(base, AvatarColors.glow, 0.22)!;
  Color get blush => Color.lerp(base, AvatarColors.rose, 0.45)!;

  /// Vitiligo: a soft, lighter patch (never stark white).
  Color get patch => Color.lerp(base, AvatarColors.depigmented, 0.58)!;

  /// Deeper tones get gold-wire glasses, lighter ones dark frames, so the
  /// frames read on every skin.
  bool get isDeep => base.computeLuminance() < 0.16;
}

@immutable
class HairColors {
  const HairColors({
    required this.base,
    required this.shade,
    required this.shine,
  });

  final Color base;
  final Color shade;
  final Color shine;
}

@immutable
class GarmentColors {
  const GarmentColors({
    required this.base,
    required this.shade,
    required this.trim,
    required this.under,
    required this.underShade,
  });

  final Color base;
  final Color shade;

  /// The edging (neckline, collar, cloak edges).
  final Color trim;

  /// The linen worn under a cloak or a wrap (contrasts with [base]).
  final Color under;
  final Color underShade;
}

/// Lookups from avatar parts to colours (plain and const: the painter reads
/// them directly).
abstract final class AvatarPalette {
  static SkinColors skin(SkinTone tone) => switch (tone) {
    SkinTone.sand => const SkinColors(
      base: AvatarColors.sand,
      shade: AvatarColors.sandShade,
      lip: AvatarColors.sandLip,
    ),
    SkinTone.honey => const SkinColors(
      base: AvatarColors.honey,
      shade: AvatarColors.honeyShade,
      lip: AvatarColors.honeyLip,
    ),
    SkinTone.clay => const SkinColors(
      base: AvatarColors.clay,
      shade: AvatarColors.clayShade,
      lip: AvatarColors.clayLip,
    ),
    SkinTone.copper => const SkinColors(
      base: AvatarColors.copper,
      shade: AvatarColors.copperShade,
      lip: AvatarColors.copperLip,
    ),
    SkinTone.chestnut => const SkinColors(
      base: AvatarColors.chestnut,
      shade: AvatarColors.chestnutShade,
      lip: AvatarColors.chestnutLip,
    ),
    SkinTone.walnut => const SkinColors(
      base: AvatarColors.walnut,
      shade: AvatarColors.walnutShade,
      lip: AvatarColors.walnutLip,
    ),
    SkinTone.umber => const SkinColors(
      base: AvatarColors.umber,
      shade: AvatarColors.umberShade,
      lip: AvatarColors.umberLip,
    ),
    SkinTone.ebony => const SkinColors(
      base: AvatarColors.ebony,
      shade: AvatarColors.ebonyShade,
      lip: AvatarColors.ebonyLip,
    ),
  };

  static HairColors hair(HairColor color) => switch (color) {
    HairColor.black => const HairColors(
      base: AvatarColors.hairBlack,
      shade: AvatarColors.hairBlackShade,
      shine: AvatarColors.hairBlackShine,
    ),
    HairColor.darkBrown => const HairColors(
      base: AvatarColors.hairDarkBrown,
      shade: AvatarColors.hairDarkBrownShade,
      shine: AvatarColors.hairDarkBrownShine,
    ),
    HairColor.brown => const HairColors(
      base: AvatarColors.hairBrown,
      shade: AvatarColors.hairBrownShade,
      shine: AvatarColors.hairBrownShine,
    ),
    HairColor.auburn => const HairColors(
      base: AvatarColors.hairAuburn,
      shade: AvatarColors.hairAuburnShade,
      shine: AvatarColors.hairAuburnShine,
    ),
    HairColor.copper => const HairColors(
      base: AvatarColors.hairCopper,
      shade: AvatarColors.hairCopperShade,
      shine: AvatarColors.hairCopperShine,
    ),
    HairColor.blonde => const HairColors(
      base: AvatarColors.hairBlonde,
      shade: AvatarColors.hairBlondeShade,
      shine: AvatarColors.hairBlondeShine,
    ),
    HairColor.grey => const HairColors(
      base: AvatarColors.hairGrey,
      shade: AvatarColors.hairGreyShade,
      shine: AvatarColors.hairGreyShine,
    ),
    HairColor.white => const HairColors(
      base: AvatarColors.hairWhite,
      shade: AvatarColors.hairWhiteShade,
      shine: AvatarColors.hairWhiteShine,
    ),
  };

  static const _linen = (AvatarColors.linen, AvatarColors.linenShade);
  static const _earth = (AvatarColors.earthLinen, AvatarColors.earthLinenShade);

  static GarmentColors garment(GarmentColor color) {
    final (base, shade, trim, under) = switch (color) {
      GarmentColor.forest => (
        AvatarColors.forest,
        AvatarColors.forestShade,
        AvatarColors.trimGold,
        _linen,
      ),
      GarmentColor.olive => (
        AvatarColors.olive,
        AvatarColors.oliveShade,
        AvatarColors.trimGold,
        _linen,
      ),
      GarmentColor.sand => (
        AvatarColors.sand2,
        AvatarColors.sand2Shade,
        AvatarColors.trimBronze,
        _earth,
      ),
      GarmentColor.ivory => (
        AvatarColors.ivory,
        AvatarColors.ivoryShade,
        AvatarColors.trimBronze,
        _earth,
      ),
      GarmentColor.sage => (
        AvatarColors.sage,
        AvatarColors.sageShade,
        AvatarColors.trimDeep,
        _earth,
      ),
      GarmentColor.indigo => (
        AvatarColors.indigo,
        AvatarColors.indigoShade,
        AvatarColors.trimGold,
        _linen,
      ),
      GarmentColor.crimson => (
        AvatarColors.crimson,
        AvatarColors.crimsonShade,
        AvatarColors.trimGold,
        _linen,
      ),
      GarmentColor.bronze => (
        AvatarColors.bronze,
        AvatarColors.bronzeShade,
        AvatarColors.trimDeep,
        _earth,
      ),
    };
    return GarmentColors(
      base: base,
      shade: shade,
      trim: trim,
      under: under.$1,
      underShade: under.$2,
    );
  }

  /// Glasses frames that read on [skin].
  static Color frameFor(SkinColors skin) =>
      skin.isDeep ? AvatarColors.metal : AvatarColors.frameDark;
}
