/datum/species/moth
	name = "Ниан"
	plural_form = "Ниан"
	id = SPECIES_MOTH
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_BUG
	body_markings = list(
		/datum/bodypart_overlay/simple/body_marking/moth = SPRITE_ACCESSORY_NONE,
	)
	mutant_organs = list(
		/obj/item/organ/wings/moth = "Обычные",
		/obj/item/organ/antennae = "Обычные",
	)
	meat = /obj/item/food/meat/slab/human/mutant/moth
	mutanttongue = /obj/item/organ/tongue/moth
	mutanteyes = /obj/item/organ/eyes/moth
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	species_cookie = /obj/item/food/muffin/moffin
	species_language_holder = /datum/language_holder/moth
	death_sound = 'sound/mobs/humanoids/moth/moth_death.ogg'
	payday_modifier = 1.0
	family_heirlooms = list(/obj/item/flashlight/lantern/heirloom_moth)

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/moth,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/moth,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/moth,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/moth,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/moth,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/moth,
	)

/datum/species/moth/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	RegisterSignal(human_who_gained_species, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))

/datum/species/moth/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	UnregisterSignal(C, COMSIG_ATOM_ATTACKBY)

/datum/species/moth/proc/on_attackby(mob/living/source, obj/item/attacking_item, mob/living/attacker, list/modifiers, list/attack_modifiers)
	SIGNAL_HANDLER

	if(istype(attacking_item, /obj/item/melee/flyswatter))
		MODIFY_ATTACK_FORCE_MULTIPLIER(attack_modifiers, 10) // Yes, a 10x damage modifier

/datum/species/moth/randomize_features()
	var/list/features = ..()
	features[FEATURE_MOTH_MARKINGS] = pick(SSaccessories.moth_markings_list)
	return features

/datum/species/moth/get_scream_sound(mob/living/carbon/human/moth)
	return 'sound/mobs/humanoids/moth/scream_moth.ogg'

/datum/species/moth/get_cough_sound(mob/living/carbon/human/moth)
	if(moth.physique == FEMALE)
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


/datum/species/moth/get_cry_sound(mob/living/carbon/human/moth)
	if(moth.physique == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/cry/female_cry1.ogg',
			'sound/mobs/humanoids/human/cry/female_cry2.ogg',
		)
	return pick(
		'sound/mobs/humanoids/human/cry/male_cry1.ogg',
		'sound/mobs/humanoids/human/cry/male_cry2.ogg',
		'sound/mobs/humanoids/human/cry/male_cry3.ogg',
	)


/datum/species/moth/get_sneeze_sound(mob/living/carbon/human/moth)
	if(moth.physique == FEMALE)
		return 'sound/mobs/humanoids/human/sneeze/female_sneeze1.ogg'
	return 'sound/mobs/humanoids/human/sneeze/male_sneeze1.ogg'


/datum/species/moth/get_laugh_sound(mob/living/carbon/human/moth)
	return 'sound/mobs/humanoids/moth/moth_laugh1.ogg'

/datum/species/moth/get_sigh_sound(mob/living/carbon/human/moth)
	if(moth.physique == FEMALE)
		return SFX_FEMALE_SIGH
	return SFX_MALE_SIGH

/datum/species/moth/get_sniff_sound(mob/living/carbon/human/moth)
	if(moth.physique == FEMALE)
		return 'sound/mobs/humanoids/human/sniff/female_sniff.ogg'
	return 'sound/mobs/humanoids/human/sniff/male_sniff.ogg'

/datum/species/moth/get_physical_attributes()
	return "Нианы имеют большие и пушистые крылья, которые помогают им ориентироваться на станции, если гравитация отключена, путем отталкивания воздуха вокруг себя. \
		Из-за этого они не очень полезны в открытом космосе. Их глаза очень чувствительны."

/datum/species/moth/get_species_description()
	return "Ниан - ещё не получили описание, т.к. лор в разработке. :)"

/datum/species/moth/get_species_lore()
	return list(
		"Разработка",

		"Лора",

		"В",

		"Процессе",
	)

/datum/species/moth/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "feather-alt",
			SPECIES_PERK_NAME = "Драгоценные Крылья",
			SPECIES_PERK_DESC = "Нианы могут летать в условиях повышенного давления, невесомости и безопасно приземляться при коротких падениях, используя свои крылья.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "tshirt",
			SPECIES_PERK_NAME = "План Питания",
			SPECIES_PERK_DESC = "Нианы могут есть одежду для временного насыщения.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fire",
			SPECIES_PERK_NAME = "Опалённые Крылья",
			SPECIES_PERK_DESC = "Крылья Ниан хрупкие и могут быть легко сожжены.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "sun",
			SPECIES_PERK_NAME = "Яркий Свет",
			SPECIES_PERK_DESC = "Нианам нужен дополнительный слой защиты от вспышек, чтобы защитить \
				себя, например, от сотрудников службы безопасности или при сварке. Сварочные \
				маски подойдут.",
		),
	)

	return to_add
