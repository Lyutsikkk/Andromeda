/datum/species/lizard
	// Reptilian humanoids with scaled skin and tails.
	name = "Унатх"
	plural_form = "Унатх"
	id = SPECIES_LIZARD
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_REPTILE
	body_markings = list(
		/datum/bodypart_overlay/simple/body_marking/lizard = SPRITE_ACCESSORY_NONE,
	)
	mutant_organs = list(
		/obj/item/organ/horns = SPRITE_ACCESSORY_NONE,
		/obj/item/organ/frills = SPRITE_ACCESSORY_NONE,
		/obj/item/organ/snout = "Круглый",
		/obj/item/organ/spines = SPRITE_ACCESSORY_NONE,
		/obj/item/organ/tail/lizard = "Гладкий",
	)
	mutanttongue = /obj/item/organ/tongue/lizard
	mutanteyes = /obj/item/organ/eyes/lizard
	mutantbrain = /obj/item/organ/brain/lizard
	coldmod = 1.5
	heatmod = 0.67
	payday_modifier = 1.0
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_cookie = /obj/item/food/meat/slab
	meat = /obj/item/food/meat/slab/human/mutant/lizard
	skinned_type = /obj/item/stack/sheet/animalhide/lizard
	exotic_bloodtype = BLOOD_TYPE_LIZARD
	inert_mutation = /datum/mutation/firebreath
	death_sound = 'sound/mobs/humanoids/lizard/deathsound.ogg'
	species_language_holder = /datum/language_holder/lizard
	digitigrade_customization = DIGITIGRADE_OPTIONAL

	// Lizards are coldblooded and can stand a greater temperature range than humans
	bodytemp_heat_damage_limit = BODYTEMP_HEAT_LAVALAND_SAFE
	bodytemp_cold_damage_limit = (BODYTEMP_COLD_DAMAGE_LIMIT - 10)

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/lizard,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/lizard,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/lizard,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/lizard,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/lizard,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/lizard,
	)

/// Lizards are cold blooded and do not stabilize body temperature naturally
/datum/species/lizard/body_temperature_core(mob/living/carbon/human/humi, seconds_per_tick, times_fired)
	return

/datum/species/lizard/randomize_features()
	var/list/features = ..()
	features[FEATURE_LIZARD_MARKINGS] = pick(SSaccessories.lizard_markings_list)
	return features

/datum/species/lizard/get_scream_sound(mob/living/carbon/human/lizard)
	return pick(
		'sound/mobs/humanoids/lizard/lizard_scream_1.ogg',
		'sound/mobs/humanoids/lizard/lizard_scream_2.ogg',
		'sound/mobs/humanoids/lizard/lizard_scream_3.ogg',
	)

/datum/species/lizard/get_cough_sound(mob/living/carbon/human/lizard)
	if(lizard.physique == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/cough/female_cough1.ogg',
			'sound/mobs/humanoids/human/cough/female_cough2.ogg',
			'sound/mobs/humanoids/human/cough/female_cough3.ogg',
			'sound/mobs/humanoids/human/cough/female_cough4.ogg',
			'sound/mobs/humanoids/human/cough/female_cough5.ogg',
			'sound/mobs/humanoids/human/cough/female_cough6.ogg',
		)
	return pick(
		'sound/mobs/humanoids/human/cough/male_cough1.ogg',
		'sound/mobs/humanoids/human/cough/male_cough2.ogg',
		'sound/mobs/humanoids/human/cough/male_cough3.ogg',
		'sound/mobs/humanoids/human/cough/male_cough4.ogg',
		'sound/mobs/humanoids/human/cough/male_cough5.ogg',
		'sound/mobs/humanoids/human/cough/male_cough6.ogg',
	)


/datum/species/lizard/get_cry_sound(mob/living/carbon/human/lizard)
	if(lizard.physique == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/cry/female_cry1.ogg',
			'sound/mobs/humanoids/human/cry/female_cry2.ogg',
		)
	return pick(
		'sound/mobs/humanoids/human/cry/male_cry1.ogg',
		'sound/mobs/humanoids/human/cry/male_cry2.ogg',
		'sound/mobs/humanoids/human/cry/male_cry3.ogg',
	)


/datum/species/lizard/get_sneeze_sound(mob/living/carbon/human/lizard)
	if(lizard.physique == FEMALE)
		return 'sound/mobs/humanoids/human/sneeze/female_sneeze1.ogg'
	return 'sound/mobs/humanoids/human/sneeze/male_sneeze1.ogg'

/datum/species/lizard/get_laugh_sound(mob/living/carbon/human/lizard)
	return 'sound/mobs/humanoids/lizard/lizard_laugh1.ogg'

/datum/species/lizard/get_sigh_sound(mob/living/carbon/human/lizard)
	if(lizard.physique == FEMALE)
		return SFX_FEMALE_SIGH
	return SFX_MALE_SIGH

/datum/species/lizard/get_sniff_sound(mob/living/carbon/human/lizard)
	if(lizard.physique == FEMALE)
		return 'sound/mobs/humanoids/human/sniff/female_sniff.ogg'
	return 'sound/mobs/humanoids/human/sniff/male_sniff.ogg'

/datum/species/lizard/get_snore_sound(mob/living/carbon/human/lizard)
	if(lizard.physique == FEMALE)
		return SFX_SNORE_FEMALE
	return SFX_SNORE_MALE

/datum/species/lizard/get_hiss_sound(mob/living/carbon/human/lizard)
	return 'sound/mobs/humanoids/lizard/lizard_hiss.ogg'

/datum/species/lizard/get_physical_attributes()
	return "Унатхи могут выдерживать немного более высокие температуры, чем большинство видов, но они очень уязвимы к холоду \
		и не могут регулировать температуру тела внутренне, что делает вакуум космоса крайне смертоносным для них."

/datum/species/lizard/get_species_description()
	return "Унатх - ещё не получили описание, т.к. лор в разработке. :)"

/datum/species/lizard/get_species_lore()
	return list(
		"Разработка",

		"Лора",

		"В",

		"Процессе",
	)

// Override for the default temperature perks, so we can give our specific "cold blooded" perk.
/datum/species/lizard/create_pref_temperature_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "thermometer-empty",
		SPECIES_PERK_NAME = "Хладнокровность",
		SPECIES_PERK_DESC = "Унатхи имеют более высокую переносимость жарких температур, но более низкую \
			переносимость холодных температур. Кроме того, они не могут самостоятельно регулировать температуру тела - \
			они такие же холодные или тёплые, как и окружающая их среда. Оставайтесь в тепле!",
	))

	return to_add

/*
Lizard subspecies: ASHWALKERS
*/
/datum/species/lizard/ashwalker
	name = "Ash Walker"
	id = SPECIES_LIZARD_ASH
	examine_limb_id = SPECIES_LIZARD
	mutantlungs = /obj/item/organ/lungs/lavaland
	mutantbrain = /obj/item/organ/brain/primitive
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_VIRUSIMMUNE,
	)
	inherent_factions = list(FACTION_ASHWALKER)
	species_language_holder = /datum/language_holder/lizard/ash
	digitigrade_customization = DIGITIGRADE_FORCED
	examine_limb_id = SPECIES_LIZARD
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/lizard,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/lizard,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/lizard/ashwalker,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/lizard/ashwalker,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/lizard,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/lizard,
	)

/datum/species/lizard/ashwalker/get_physical_attributes()
	return "Пеплоходцы идентичны Унатхам почти во всех аспектах. \
		В отличие от них, они всегда ходят на цыпочках, могут дышать часто ядовитой атмосферой Лаваленда и устойчивы к вирусам. Обычно они неграмотны."

/*
Lizard subspecies: SILVER SCALED
*/
/datum/species/lizard/silverscale
	name = "Silver Scale"
	id = SPECIES_LIZARD_SILVER
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_REPTILE
	inherent_traits = list(
		TRAIT_HOLY,
		TRAIT_NOBREATH,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_WINE_TASTER,
	)
	mutantlungs = null
	damage_modifier = 10 //very light silvery scales soften blows
	species_language_holder = /datum/language_holder/lizard/silver
	mutanttongue = /obj/item/organ/tongue/lizard/silver
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN
	examine_limb_id = SPECIES_LIZARD
	///stored mutcolor for when we turn back off of a silverscale.
	var/old_mutcolor

/datum/species/lizard/silverscale/get_physical_attributes()
	return "Серебряная Чешуя для Унатхов - то же, что ангелы для людей. \
		В основном идентичны, они святы, не дышат, не подвержены вирусам, их шкуру нельзя пронзить, обожают вкус вина, \
		и их язык позволяет им превращаться в статую, по какой-то причине."

/datum/species/lizard/silverscale/on_species_gain(mob/living/carbon/human/new_silverscale, datum/species/old_species, pref_load, regenerate_icons)
	old_mutcolor = new_silverscale.dna.features[FEATURE_MUTANT_COLOR]
	new_silverscale.dna.features[FEATURE_MUTANT_COLOR] = "#eeeeee"
	new_silverscale.add_eye_color("#0000a0", EYE_COLOR_SPECIES_PRIORITY)
	. = ..()
	new_silverscale.add_filter("silver_glint", 2, list("type" = "outline", "color" = "#ffffff63", "size" = 2))

/datum/species/lizard/silverscale/on_species_loss(mob/living/carbon/human/was_silverscale, datum/species/new_species, pref_load)
	was_silverscale.dna.features[FEATURE_MUTANT_COLOR] = old_mutcolor
	was_silverscale.remove_eye_color(EYE_COLOR_SPECIES_PRIORITY)
	was_silverscale.remove_filter("silver_glint")
	return ..()
