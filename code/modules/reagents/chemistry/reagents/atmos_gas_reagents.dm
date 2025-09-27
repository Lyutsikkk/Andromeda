/datum/reagent/freon
	name = "Freon"
	description = "Мощный поглотитель тепла."
	metabolization_rate = REAGENTS_METABOLISM * 0.5 // Поскольку нитрий/фреон/гиперноблий обрабатываются через дыхание газом, метаболизм должен быть ниже, чтобы breathcode успевал
	color = "90560B"
	taste_description = "жжение"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/freon/on_mob_metabolize(mob/living/breather)
	. = ..()
	breather.add_movespeed_modifier(/datum/movespeed_modifier/reagent/freon)

/datum/reagent/freon/on_mob_end_metabolize(mob/living/breather)
	. = ..()
	breather.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/freon)

/datum/reagent/halon
	name = "Halon"
	description = "Огнетушащий газ, который удаляет кислород и охлаждает область"
	metabolization_rate = REAGENTS_METABOLISM * 0.5
	color = "90560B"
	taste_description = "мятный"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE
	metabolized_traits = list(TRAIT_RESISTHEAT)

/datum/reagent/halon/on_mob_metabolize(mob/living/breather)
	. = ..()
	breather.add_movespeed_modifier(/datum/movespeed_modifier/reagent/halon)

/datum/reagent/halon/on_mob_end_metabolize(mob/living/breather)
	. = ..()
	breather.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/halon)

/datum/reagent/healium
	name = "Healium"
	description = "Мощное снотворное средство с целебными свойствами"
	metabolization_rate = REAGENTS_METABOLISM * 0.5
	color = "90560B"
	taste_description = "резина"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/healium/on_mob_end_metabolize(mob/living/breather)
	. = ..()
	breather.SetSleeping(1 SECONDS)

/datum/reagent/healium/on_mob_life(mob/living/breather, seconds_per_tick, times_fired)
	. = ..()
	breather.SetSleeping(30 SECONDS)
	var/need_mob_update
	need_mob_update = breather.adjustFireLoss(-2 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += breather.adjustToxLoss(-5 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)
	need_mob_update += breather.adjustBruteLoss(-2 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/hypernoblium
	name = "Hyper-Noblium"
	description = "Подавляющий газ, который останавливает газовые реакции у тех, кто его вдыхает."
	metabolization_rate = REAGENTS_METABOLISM * 0.5 // Поскольку нитрий/фреон/гипер-ноблий обрабатываются через дыхание газом, метаболизм должен быть ниже, чтобы breathcode успевал
	color = "90560B"
	taste_description = "обжигающе холодный"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/hypernoblium/on_mob_life(mob/living/carbon/breather, seconds_per_tick, times_fired)
	. = ..()
	if(isplasmaman(breather))
		breather.set_timed_status_effect(10 SECONDS * REM * seconds_per_tick, /datum/status_effect/hypernob_protection)

/datum/reagent/nitrium_high_metabolization
	name = "Nitrosyl plasmide"
	description = "Высокореактивный побочный продукт, который мешает вам спать, одновременно нанося увеличивающийся урон токсинами со временем."
	metabolization_rate = REAGENTS_METABOLISM * 0.5 // Поскольку нитрий/фреон/гиперноблий обрабатываются через дыхание газом, метаболизм должен быть ниже, чтобы breathcode успевал
	color = "E1A116"
	taste_description = "кислота"
	ph = 1.8
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE
	addiction_types = list(/datum/addiction/stimulants = 14)
	metabolized_traits = list(TRAIT_SLEEPIMMUNE)

/datum/reagent/nitrium_high_metabolization/on_mob_life(mob/living/carbon/breather, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = breather.adjustStaminaLoss(-4 * REM * seconds_per_tick, updating_stamina = FALSE, required_biotype = affected_biotype)
	need_mob_update += breather.adjustToxLoss(0.1 * (current_cycle-1) * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype) // 1 toxin damage per cycle at cycle 10
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/nitrium_low_metabolization
	name = "Nitrium"
	description = "Высокореактивный газ, который заставляет вас чувствовать себя быстрее."
	metabolization_rate = REAGENTS_METABOLISM * 0.5 // Поскольку нитрий/фреон/гиперноблий обрабатываются через дыхание газом, метаболизм должен быть ниже, чтобы breathcode успевал
	color = "90560B"
	taste_description = "жжение"
	ph = 2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/nitrium_low_metabolization/on_mob_metabolize(mob/living/breather)
	. = ..()
	breather.add_movespeed_modifier(/datum/movespeed_modifier/reagent/nitrium)

/datum/reagent/nitrium_low_metabolization/on_mob_end_metabolize(mob/living/breather)
	. = ..()
	breather.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/nitrium)

/datum/reagent/pluoxium
	name = "Pluoxium"
	description = "Газ, который в восемь раз эффективнее O2 в диффузии в лёгких, с целебными свойствами для органов у спящих пациентов."
	metabolization_rate = REAGENTS_METABOLISM * 0.5
	color = COLOR_GRAY
	taste_description = "облучённый воздух"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/pluoxium/on_mob_life(mob/living/carbon/breather, seconds_per_tick, times_fired)
	. = ..()
	if(!HAS_TRAIT(breather, TRAIT_KNOCKEDOUT))
		return

	for(var/obj/item/organ/organ_being_healed as anything in breather.organs)
		if(!organ_being_healed.damage)
			continue

		if(organ_being_healed.apply_organ_damage(-0.5 * REM * seconds_per_tick, required_organ_flag = ORGAN_ORGANIC))
			. = UPDATE_MOB_HEALTH

/datum/reagent/zauker
	name = "Zauker"
	description = "Нестабильный газ, ядовитый для всех живых существ."
	metabolization_rate = REAGENTS_METABOLISM * 0.5
	color = "90560B"
	taste_description = "горечь"
	chemical_flags = REAGENT_NO_RANDOM_RECIPE
	affected_biotype = MOB_ORGANIC | MOB_MINERAL | MOB_PLANT // "toxic to all living beings"
	affected_respiration_type = ALL

/datum/reagent/zauker/on_mob_life(mob/living/breather, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = breather.adjustBruteLoss(6 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += breather.adjustOxyLoss(1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
	need_mob_update += breather.adjustFireLoss(2 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += breather.adjustToxLoss(2 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH
