

//////////////////////////////////////////////////////////////////////////////////////////
					// MEDICINE REAGENTS
//////////////////////////////////////////////////////////////////////////////////////

// where all the reagents related to medicine go.

/datum/reagent/medicine
	taste_description = "горечь"

/datum/reagent/medicine/New()
	. = ..()
	// All medicine metabolizes out slower / stay longer if you have a better metabolism
	chemical_flags |= REAGENT_REVERSE_METABOLISM

/datum/reagent/medicine/leporazine
	name = "Leporazine"
	description = "Лепоразин эффективно регулирует температуру тела пациента, гарантируя, что она никогда не выйдет за безопасные пределы."
	ph = 8.4
	color = "#DB90C6"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/leporazine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/target_temp = affected_mob.get_body_temp_normal(apply_change = FALSE)
	if(affected_mob.bodytemperature > target_temp)
		affected_mob.adjust_bodytemperature(-40 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * seconds_per_tick, target_temp)
	else if(affected_mob.bodytemperature < (target_temp + 1))
		affected_mob.adjust_bodytemperature(40 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * seconds_per_tick, 0, target_temp)
	if(ishuman(affected_mob))
		var/mob/living/carbon/human/affected_human = affected_mob
		if(affected_human.coretemperature > target_temp)
			affected_human.adjust_coretemperature(-40 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * seconds_per_tick, target_temp)
		else if(affected_human.coretemperature < (target_temp + 1))
			affected_human.adjust_coretemperature(40 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * seconds_per_tick, 0, target_temp)

/datum/reagent/medicine/adminordrazine //An OP chemical for admins
	name = "Adminordrazine"
	description = "Это магия. Мы не обязаны это объяснять."
	color = "#E0BB00" //золотой для богов
	taste_description = "бадмины"
	chemical_flags = REAGENT_DEAD_PROCESS
	metabolized_traits = list(TRAIT_ANALGESIA)
	/// Flags to fullheal every metabolism tick
	var/full_heal_flags = ~(HEAL_BRUTE|HEAL_BURN|HEAL_TOX|HEAL_RESTRAINTS|HEAL_ORGANS)

// The best stuff there is. For testing/debugging.
/datum/reagent/medicine/adminordrazine/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_waterlevel(round(volume))
	mytray.adjust_plant_health(round(volume))
	mytray.adjust_pestlevel(-rand(1,5))
	mytray.adjust_weedlevel(-rand(1,5))
	if(volume < 3)
		return

	switch(rand(100))
		if(66 to 100)
			mytray.mutatespecie()
		if(33 to 65)
			mytray.mutateweed()
		if(1 to 32)
			mytray.mutatepest(user)
		else
			if(prob(20))
				mytray.visible_message(span_warning("Ничего не происходит..."))

/datum/reagent/medicine/adminordrazine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.heal_bodypart_damage(brute = 5 * REM * seconds_per_tick, burn = 5 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	affected_mob.adjustToxLoss(-5 * REM * seconds_per_tick, updating_health = FALSE, forced = TRUE, required_biotype = affected_biotype)
	// Heal everything! That we want to. But really don't heal reagents. Otherwise we'll lose ... us.
	affected_mob.fully_heal(full_heal_flags & ~HEAL_ALL_REAGENTS) // there is no need to return UPDATE_MOB_HEALTH because this proc calls updatehealth()

/datum/reagent/medicine/adminordrazine/quantum_heal
	name = "Quantum Medicine"
	description = "Редкие и экспериментальные частицы, которые, по-видимому, меняют тело пользователя на тело из параллельного измерения, где оно полностью здорово."
	taste_description = "наука"
	full_heal_flags = ~(HEAL_ADMIN|HEAL_BRUTE|HEAL_BURN|HEAL_TOX|HEAL_RESTRAINTS|HEAL_ALL_REAGENTS|HEAL_ORGANS)

/datum/reagent/medicine/synaptizine
	name = "Synaptizine"
	description = "Повышает сопротивление оглушению, а также уменьшает сонливость и галлюцинации."
	color = COLOR_MAGENTA
	ph = 4
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/synaptizine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_drowsiness(-10 SECONDS * REM * seconds_per_tick)
	affected_mob.AdjustAllImmobility(-20 * REM * seconds_per_tick)

	if(holder.has_reagent(/datum/reagent/toxin/mindbreaker))
		holder.remove_reagent(/datum/reagent/toxin/mindbreaker, 5 * REM * seconds_per_tick)
	affected_mob.adjust_hallucinations(-20 SECONDS * REM * seconds_per_tick)
	if(SPT_PROB(16, seconds_per_tick))
		if(affected_mob.adjustToxLoss(1, updating_health = FALSE, required_biotype = affected_biotype))
			return UPDATE_MOB_HEALTH

/datum/reagent/medicine/synaphydramine
	name = "Diphen-Synaptizine"
	description = "Уменьшает сонливость, галлюцинации и гистамин в организме."
	color = "#EC536D" // rgb: 236, 83, 109
	ph = 5.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/medicine/synaphydramine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_drowsiness(-10 SECONDS * REM * seconds_per_tick)
	if(holder.has_reagent(/datum/reagent/toxin/mindbreaker))
		holder.remove_reagent(/datum/reagent/toxin/mindbreaker, 5 * REM * seconds_per_tick)
	if(holder.has_reagent(/datum/reagent/toxin/histamine))
		holder.remove_reagent(/datum/reagent/toxin/histamine, 5 * REM * seconds_per_tick)
	affected_mob.adjust_hallucinations(-20 SECONDS * REM * seconds_per_tick)
	if(SPT_PROB(16, seconds_per_tick))
		if(affected_mob.adjustToxLoss(1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
			return UPDATE_MOB_HEALTH

/datum/reagent/medicine/sansufentanyl
	name = "Sansufentanyl"
	description = "Временные побочные эффекты включают - тошноту, головокружение, нарушение двигательной координации."
	color = "#07e4d1"
	ph = 6.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/sansufentanyl/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_confusion_up_to(3 SECONDS * REM * seconds_per_tick, 5 SECONDS)
	affected_mob.adjust_dizzy_up_to(6 SECONDS * REM * seconds_per_tick, 12 SECONDS)
	if(affected_mob.adjustStaminaLoss(1 * REM * seconds_per_tick, updating_stamina = FALSE))
		. = UPDATE_MOB_HEALTH

	if(SPT_PROB(10, seconds_per_tick))
		to_chat(affected_mob, "Вы чувствуете растерянность и дезориентацию.")
		if(prob(30))
			SEND_SOUND(affected_mob, sound('sound/items/weapons/flash_ring.ogg'))

/datum/reagent/medicine/cryoxadone
	name = "Cryoxadone"
	description = "Химическая смесь с почти магическими целебными свойствами. Основное ограничение заключается в том, что температура тела пациента должна быть ниже 270K для правильного метаболизма."
	color = "#0000C8"
	taste_description = "синий"
	ph = 11
	burning_temperature = 20 //cold burning
	burning_volume = 0.1
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/cryoxadone/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	metabolization_rate = REAGENTS_METABOLISM * (0.00001 * (affected_mob.bodytemperature ** 2) + 0.5)
	if(affected_mob.bodytemperature >= T0C || !HAS_TRAIT(affected_mob, TRAIT_KNOCKEDOUT))
		return
	var/power = -0.00003 * (affected_mob.bodytemperature ** 2) + 3
	var/need_mob_update
	need_mob_update = affected_mob.adjustOxyLoss(-3 * power * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
	need_mob_update += affected_mob.adjustBruteLoss(-power * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += affected_mob.adjustFireLoss(-power * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += affected_mob.adjustToxLoss(-power * REM * seconds_per_tick, updating_health = FALSE, forced = TRUE, required_biotype = affected_biotype) //heals TOXINLOVERs
	for(var/i in affected_mob.all_wounds)
		var/datum/wound/iter_wound = i
		iter_wound.on_xadone(power * REM * seconds_per_tick)
	REMOVE_TRAIT(affected_mob, TRAIT_DISFIGURED, TRAIT_GENERIC) //fixes common causes for disfiguration
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

// Healing
/datum/reagent/medicine/cryoxadone/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_plant_health(round(volume * 3))
	mytray.adjust_toxic(-round(volume * 3))

/datum/reagent/medicine/pyroxadone
	name = "Pyroxadone"
	description = "Смесь криоксадона и желе слаймов, которая, по-видимому, обращает требование для его активации."
	color = "#f7832a"
	taste_description = "острое желе"
	ph = 12
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/pyroxadone/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT)
		var/power = 0
		switch(affected_mob.bodytemperature)
			if(BODYTEMP_HEAT_DAMAGE_LIMIT to 400)
				power = 2
			if(400 to 460)
				power = 3
			else
				power = 5
		if(affected_mob.on_fire)
			power *= 2

		var/need_mob_update
		need_mob_update = affected_mob.adjustOxyLoss(-2 * power * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
		need_mob_update += affected_mob.adjustBruteLoss(-power * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
		need_mob_update += affected_mob.adjustFireLoss(-1.5 * power * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
		need_mob_update += affected_mob.adjustToxLoss(-power * REM * seconds_per_tick, updating_health = FALSE, forced = TRUE, required_biotype = affected_biotype)
		if(need_mob_update)
			. = UPDATE_MOB_HEALTH
		for(var/i in affected_mob.all_wounds)
			var/datum/wound/iter_wound = i
			iter_wound.on_xadone(power * REM * seconds_per_tick)
		REMOVE_TRAIT(affected_mob, TRAIT_DISFIGURED, TRAIT_GENERIC)

/datum/reagent/medicine/rezadone
	name = "Rezadone"
	description = "Порошок, полученный из рыбьего токсина. Резадон может эффективно восстанавливать трупы, обугленные ожогами, а также лечить небольшие раны. Передозировка вызовет сильное тошноту и незначительный урон токсинами."
	color = "#669900" // rgb: 102, 153, 0
	overdose_threshold = 30
	ph = 12.2
	taste_description = "рыба"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	inverse_chem_val = 0.25
	inverse_chem = /datum/reagent/inverse/rezadone

// Rezadone is almost never used in favor of cryoxadone. Hopefully this will change that. // No such luck so far // with clone damage gone, someone will find a better use for rezadone... right?
/datum/reagent/medicine/rezadone/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.heal_bodypart_damage(
		brute = 1 * REM * seconds_per_tick,
		burn = 1 * REM * seconds_per_tick,
		updating_health = FALSE,
		required_bodytype = affected_biotype
	))
		. = UPDATE_MOB_HEALTH
	REMOVE_TRAIT(affected_mob, TRAIT_DISFIGURED, TRAIT_GENERIC)

/datum/reagent/medicine/rezadone/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.adjustToxLoss(1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
		. = UPDATE_MOB_HEALTH
	affected_mob.set_dizzy_if_lower(10 SECONDS * REM * seconds_per_tick)
	affected_mob.set_jitter_if_lower(10 SECONDS * REM * seconds_per_tick)

/datum/reagent/medicine/rezadone/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if(!iscarbon(exposed_mob))
		return

	var/functional_react_volume = reac_volume * (1 - touch_protection)

	var/mob/living/carbon/patient = exposed_mob
	if(functional_react_volume >= 5 && HAS_TRAIT_FROM(patient, TRAIT_HUSK, BURN) && patient.getFireLoss() < UNHUSK_DAMAGE_THRESHOLD) //One carp yields 12u rezadone.
		patient.cure_husk(BURN)
		patient.visible_message(span_nicegreen("Тело [patient] быстро поглощает влагу из окружающей среды, приобретая более здоровый вид."))

/datum/reagent/medicine/spaceacillin
	name = "Spaceacillin"
	description = "Спейсациллин оказывает ограниченную устойчивость к болезням и паразитам. Также уменьшает инфекцию при серьезных ожогах."
	color = "#E1F2E6"
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	ph = 8.1
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	inverse_chem_val = 0.3
	inverse_chem = /datum/reagent/inverse/spaceacillin
	added_traits = list(TRAIT_VIRUS_RESISTANCE)

//Goon Chems. Ported mainly from Goonstation. Easily mixable (or not so easily) and provide a variety of effects.

/datum/reagent/medicine/oxandrolone
	name = "Oxandrolone"
	description = "Стимулирует заживление тяжелых ожогов. Чрезвычайно быстро заживляет сильные ожоги и медленно заживляет легкие. Передозировка усугубит существующие ожоги."
	color = "#1E8BFF"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 25
	ph = 10.7
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	inverse_chem_val = 0.3
	inverse_chem = /datum/reagent/inverse/oxandrolone

/datum/reagent/medicine/oxandrolone/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	if(affected_mob.getFireLoss() > 25)
		need_mob_update = affected_mob.adjustFireLoss(-4 * REM * seconds_per_tick * normalise_creation_purity(), updating_health = FALSE, required_bodytype = affected_bodytype) //Twice as effective as AIURI for severe burns
	else
		need_mob_update = affected_mob.adjustFireLoss(-0.5 * REM * seconds_per_tick * normalise_creation_purity(), updating_health = FALSE, required_bodytype = affected_bodytype) //But only a quarter as effective for more minor ones
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/oxandrolone/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.getFireLoss()) //It only makes existing burns worse
		if(affected_mob.adjustFireLoss(4.5 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_biotype)) // it's going to be healing either 4 or 0.5
			return UPDATE_MOB_HEALTH

/datum/reagent/medicine/salglu_solution
	name = "Saline-Glucose Solution"
	description = "Имеет 33% шанс за цикл микроволновки вылечить грубую силу и урон от ожога. Может использоваться как временный заменитель крови, а также медленно ускоряет регенерацию крови."
	color = "#DCDCDC"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 60
	taste_description = "сладость и соль"
	var/last_added = 0
	var/maximum_reachable = BLOOD_VOLUME_NORMAL - 10 //So that normal blood regeneration can continue with salglu active
	var/extra_regen = 0.25 // in addition to acting as temporary blood, also add about half this much to their actual blood per second
	ph = 5.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/salglu_solution/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update = FALSE
	if(SPT_PROB(18, seconds_per_tick))
		need_mob_update = affected_mob.adjustBruteLoss(-0.5 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_biotype)
		need_mob_update += affected_mob.adjustFireLoss(-0.5 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_biotype)
	var/datum/blood_type/blood_type = affected_mob.get_bloodtype()
	// Only suppliments base blood types
	if(blood_type?.restoration_chem != /datum/reagent/iron)
		return need_mob_update ? UPDATE_MOB_HEALTH : null
	if(last_added)
		affected_mob.blood_volume -= last_added
		last_added = 0
	if(affected_mob.blood_volume < maximum_reachable) //Can only up to double your effective blood level.
		var/amount_to_add = min(affected_mob.blood_volume, 5*volume)
		var/new_blood_level = min(affected_mob.blood_volume + amount_to_add, maximum_reachable)
		last_added = new_blood_level - affected_mob.blood_volume
		affected_mob.blood_volume = new_blood_level + (extra_regen * REM * seconds_per_tick)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/salglu_solution/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	if(SPT_PROB(1.5, seconds_per_tick))
		if(holder)
			to_chat(affected_mob, span_warning("Вы чувствуете солёность."))
			holder.add_reagent(/datum/reagent/consumable/salt, 1)
			holder.remove_reagent(/datum/reagent/medicine/salglu_solution, 0.5)
	else if(SPT_PROB(1.5, seconds_per_tick))
		if(holder)
			to_chat(affected_mob, span_warning("Вы чувствуете сладость."))
			holder.add_reagent(/datum/reagent/consumable/sugar, 1)
			holder.remove_reagent(/datum/reagent/medicine/salglu_solution, 0.5)
	if(SPT_PROB(18, seconds_per_tick))
		need_mob_update = affected_mob.adjustBruteLoss(0.5 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_biotype)
		need_mob_update += affected_mob.adjustFireLoss(0.5 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_biotype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/mine_salve
	name = "Miner's Salve"
	description = "Мощное обезболивающее. Восстанавливает ушибы и ожоги, а также заставляет пациента поверить, что он полностью исцелён. Также отлично подходит для лечения тяжелых ожоговых ран в редких случаях."
	color = "#6D6374"
	metabolization_rate = 0.4 * REAGENTS_METABOLISM
	ph = 2.6
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_AFFECTS_WOUNDS
	metabolized_traits = list(TRAIT_ANALGESIA)

/datum/reagent/medicine/mine_salve/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustBruteLoss(-0.25 * REM * seconds_per_tick, FALSE, required_bodytype = affected_bodytype)
	need_mob_update += affected_mob.adjustFireLoss(-0.25 * REM * seconds_per_tick, FALSE, required_bodytype = affected_bodytype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/mine_salve/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if(!iscarbon(exposed_mob) || (exposed_mob.stat == DEAD))
		return

	if(methods & (INGEST|VAPOR|INJECT|INHALE))
		var/miner_cramps = 5 * (1 - touch_protection)
		if(miner_cramps)
			exposed_mob.adjust_nutrition(-miner_cramps)
			if(show_message)
				to_chat(exposed_mob, span_warning("Ваш желудок пуст и сводит судорогой!"))

	if(methods & (PATCH|TOUCH))
		var/mob/living/carbon/exposed_carbon = exposed_mob
		for(var/datum/surgery/surgery as anything in exposed_carbon.surgeries)
			surgery.speed_modifier = min(0.9, surgery.speed_modifier)

		if(show_message)
			to_chat(exposed_carbon, span_danger("Вы чувствуете, как ваши травмы исчезают в ничто!") )

/datum/reagent/medicine/mine_salve/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.apply_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)

/datum/reagent/medicine/mine_salve/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.remove_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)

/datum/reagent/medicine/mine_salve/on_burn_wound_processing(datum/wound/burn/flesh/burn_wound)
	burn_wound.sanitization += 0.3
	burn_wound.flesh_healing += 0.5

/datum/reagent/medicine/omnizine
	name = "Omnizine"
	description = "Медленно излечивает все виды урона. Передозировка вместо этого нанесёт урон всех видов."
	color = "#DCDCDC"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30
	var/healing = 0.5
	ph = 2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/omnizine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustToxLoss(-healing * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)
	need_mob_update += affected_mob.adjustOxyLoss(-healing * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
	need_mob_update += affected_mob.adjustBruteLoss(-healing * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += affected_mob.adjustFireLoss(-healing * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/omnizine/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustToxLoss(1.5 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)
	need_mob_update += affected_mob.adjustOxyLoss(1.5 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
	need_mob_update += affected_mob.adjustBruteLoss(1.5 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += affected_mob.adjustFireLoss(1.5 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/omnizine/protozine
	name = "Protozine"
	description = "Менее экологичный и несколько более слабый вариант омнизина."
	color = "#d8c7b7"
	healing = 0.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/calomel
	name = "Calomel"
	description = "Быстро очищает организм от всех химикатов, кроме себя. Чем больше здоровья у человека, \
		тем больше урона токсинами он нанесёт. Может лечить урон токсинами, когда у людей достаточно низкое здоровье."
	color = "#c85319"
	metabolization_rate = 1 * REAGENTS_METABOLISM
	taste_description = "кислота"
	overdose_threshold = 20
	ph = 1.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/calomel/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	for(var/datum/reagent/target_reagent as anything in affected_mob.reagents.reagent_list)
		if(istype(target_reagent, /datum/reagent/medicine/calomel))
			continue
		affected_mob.reagents.remove_reagent(target_reagent.type, 3 * target_reagent.purge_multiplier * REM * seconds_per_tick)
	var/toxin_amount = round(affected_mob.health / 40, 0.1)
	if(affected_mob.adjustToxLoss(toxin_amount * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/calomel/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.reagents.remove_reagent(type, 2 * REM * seconds_per_tick)
	if(affected_mob.adjustToxLoss(2.5 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/ammoniated_mercury
	name = "Ammoniated Mercury"
	description = "Быстро очищает организм от токсичных химикатов. Лечит урон токсинами, когда в хорошем состоянии у кого-то \
		нет физического и ожогового урона. При наличии физического или ожогового урона может нанести большое количество урона токсинами. \
		Когда токсины отсутствуют, начинает медленно очищать себя."
	color = "#f3f1f0"
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	taste_description = "металл"
	overdose_threshold = 10
	ph = 7
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	inverse_chem_val = 0.50
	inverse_chem = /datum/reagent/inverse/ammoniated_mercury

/datum/reagent/medicine/ammoniated_mercury/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/toxin_chem_amount = 0
	for(var/datum/reagent/toxin/target_reagent in affected_mob.reagents.reagent_list)
		toxin_chem_amount += 1
		affected_mob.reagents.remove_reagent(target_reagent.type, 5 * target_reagent.purge_multiplier * REM * seconds_per_tick)
	var/toxin_amount = round(affected_mob.getBruteLoss() / 15, 0.1) + round(affected_mob.getFireLoss() / 30, 0.1) - 3
	if(affected_mob.adjustToxLoss(toxin_amount * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
		. = UPDATE_MOB_HEALTH
	if(toxin_chem_amount == 0)
		for(var/datum/reagent/medicine/ammoniated_mercury/target_reagent in affected_mob.reagents.reagent_list)
			affected_mob.reagents.remove_reagent(target_reagent.type, 1 * REM * seconds_per_tick)

/datum/reagent/medicine/ammoniated_mercury/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.adjustToxLoss(3 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/potass_iodide
	name = "Potassium Iodide"
	description = "Лечит небольшой урон токсинами, пока пациент облучён, и останавливает повреждающие эффекты радиации."
	color = "#BAA15D"
	metabolization_rate = 2 * REAGENTS_METABOLISM
	ph = 12 //It's a reducing agent
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	metabolized_traits = list(TRAIT_HALT_RADIATION_EFFECTS)

/datum/reagent/medicine/potass_iodide/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(HAS_TRAIT(affected_mob, TRAIT_IRRADIATED))
		if(affected_mob.adjustToxLoss(-1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
			return UPDATE_MOB_HEALTH

/datum/reagent/medicine/pen_acid
	name = "Pentetic Acid"
	description = "Уменьшает большое количество урона токсинами, одновременно очищая организм от других химикатов."
	color = "#E6FFF0"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	ph = 1 //One of the best buffers, NEVERMIND!
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	inverse_chem_val = 0.4
	inverse_chem = /datum/reagent/inverse/pen_acid
	metabolized_traits = list(TRAIT_HALT_RADIATION_EFFECTS)

/datum/reagent/medicine/pen_acid/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.adjustToxLoss(-2 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
		. = UPDATE_MOB_HEALTH
	for(var/datum/reagent/reagent as anything in affected_mob.reagents.reagent_list)
		if(reagent != src)
			affected_mob.reagents.remove_reagent(reagent.type, 2 * reagent.purge_multiplier * REM * seconds_per_tick)

/datum/reagent/medicine/sal_acid
	name = "Salicylic Acid"
	description = "Стимулирует заживление сильных ушибов. Чрезвычайно быстро заживляет сильные ушибы и медленно заживляет незначительные. Передозировка усугубит существующие ушибы."
	color = "#D2D2D2"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 25
	ph = 2.1
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	inverse_chem_val = 0.3
	inverse_chem = /datum/reagent/inverse/sal_acid

/datum/reagent/medicine/sal_acid/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	if(affected_mob.getBruteLoss() > 25)
		need_mob_update = affected_mob.adjustBruteLoss(-4 * REM * seconds_per_tick * normalise_creation_purity(), updating_health = FALSE, required_bodytype = affected_bodytype)
	else
		need_mob_update = affected_mob.adjustBruteLoss(-0.5 * REM * seconds_per_tick * normalise_creation_purity(), updating_health = FALSE, required_bodytype = affected_bodytype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/sal_acid/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.getBruteLoss()) //It only makes existing bruises worse
		if(affected_mob.adjustBruteLoss(4.5 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)) // it's going to be healing either 4 or 0.5
			return UPDATE_MOB_HEALTH

/datum/reagent/medicine/salbutamol
	name = "Salbutamol"
	description = "Быстро восстанавливает кислородное голодание, а также в некоторой степени предотвращает его."
	color = COLOR_CYAN
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	ph = 2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	inverse_chem_val = 0.25
	inverse_chem = /datum/reagent/inverse/salbutamol

/datum/reagent/medicine/salbutamol/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustOxyLoss(-3 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
	if(affected_mob.losebreath >= 4)
		var/obj/item/organ/lungs/affected_lungs = affected_mob.get_organ_slot(ORGAN_SLOT_LUNGS)
		var/our_respiration_type = affected_lungs ? affected_lungs.respiration_type : affected_mob.mob_respiration_type // use lungs' respiration type or mob_respiration_type if no lungs
		if(our_respiration_type & affected_respiration_type)
			affected_mob.losebreath -= 2 * REM * seconds_per_tick
			need_mob_update = TRUE
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/albuterol
	name = "Albuterol"
	description = "Мощный бронходилататор, способный увеличить количество газа, вдыхаемого лёгкими. Высокоэффективен для прекращения приступов астмы, \
		но только при ингаляции. Передозировка вызывает чрезмерное расширение, приводя к снижению функции лёгких."
	taste_description = "горький и солёный воздух"
	overdose_threshold = 30
	color = "#8df5f0"
	metabolization_rate = REAGENTS_METABOLISM
	ph = 4
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/inhaler_canister

	/// The decrement we will apply to the received_pressure_mult of our targets lungs.
	var/pressure_mult_increment = 0.4
	/// After this many cycles of overdose, we activate secondary effects.
	var/secondary_overdose_effect_cycle_threshold = 40
	/// We stop increasing stamina damage once we reach this number.
	var/maximum_od_stamina_damage = 80

/datum/reagent/medicine/albuterol/on_mob_metabolize(mob/living/affected_mob)
	. = ..()

	if (!iscarbon(affected_mob))
		return

	// has additional effects on asthma, but that's handled in the quirk

	RegisterSignal(affected_mob, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(holder_lost_organ))
	RegisterSignal(affected_mob, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(holder_gained_organ))
	var/mob/living/carbon/carbon_mob = affected_mob
	var/obj/item/organ/lungs/holder_lungs = carbon_mob.get_organ_slot(ORGAN_SLOT_LUNGS)
	holder_lungs?.adjust_received_pressure_mult(pressure_mult_increment)

/datum/reagent/medicine/albuterol/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()

	if (!iscarbon(affected_mob))
		return

	UnregisterSignal(affected_mob, list(COMSIG_CARBON_LOSE_ORGAN, COMSIG_CARBON_GAIN_ORGAN))
	var/mob/living/carbon/carbon_mob = affected_mob
	var/obj/item/organ/lungs/holder_lungs = carbon_mob.get_organ_slot(ORGAN_SLOT_LUNGS)
	holder_lungs?.adjust_received_pressure_mult(-pressure_mult_increment)

/datum/reagent/medicine/albuterol/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()

	if (!iscarbon(affected_mob))
		return

	var/mob/living/carbon/carbon_mob = affected_mob
	if (SPT_PROB(25, seconds_per_tick))
		carbon_mob.adjust_jitter_up_to(2 SECONDS, 20 SECONDS)
	if (SPT_PROB(35, seconds_per_tick))
		if (prob(60))
			carbon_mob.losebreath += 1
			to_chat(affected_mob, span_danger("Ваша диафрагма спазмирует, и вы обнаруживаете, что не можете дышать!"))
		else
			carbon_mob.breathe(seconds_per_tick, times_fired)
			to_chat(affected_mob, span_danger("Ваша диафрагма спазмирует, и вы непреднамеренно делаете вдох!"))

	if (current_cycle > secondary_overdose_effect_cycle_threshold)
		if (SPT_PROB(30, seconds_per_tick))
			carbon_mob.adjust_eye_blur_up_to(6 SECONDS, 30 SECONDS)
		if (carbon_mob.getStaminaLoss() < maximum_od_stamina_damage)
			carbon_mob.adjustStaminaLoss(seconds_per_tick)

/datum/reagent/medicine/albuterol/proc/holder_lost_organ(datum/source, obj/item/organ/lost)
	SIGNAL_HANDLER

	if (istype(lost, /obj/item/organ/lungs))
		var/obj/item/organ/lungs/holder_lungs = lost
		holder_lungs.adjust_received_pressure_mult(-pressure_mult_increment)

/datum/reagent/medicine/albuterol/proc/holder_gained_organ(datum/source, obj/item/organ/gained)
	SIGNAL_HANDLER

	if (istype(gained, /obj/item/organ/lungs))
		var/obj/item/organ/lungs/holder_lungs = gained
		holder_lungs.adjust_received_pressure_mult(pressure_mult_increment)

/datum/reagent/medicine/ephedrine
	name = "Ephedrine"
	description = "Повышает сопротивление дубинкам и скорость движения, вызывая судороги в руках. Передозировка наносит урон токсинами и затрудняет дыхание."
	color = "#D2FFFA"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 30
	ph = 12
	purity = REAGENT_STANDARD_PURITY
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/stimulants = 4) //1.6 per 2 seconds
	inverse_chem = /datum/reagent/inverse/corazargh
	inverse_chem_val = 0.4
	metabolized_traits = list(TRAIT_BATON_RESISTANCE, TRAIT_STIMULATED)

/datum/reagent/medicine/ephedrine/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/ephedrine)
	var/purity_movespeed_accounting = -0.375 * normalise_creation_purity()
	affected_mob.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/reagent/ephedrine, TRUE, purity_movespeed_accounting)

/datum/reagent/medicine/ephedrine/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/ephedrine)

/datum/reagent/medicine/ephedrine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/obj/item/active_held_item = affected_mob.get_active_held_item()
	if(SPT_PROB(10 * (1.5-creation_purity), seconds_per_tick) && iscarbon(affected_mob) && active_held_item?.w_class > WEIGHT_CLASS_SMALL)
		if(active_held_item && affected_mob.dropItemToGround(active_held_item))
			to_chat(affected_mob, span_notice("Ваши руки дёргаются и вы роняете то, что держали!"))
			affected_mob.set_jitter_if_lower(20 SECONDS)

	affected_mob.AdjustAllImmobility(-20 * REM * seconds_per_tick * normalise_creation_purity())
	affected_mob.adjustStaminaLoss(-4 * REM * seconds_per_tick * normalise_creation_purity(), updating_stamina = FALSE)

	return UPDATE_MOB_HEALTH

/datum/reagent/medicine/ephedrine/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(1 * (1 + (1-normalise_creation_purity())), seconds_per_tick) && iscarbon(affected_mob))
		affected_mob.apply_status_effect(/datum/status_effect/heart_attack)
		to_chat(affected_mob, span_userdanger("Вы почти уверены, что только что почувствовали, как ваше сердце остановилось на секунду..."))
		affected_mob.playsound_local(affected_mob, 'sound/effects/singlebeat.ogg', 100, 0)

	if(SPT_PROB(3.5 * (1 + (1-normalise_creation_purity())), seconds_per_tick))
		to_chat(affected_mob, span_notice("[pick("Ваша голова пульсирует.", "Вы чувствуете сжимающую боль в груди.", "Вам трудно оставаться на месте.", "Вы чувствуете, как ваше сердце практически выпрыгивает из груди.")]"))

	if(SPT_PROB(18 * (1 + (1-normalise_creation_purity())), seconds_per_tick))
		affected_mob.adjustToxLoss(1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)
		affected_mob.losebreath++
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/diphenhydramine
	name = "Diphenhydramine"
	description = "Быстро очищает организм от гистамина и уменьшает дрожь. Небольшая вероятность вызвать сонливость."
	color = "#64FFE6"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	ph = 11.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/diphenhydramine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(5, seconds_per_tick))
		affected_mob.adjust_drowsiness(2 SECONDS)
	affected_mob.adjust_jitter(-2 SECONDS * REM * seconds_per_tick)
	holder.remove_reagent(/datum/reagent/toxin/histamine, 3 * REM * seconds_per_tick)

/datum/reagent/medicine/morphine
	name = "Morphine"
	description = "Обезболивающее, которое позволяет пациенту двигаться на полной скорости даже при травмах. Вызывает сонливость и в конечном итоге бессознательное состояние в высоких дозах. Передозировка вызывает различные эффекты, от незначительных до смертельных."
	color = "#A9FBFB"
	taste_description = "парфюмерная, горькая ваниль"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 30
	ph = 8.96
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/opioids = 20) // 30 units of morphine may cause addition
	metabolized_traits = list(TRAIT_ANALGESIA)

/datum/reagent/medicine/morphine/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)

/datum/reagent/medicine/morphine/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)

/datum/reagent/medicine/morphine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(current_cycle > 5)
		affected_mob.add_mood_event("numb", /datum/mood_event/narcotic_medium, name)
	if(affected_mob.disgust < DISGUST_LEVEL_VERYGROSS && SPT_PROB(50 * (2 - creation_purity), seconds_per_tick))
		affected_mob.adjust_disgust(1.5 * REM * seconds_per_tick)

	switch(current_cycle)
		if(16) //~3u
			to_chat(affected_mob, span_warning("Вы начинаете чувствовать усталость..."))
			affected_mob.adjust_eye_blur(2 SECONDS * REM * seconds_per_tick)
			if(SPT_PROB(66, seconds_per_tick))
				affected_mob.emote("yawn")

		if(24 to 36) // 5u to 7.5u
			if(SPT_PROB(66 * (2 - creation_purity), seconds_per_tick))
				affected_mob.adjust_drowsiness_up_to(2 SECONDS * REM * seconds_per_tick, 12 SECONDS)

		if(36 to 48) // 7.5u to 10u
			affected_mob.adjust_drowsiness_up_to(2 SECONDS * REM * seconds_per_tick, 12 SECONDS)

		if(48 to INFINITY) //10u onward
			affected_mob.adjust_drowsiness_up_to(3 SECONDS * REM * seconds_per_tick, 20 SECONDS)
			// doesn't scale from purity - at this point it tries to guarantee sleep
			if(SPT_PROB(30 * (48 - current_cycle), seconds_per_tick))
				affected_mob.Sleeping(4 SECONDS * REM * seconds_per_tick)

/datum/reagent/medicine/morphine/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(18, seconds_per_tick))
		affected_mob.drop_all_held_items()
		affected_mob.set_dizzy_if_lower(4 SECONDS)
		affected_mob.set_jitter_if_lower(4 SECONDS)


/datum/reagent/medicine/oculine
	name = "Oculine"
	description = "Быстро восстанавливает повреждения глаз, лечит близорукость и имеет шанс вернуть зрение слепым."
	color = "#404040" //окулин тёмно-серый, инакузиат светло-серый
	metabolization_rate = 1 * REAGENTS_METABOLISM
	overdose_threshold = 30
	taste_description = "землистая горечь"
	purity = REAGENT_STANDARD_PURITY
	ph = 10
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	inverse_chem = /datum/reagent/inverse/oculine
	inverse_chem_val = 0.45
	///The lighting alpha that the mob had on addition
	var/delta_light

/datum/reagent/medicine/oculine/on_mob_add(mob/living/affected_mob)
	if(!iscarbon(affected_mob))
		return
	RegisterSignal(affected_mob, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(on_gained_organ))
	RegisterSignal(affected_mob, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_removed_organ))
	var/obj/item/organ/eyes/eyes = affected_mob.get_organ_slot(ORGAN_SLOT_EYES)
	if(!eyes)
		return
	improve_eyesight(affected_mob, eyes)


/datum/reagent/medicine/oculine/proc/improve_eyesight(mob/living/carbon/affected_mob, obj/item/organ/eyes/eyes)
	delta_light = creation_purity*10
	eyes.lighting_cutoff += delta_light
	affected_mob.update_sight()

/datum/reagent/medicine/oculine/proc/restore_eyesight(mob/living/carbon/affected_mob, obj/item/organ/eyes/eyes)
	eyes.lighting_cutoff -= delta_light
	affected_mob.update_sight()

/datum/reagent/medicine/oculine/proc/on_gained_organ(mob/affected_mob, obj/item/organ/organ)
	SIGNAL_HANDLER
	if(!istype(organ, /obj/item/organ/eyes))
		return
	var/obj/item/organ/eyes/affected_eyes = organ
	improve_eyesight(affected_mob, affected_eyes)

/datum/reagent/medicine/oculine/proc/on_removed_organ(mob/prev_affected_mob, obj/item/organ/organ)
	SIGNAL_HANDLER
	if(!istype(organ, /obj/item/organ/eyes))
		return
	var/obj/item/organ/eyes/eyes = organ
	restore_eyesight(prev_affected_mob, eyes)

/datum/reagent/medicine/oculine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/normalized_purity = normalise_creation_purity()
	affected_mob.adjust_temp_blindness(-4 SECONDS * REM * seconds_per_tick * normalized_purity)
	affected_mob.adjust_eye_blur(-4 SECONDS * REM * seconds_per_tick * normalized_purity)
	var/obj/item/organ/eyes/eyes = affected_mob.get_organ_slot(ORGAN_SLOT_EYES)
	if(eyes)
		// Healing eye damage will cure nearsightedness and blindness from ... eye damage
		if(eyes.apply_organ_damage(-2 * REM * seconds_per_tick * normalise_creation_purity(), required_organ_flag = affected_organ_flags))
			. = UPDATE_MOB_HEALTH
		// If our eyes are seriously damaged, we have a probability of causing eye blur while healing depending on purity
		if(eyes.damaged && IS_ORGANIC_ORGAN(eyes) && SPT_PROB(16 - min(normalized_purity * 6, 12), seconds_per_tick))
			// While healing, gives some eye blur
			if(affected_mob.is_blind_from(EYE_DAMAGE))
				to_chat(affected_mob, span_warning("Ваше зрение медленно возвращается..."))
				affected_mob.adjust_eye_blur(20 SECONDS)
			else if(affected_mob.is_nearsighted_from(EYE_DAMAGE))
				to_chat(affected_mob, span_warning("Чернота в вашем периферийном зрении начинает исчезать."))
				affected_mob.adjust_eye_blur(5 SECONDS)

/datum/reagent/medicine/oculine/on_mob_delete(mob/living/affected_mob)
	. = ..()
	var/obj/item/organ/eyes/eyes = affected_mob.get_organ_slot(ORGAN_SLOT_EYES)
	if(!eyes)
		return
	restore_eyesight(affected_mob, eyes)

/datum/reagent/medicine/oculine/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.adjustOrganLoss(ORGAN_SLOT_EYES, 1.5 * REM * seconds_per_tick, required_organ_flag = affected_organ_flags))
		. = UPDATE_MOB_HEALTH

/datum/reagent/medicine/oculine/flumpuline
	name = "Flumpuline"
	description = "Часто путают с Окулином или его вариацией, либо продают как таковой. Медленно превращает глаза пациента в гротескные стебельки - но вам больше никогда не понадобятся очки."
	color = "#6c596d"
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	overdose_threshold = 5
	taste_description = "грибы"
	purity = 1
	ph = 0.01
	chemical_flags = REAGENT_DEAD_PROCESS|REAGENT_IGNORE_STASIS|REAGENT_NO_RANDOM_RECIPE|REAGENT_CAN_BE_SYNTHESIZED
	inverse_chem = /datum/reagent/inverse
	inverse_chem_val = 0
	var/static/list/eye_types = list(/obj/item/organ/eyes/snail, /obj/item/organ/eyes/night_vision/mushroom)

/datum/reagent/medicine/oculine/flumpuline/improve_eyesight(mob/living/carbon/affected_mob, obj/item/organ/eyes/eyes)
	delta_light = 200 //2x better than pure oculine
	eyes.lighting_cutoff += delta_light
	affected_mob.update_sight()

/datum/reagent/medicine/oculine/flumpuline/restore_eyesight(mob/living/carbon/affected_mob, obj/item/organ/eyes/eyes)
	eyes.lighting_cutoff -= delta_light
	affected_mob.update_sight()

/datum/reagent/medicine/oculine/flumpuline/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/obj/item/organ/eyes/eyes = affected_mob.get_organ_slot(ORGAN_SLOT_EYES)
	// if no eyes or inorganic do nothing. we let already changed eyes go because funny
	if(!eyes || !IS_ORGANIC_ORGAN(eyes))
		return .

	if(!prob(2))
		return .

	flump_eyes(affected_mob, eyes)

// Overdose causes constant eye popping
/datum/reagent/medicine/oculine/flumpuline/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(!prob(25))
		return
	var/obj/item/organ/eyes/eyes = affected_mob.get_organ_slot(ORGAN_SLOT_EYES)

	flump_eyes(affected_mob, eyes)

/datum/reagent/medicine/oculine/flumpuline/proc/flump_eyes(mob/affected_mob, obj/eyes)
	var/obj/item/organ/eyes/new_eyes = pick(eye_types)
	new_eyes = new new_eyes(affected_mob)
	new_eyes.Insert(affected_mob)
	playsound(affected_mob, 'sound/effects/cartoon_sfx/cartoon_pop.ogg', 50, TRUE)
	affected_mob.visible_message(span_danger("[eyes ? "Глаза [affected_mob]" : "Глазные впадины [affected_mob]"] внезапно выпускают стебельки и превращаются в [new_eyes]!"))
	ASYNC
		affected_mob.emote("scream")
		sleep(5 SECONDS)
		if(!QDELETED(eyes))
			eyes.visible_message(span_danger("[eyes] быстро превращаются в пыль."))
			eyes.dust()

/datum/reagent/medicine/inacusiate
	name = "Inacusiate"
	description = "Быстро восстанавливает повреждения ушей пациента, чтобы вылечить глухоту, при условии, что источник этой глухоты не связан с генетическими мутациями, хронической глухотой или полным отсутствием ушей." //by "chronic" deafness, we mean people with the "deaf" quirk
	color = "#606060" // ditto
	ph = 2
	purity = REAGENT_STANDARD_PURITY
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	inverse_chem_val = 0.3
	inverse_chem = /datum/reagent/impurity/inacusiate

/datum/reagent/medicine/inacusiate/on_mob_add(mob/living/affected_mob, amount)
	. = ..()
	if(creation_purity >= 1)
		ADD_TRAIT(affected_mob, TRAIT_GOOD_HEARING, type)
		if(affected_mob.can_hear())
			to_chat(affected_mob, span_nicegreen("You can feel your hearing drastically improve!"))

/datum/reagent/medicine/inacusiate/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/obj/item/organ/ears/ears = affected_mob.get_organ_slot(ORGAN_SLOT_EARS)
	if(!ears)
		return
	ears.adjustEarDamage(-4 * REM * seconds_per_tick * normalise_creation_purity(), -4 * REM * seconds_per_tick * normalise_creation_purity())
	return UPDATE_MOB_HEALTH

/datum/reagent/medicine/inacusiate/on_mob_delete(mob/living/affected_mob)
	. = ..()
	REMOVE_TRAIT(affected_mob, TRAIT_GOOD_HEARING, type)
	if(affected_mob.can_hear())
		to_chat(affected_mob, span_notice("Ваш слух возвращается к своей нормпльной остроте."))

/datum/reagent/medicine/atropine
	name = "Atropine"
	description = "Если пациент находится в критическом состоянии, быстро лечит все виды урона, а также регулирует кислород в организме. Отлично подходит для стабилизации раненых пациентов и, как говорят, нейтрализует кровоактивируемые внутренние взрывные устройства, встречающиеся среди агентов тайных чёрных операций."
	color = "#1D3535" //slightly more blue, like epinephrine
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 35
	ph = 12
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	inverse_chem_val = 0.35
	inverse_chem = /datum/reagent/inverse/atropine
	added_traits = list(TRAIT_PREVENT_IMPLANT_AUTO_EXPLOSION)

/datum/reagent/medicine/atropine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.health <= affected_mob.crit_threshold)
		var/need_mob_update
		need_mob_update = affected_mob.adjustToxLoss(-2 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)
		need_mob_update += affected_mob.adjustBruteLoss(-2* REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
		need_mob_update += affected_mob.adjustFireLoss(-2 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
		need_mob_update += affected_mob.adjustOxyLoss(-5 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
		if(need_mob_update)
			. = UPDATE_MOB_HEALTH
	var/obj/item/organ/lungs/affected_lungs = affected_mob.get_organ_slot(ORGAN_SLOT_LUNGS)
	var/our_respiration_type = affected_lungs ? affected_lungs.respiration_type : affected_mob.mob_respiration_type
	if(our_respiration_type & affected_respiration_type)
		affected_mob.losebreath = 0
	if(SPT_PROB(10, seconds_per_tick))
		affected_mob.set_dizzy_if_lower(10 SECONDS)
		affected_mob.set_jitter_if_lower(10 SECONDS)

/datum/reagent/medicine/atropine/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.adjustToxLoss(0.5 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
		. = UPDATE_MOB_HEALTH
	affected_mob.set_dizzy_if_lower(2 SECONDS * REM * seconds_per_tick)
	affected_mob.set_jitter_if_lower(2 SECONDS * REM * seconds_per_tick)

/datum/reagent/medicine/epinephrine
	name = "Epinephrine"
	description = "Очень незначительное повышение сопротивления оглушению. Медленно лечит урон, если пациент находится в критическом состоянии, а также регулирует потерю кислорода. Передозировка вызывает слабость и урон токсинами."
	color = "#D2FFFA"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30
	ph = 10.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	metabolized_traits = list(TRAIT_NOCRITDAMAGE)

/datum/reagent/medicine/epinephrine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(holder.has_reagent(/datum/reagent/toxin/lexorin))
		if(SPT_PROB(10, seconds_per_tick))
			holder.add_reagent(/datum/reagent/toxin/histamine, 4)
		return

	var/need_mob_update
	if(affected_mob.health <= affected_mob.crit_threshold)
		need_mob_update = affected_mob.adjustToxLoss(-0.5 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)
		need_mob_update += affected_mob.adjustBruteLoss(-0.5 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
		need_mob_update += affected_mob.adjustFireLoss(-0.5 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
		need_mob_update += affected_mob.adjustOxyLoss(-0.5 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
	if(affected_mob.losebreath >= 4)
		var/obj/item/organ/lungs/affected_lungs = affected_mob.get_organ_slot(ORGAN_SLOT_LUNGS)
		var/our_respiration_type = affected_lungs ? affected_lungs.respiration_type : affected_mob.mob_respiration_type
		if(our_respiration_type & affected_respiration_type)
			affected_mob.losebreath -= 2 * REM * seconds_per_tick
			need_mob_update = TRUE
	if(affected_mob.losebreath < 0)
		affected_mob.losebreath = 0
		need_mob_update = TRUE
	need_mob_update += affected_mob.adjustStaminaLoss(-2 * REM * seconds_per_tick, updating_stamina = FALSE)
	if(SPT_PROB(10, seconds_per_tick))
		affected_mob.AdjustAllImmobility(-20)
		need_mob_update = TRUE
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/epinephrine/metabolize_reagent(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	if(holder.has_reagent(/datum/reagent/toxin/lexorin))
		holder.remove_reagent(/datum/reagent/toxin/lexorin, 2 * REM * seconds_per_tick)
		holder.remove_reagent(/datum/reagent/medicine/epinephrine, 1 * REM * seconds_per_tick)
	return ..()

/datum/reagent/medicine/epinephrine/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(18, REM * seconds_per_tick))
		var/need_mob_update
		need_mob_update = affected_mob.adjustStaminaLoss(2.5 * REM * seconds_per_tick, updating_stamina = FALSE)
		need_mob_update += affected_mob.adjustToxLoss(1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)
		var/obj/item/organ/lungs/affected_lungs = affected_mob.get_organ_slot(ORGAN_SLOT_LUNGS)
		var/our_respiration_type = affected_lungs ? affected_lungs.respiration_type : affected_mob.mob_respiration_type
		if(our_respiration_type & affected_respiration_type)
			affected_mob.losebreath++
			need_mob_update = TRUE
		if(need_mob_update)
			return UPDATE_MOB_HEALTH

/datum/reagent/medicine/strange_reagent
	name = "Strange Reagent"
	description = "Чудо-препарат, способный воскрешать мёртвых. Действует наружно, если анатомически не сложно, в противном случае действует перорально. Не может воскресить цели с здоровьем ниже -%MAXHEALTHRATIO%."
	color = "#A0E85E"
	metabolization_rate = 1.25 * REAGENTS_METABOLISM
	taste_description = "магниты"
	ph = 0.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	/// The amount of damage a single unit of this will heal
	var/healing_per_reagent_unit = 5
	/// The ratio of the excess reagent used to contribute to excess healing
	var/excess_healing_ratio = 0.8
	/// Do we instantly revive
	var/instant = FALSE
	/// The maximum amount of damage we can revive from, as a ratio of max health
	var/max_revive_damage_ratio = 2

// To override for subtypes.
/datum/reagent/medicine/strange_reagent/proc/pre_rez_check(atom/thing_to_rez)
	return TRUE

/datum/reagent/medicine/strange_reagent/instant
	name = "Stranger Reagent"
	instant = TRUE
	chemical_flags = NONE

/datum/reagent/medicine/strange_reagent/New()
	. = ..()
	description = replacetext(description, "%MAXHEALTHRATIO%", "[max_revive_damage_ratio * 100]%")
	if(instant)
		description += " Кажется, он пульсирует тёплым розовым светом."

// FEED ME SEYMOUR
/datum/reagent/medicine/strange_reagent/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.spawnplant()

/// Calculates the amount of reagent to at a bare minimum make the target not dead
/datum/reagent/medicine/strange_reagent/proc/calculate_amount_needed_to_revive(mob/living/benefactor)
	var/their_health = benefactor.getMaxHealth() - (benefactor.getBruteLoss() + benefactor.getFireLoss())
	if(their_health > 0)
		return 1

	return round(-their_health / healing_per_reagent_unit, DAMAGE_PRECISION)

/// Calculates the amount of reagent that will be needed to both revive and full heal the target. Looks at healing_per_reagent_unit and excess_healing_ratio
/datum/reagent/medicine/strange_reagent/proc/calculate_amount_needed_to_full_heal(mob/living/benefactor)
	var/their_health = benefactor.getBruteLoss() + benefactor.getFireLoss()
	var/max_health = benefactor.getMaxHealth()
	if(their_health >= max_health)
		return 1

	var/amount_needed_to_revive = calculate_amount_needed_to_revive(benefactor)
	var/expected_amount_to_full_heal = round(max_health / healing_per_reagent_unit, DAMAGE_PRECISION) / excess_healing_ratio
	return amount_needed_to_revive + expected_amount_to_full_heal

/datum/reagent/medicine/strange_reagent/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	if(exposed_mob.stat != DEAD || !(exposed_mob.mob_biotypes & MOB_ORGANIC))
		return ..()

	if(HAS_TRAIT(exposed_mob, TRAIT_SUICIDED)) //они никогда не вернутся
		exposed_mob.visible_message(span_warning("Тело [exposed_mob] не реагирует..."))
		return

	if(iscarbon(exposed_mob) && !(methods & (INGEST|INHALE))) //простые мобы всё ещё могут быть облиты
		return ..()

	if(HAS_TRAIT(exposed_mob, TRAIT_HUSK))
		exposed_mob.visible_message(span_warning("Тело [exposed_mob] испускает клуб дыма..."))
		return

	if((exposed_mob.getBruteLoss() + exposed_mob.getFireLoss()) > (exposed_mob.getMaxHealth() * max_revive_damage_ratio))
		exposed_mob.visible_message(span_warning("Тело [exposed_mob] яростно бьётся в конвульсиях, прежде чем замирает..."))
		return

	var/needed_to_revive = calculate_amount_needed_to_revive(exposed_mob)
	if(reac_volume < needed_to_revive)
		exposed_mob.visible_message(span_warning("Тело [exposed_mob] немного дёргается, а затем снова замирает."))
		exposed_mob.do_jitter_animation(10)
		return

	if(!pre_rez_check(exposed_mob))
		exposed_mob.visible_message(span_warning("Тело [exposed_mob] слегка подёргивается."))
		exposed_mob.do_jitter_animation(1)
		return

	exposed_mob.visible_message(span_warning("Тело [exposed_mob] начинает биться в конвульсиях!"))
	exposed_mob.notify_revival("Ваше тело воскрешают с помощью Странного Реагента!")
	exposed_mob.do_jitter_animation(10)

	// we factor in healing needed when determing if we do anything
	var/healing = needed_to_revive * healing_per_reagent_unit
	// but excessive healing is penalized, to reward doctors who use the perfect amount
	reac_volume -= needed_to_revive
	healing += (reac_volume * healing_per_reagent_unit) * excess_healing_ratio

	// during unit tests, we want it to happen immediately
	if(instant)
		exposed_mob.do_strange_reagent_revival(healing)
	else
		// jitter immediately, after four seconds, and after eight seconds
		addtimer(CALLBACK(exposed_mob, TYPE_PROC_REF(/mob/living, do_jitter_animation), 1 SECONDS), 4 SECONDS)
		addtimer(CALLBACK(exposed_mob, TYPE_PROC_REF(/mob/living, do_strange_reagent_revival), healing), 7 SECONDS)
		addtimer(CALLBACK(exposed_mob, TYPE_PROC_REF(/mob/living, do_jitter_animation), 1 SECONDS), 8 SECONDS)

	return ..()

/datum/reagent/medicine/strange_reagent/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/damage_at_random = rand(0, 250)/100 //0 to 2.5
	var/need_mob_update
	need_mob_update = affected_mob.adjustBruteLoss(damage_at_random * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += affected_mob.adjustFireLoss(damage_at_random * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/strange_reagent/fishy_reagent
	name = "Fishy Reagent"
	description = "Этот реагент имеет химический состав, очень похожий на Странный Реагент, однако, похоже, он работает исключительно и только на... рыб. Или, по крайней мере, на водных существ."
	color = "#5ee8b3"
	metabolization_rate = 1.25 * REAGENTS_METABOLISM
	taste_description = "магнитная чешуя"
	ph = 0.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

// only revives fish.
/datum/reagent/medicine/strange_reagent/fishy_reagent/pre_rez_check(atom/thing_to_rez)
	if(ismob(thing_to_rez))
		var/mob/living/mob_to_rez = thing_to_rez
		if(mob_to_rez.mob_biotypes & MOB_AQUATIC)
			return TRUE
		return FALSE
	if(isfish(thing_to_rez))
		return TRUE
	return FALSE

/datum/reagent/medicine/mannitol
	name = "Mannitol"
	description = "Эффективно восстанавливает повреждения мозга."
	taste_description = "приятная сладость"
	color = "#A0A0A0" //mannitol is light grey, neurine is lighter grey
	ph = 10.4
	overdose_threshold = 15
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	purity = REAGENT_STANDARD_PURITY
	inverse_chem = /datum/reagent/inverse
	inverse_chem_val = 0.45
	metabolized_traits = list(TRAIT_TUMOR_SUPPRESSED) //Having mannitol in you will pause the brain damage from brain tumor (so it heals an even 2 brain damage instead of 1.8)

/datum/reagent/medicine/mannitol/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, -2 * REM * seconds_per_tick * normalise_creation_purity(), required_organ_flag = affected_organ_flags))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/mannitol/overdose_start(mob/living/affected_mob)
	. = ..()
	to_chat(affected_mob, span_notice("Вы внезапно чувствуете <span class='purple'>П Р О С В Е Т Л Е Н И Е!</span>"))

/datum/reagent/medicine/mannitol/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(65, seconds_per_tick))
		return
	var/list/tips
	if(SPT_PROB(50, seconds_per_tick))
		tips = world.file2list("strings/tips.txt")
	if(SPT_PROB(50, seconds_per_tick))
		tips = world.file2list("strings/sillytips.txt")
	else
		tips = world.file2list("strings/chemistrytips.txt")
	var/message = pick(tips)
	send_tip_of_the_round(affected_mob, message, source = "Химически-индуцированная мудрость")

/datum/reagent/medicine/neurine
	name = "Neurine"
	description = "Реагирует с нервной тканью, помогая восстанавливать повреждённые связи. Может излечивать небольшие травмы."
	color = COLOR_SILVER //ditto
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED | REAGENT_DEAD_PROCESS
	purity = REAGENT_STANDARD_PURITY
	inverse_chem_val = 0.5
	inverse_chem = /datum/reagent/inverse/neurine
	added_traits = list(TRAIT_ANTICONVULSANT)
	///brain damage level when we first started taking the chem
	var/initial_bdamage = 200

/datum/reagent/medicine/neurine/on_mob_add(mob/living/affected_mob, amount)
	. = ..()
	if(!iscarbon(affected_mob))
		return
	var/mob/living/carbon/affected_carbon = affected_mob
	if(creation_purity >= 1)
		initial_bdamage = affected_carbon.get_organ_loss(ORGAN_SLOT_BRAIN)

/datum/reagent/medicine/neurine/on_mob_delete(mob/living/affected_mob)
	. = ..()
	if(!iscarbon(affected_mob))
		return
	var/mob/living/carbon/affected_carbon = affected_mob
	if(initial_bdamage < affected_carbon.get_organ_loss(ORGAN_SLOT_BRAIN))
		affected_carbon.setOrganLoss(ORGAN_SLOT_BRAIN, initial_bdamage)

/datum/reagent/medicine/neurine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(holder.has_reagent(/datum/reagent/consumable/ethanol/neurotoxin))
		holder.remove_reagent(/datum/reagent/consumable/ethanol/neurotoxin, 5 * REM * seconds_per_tick * normalise_creation_purity())
	if(SPT_PROB(8 * normalise_creation_purity(), seconds_per_tick))
		affected_mob.cure_trauma_type(resilience = TRAUMA_RESILIENCE_BASIC)

/datum/reagent/medicine/neurine/on_mob_dead(mob/living/carbon/affected_mob, seconds_per_tick)
	. = ..()
	if(affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, -1 * REM * seconds_per_tick * normalise_creation_purity(), required_organ_flag = affected_organ_flags))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/mutadone
	name = "Mutadone"
	description = "Устраняет дрожь и восстанавливает генетические дефекты."
	color = "#5096C8"
	taste_description = "кислота"
	ph = 2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/mutadone/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	if (!ishuman(affected_mob))
		return
	var/mob/living/carbon/human/human_mob = affected_mob
	if (ismonkey(human_mob))
		if (!HAS_TRAIT(human_mob, TRAIT_BORN_MONKEY))
			//This is the only time mutadone should remove monkeyism
			human_mob.dna.remove_mutation(/datum/mutation/race, list(MUTATION_SOURCE_ACTIVATED, MUTATION_SOURCE_MUTATOR))
	else if (HAS_TRAIT(human_mob, TRAIT_BORN_MONKEY))
		human_mob.monkeyize()


/datum/reagent/medicine/mutadone/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.remove_status_effect(/datum/status_effect/jitter)
	if(affected_mob.has_dna())
		affected_mob.dna.remove_mutation_group(affected_mob.dna.mutations - affected_mob.dna.get_mutation(/datum/mutation/race), GLOB.standard_mutation_sources)
		affected_mob.dna.scrambled = FALSE

/datum/reagent/medicine/antihol
	name = "Antihol"
	description = "Очищает организм пациента от алкогольных веществ и устраняет их побочные эффекты."
	color = "#00B4C8"
	taste_description = "сырое яйцо"
	ph = 4
	purity = REAGENT_STANDARD_PURITY
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	inverse_chem_val = 0.35
	inverse_chem = /datum/reagent/inverse/antihol
	/// All status effects we remove on metabolize.
	/// Does not include drunk (despite what you may thing) as that's decresed gradually
	var/static/list/status_effects_to_clear = list(
		/datum/status_effect/confusion,
		/datum/status_effect/dizziness,
		/datum/status_effect/drowsiness,
		/datum/status_effect/speech/slurring/drunk,
	)

/datum/reagent/medicine/antihol/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	for(var/effect in status_effects_to_clear)
		affected_mob.remove_status_effect(effect)
	affected_mob.reagents.remove_reagent(/datum/reagent/consumable/ethanol, 8 * REM * seconds_per_tick * normalise_creation_purity(), include_subtypes = TRUE)
	if(affected_mob.adjustToxLoss(-0.2 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
		. = UPDATE_MOB_HEALTH
	affected_mob.adjust_drunk_effect(-10 * REM * seconds_per_tick * normalise_creation_purity())

/datum/reagent/medicine/antihol/expose_mob(mob/living/carbon/exposed_carbon, methods=TOUCH, reac_volume)
	. = ..()
	if(!(methods & (TOUCH|VAPOR|PATCH)))
		return

	for(var/datum/surgery/surgery as anything in exposed_carbon.surgeries)
		surgery.speed_modifier = min(surgery.speed_modifier  +  0.1, 1.1)

/datum/reagent/medicine/stimulants
	name = "Stimulants"
	description = "Повышает сопротивление дубинкам и скорость движения, а также восстанавливает небольшой урон и слабость. Передозировка вызывает слабость и урон токсинами."
	color = "#78008C"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 60
	ph = 8.7
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE
	addiction_types = list(/datum/addiction/stimulants = 4) //0.8 per 2 seconds
	metabolized_traits = list(TRAIT_BATON_RESISTANCE, TRAIT_ANALGESIA, TRAIT_STIMULATED)

/datum/reagent/medicine/stimulants/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/stimulants)

/datum/reagent/medicine/stimulants/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/stimulants)

/datum/reagent/medicine/stimulants/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.health < 50 && affected_mob.health > 0)
		var/need_mob_update
		need_mob_update += affected_mob.adjustOxyLoss(-1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
		need_mob_update += affected_mob.adjustToxLoss(-1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)
		need_mob_update += affected_mob.adjustBruteLoss(-1 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
		need_mob_update += affected_mob.adjustFireLoss(-1 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
		if(need_mob_update)
			. = UPDATE_MOB_HEALTH
	affected_mob.AdjustAllImmobility(-60  * REM * seconds_per_tick)
	affected_mob.adjustStaminaLoss(-12 * REM * seconds_per_tick, updating_stamina = FALSE, required_biotype = affected_biotype)

/datum/reagent/medicine/stimulants/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(18, seconds_per_tick))
		affected_mob.adjustStaminaLoss(2.5, updating_stamina = FALSE, required_biotype = affected_biotype)
		affected_mob.adjustToxLoss(1, updating_health = FALSE, required_biotype = affected_biotype)
		affected_mob.losebreath++
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/insulin
	name = "Insulin"
	description = "Увеличивает скорость расхода сахара."
	color = "#FFFFF0"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	ph = 6.7
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/insulin/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.AdjustSleeping(-2 SECONDS * REM * seconds_per_tick)
	holder.remove_reagent(/datum/reagent/consumable/sugar, 3 * REM * seconds_per_tick)

//Trek Chems, used primarily by medibots. Only heals a specific damage type, but is very efficient.

/datum/reagent/medicine/inaprovaline //is this used anywhere?
	name = "Inaprovaline"
	description = "Стабилизирует дыхание пациентов. Хорош для тех, кто находится в критическом состоянии."
	color = "#A4D8D8"
	ph = 8.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/medicine/inaprovaline/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.losebreath >= 5)
		affected_mob.losebreath -= 5 * REM * seconds_per_tick
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/regen_jelly
	name = "Regenerative Jelly"
	description = "Постепенно регенерирует все виды урона, не вредя анатомии слаймов."
	color = "#CC23FF"
	taste_description = "желе"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	affected_biotype = MOB_ORGANIC | MOB_MINERAL | MOB_PLANT // no healing ghosts
	affected_respiration_type = ALL

/datum/reagent/medicine/regen_jelly/expose_mob(mob/living/exposed_mob, reac_volume)
	. = ..()
	if(!ishuman(exposed_mob) || (reac_volume < 0.5))
		return

	var/mob/living/carbon/human/exposed_human = exposed_mob
	exposed_human.set_facial_haircolor(color, update = FALSE)
	exposed_human.set_haircolor(color, update = TRUE)

/datum/reagent/medicine/regen_jelly/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustBruteLoss(-1.5 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += affected_mob.adjustFireLoss(-1.5 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += affected_mob.adjustOxyLoss(-1.5 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
	need_mob_update += affected_mob.adjustToxLoss(-1.5 * REM * seconds_per_tick, updating_health = FALSE, forced = TRUE, required_biotype = affected_biotype) //heals TOXINLOVERs
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/syndicate_nanites //Used exclusively by Syndicate medical cyborgs
	name = "Restorative Nanites"
	description = "Крошечные медицинские роботы, которые быстро восстанавливают телесные повреждения."
	color = "#555555"
	overdose_threshold = 30
	ph = 11
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/medicine/syndicate_nanites/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustBruteLoss(-5 * REM * seconds_per_tick, updating_health = FALSE) //A ton of healing - this is a 50 telecrystal investment.
	need_mob_update += affected_mob.adjustFireLoss(-5 * REM * seconds_per_tick, updating_health = FALSE)
	need_mob_update += affected_mob.adjustOxyLoss(-15 * REM * seconds_per_tick, updating_health = FALSE)
	need_mob_update += affected_mob.adjustToxLoss(-5 * REM * seconds_per_tick, updating_health = FALSE, forced = TRUE, required_biotype = affected_biotype)
	need_mob_update += affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, -15 * REM * seconds_per_tick)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/syndicate_nanites/overdose_process(mob/living/carbon/affected_mob, seconds_per_tick, times_fired) //wtb flavortext messages that hint that you're vomitting up robots
	. = ..()
	if(SPT_PROB(13, seconds_per_tick))
		affected_mob.reagents.remove_reagent(type, metabolization_rate * 15) // ~5 units at a rate of 0.4 but i wanted a nice number in code
		affected_mob.vomit(vomit_flags = VOMIT_CATEGORY_DEFAULT, vomit_type = /obj/effect/decal/cleanable/vomit/nanites, lost_nutrition = 20) // nanite safety protocols make your body expel them to prevent harmies

/datum/reagent/medicine/earthsblood //Created by ambrosia gaia plants
	name = "Earthsblood"
	description = "Ихор из невероятно мощного растения. Отлично подходит для восстановления ран, но немного тяжеловат для мозга. По какой-то странной причине также вызывает временный пацифизм у тех, кто его употребляет, и полупостоянный пацифизм у тех, кто передозирует им."
	color = "#FFAF00"
	metabolization_rate = REAGENTS_METABOLISM //Math is based on specific metab rate so we want this to be static AKA if define or medicine metab rate changes, we want this to stay until we can rework calculations.
	overdose_threshold = 25
	ph = 11
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/hallucinogens = 14)
	metabolized_traits = list(TRAIT_PACIFISM)

/datum/reagent/medicine/earthsblood/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	if(current_cycle < 25) //10u has to be processed before u get into THE FUN ZONE
		need_mob_update = affected_mob.adjustBruteLoss(-1 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
		need_mob_update += affected_mob.adjustFireLoss(-1 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
		need_mob_update += affected_mob.adjustOxyLoss(-0.5 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
		need_mob_update += affected_mob.adjustToxLoss(-0.5 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)
		need_mob_update += affected_mob.adjustStaminaLoss(-2 * REM * seconds_per_tick, updating_stamina = FALSE, required_biotype = affected_biotype)
		need_mob_update += affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1 * REM * seconds_per_tick, 150, affected_organ_flags) //This does, after all, come from ambrosia, and the most powerful ambrosia in existence, at that!
	else
		need_mob_update = affected_mob.adjustBruteLoss(-5 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype) //slow to start, but very quick healing once it gets going
		need_mob_update += affected_mob.adjustFireLoss(-5 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
		need_mob_update += affected_mob.adjustOxyLoss(-3 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
		need_mob_update += affected_mob.adjustToxLoss(-3 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)
		need_mob_update += affected_mob.adjustStaminaLoss(-8 * REM * seconds_per_tick, updating_stamina = FALSE, required_biotype = affected_biotype)
		need_mob_update += affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2 * REM * seconds_per_tick, 150, affected_organ_flags)
		affected_mob.adjust_jitter_up_to(6 SECONDS * REM * seconds_per_tick, 1 MINUTES)
		if(SPT_PROB(5, seconds_per_tick))
			affected_mob.say(return_hippie_line(), forced = /datum/reagent/medicine/earthsblood)
	affected_mob.adjust_drugginess_up_to(20 SECONDS * REM * seconds_per_tick, 30 SECONDS * REM * seconds_per_tick)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/earthsblood/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_hallucinations_up_to(10 SECONDS * REM * seconds_per_tick, 120 SECONDS)
	var/need_mob_update
	if(current_cycle > 26)
		need_mob_update = affected_mob.adjustToxLoss(4 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)
		if(current_cycle > 101) //podpeople get out reeeeeeeeeeeeeeeeeeeee
			need_mob_update += affected_mob.adjustToxLoss(6 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)
	if(iscarbon(affected_mob))
		var/mob/living/carbon/hippie = affected_mob
		hippie.gain_trauma(/datum/brain_trauma/severe/pacifism)

	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/// Returns a hippie-esque string for the person affected by the reagent to say.
/datum/reagent/medicine/earthsblood/proc/return_hippie_line()
	var/static/list/earthsblood_lines = list(
		"Я рад, что он заморожен там, а мы здесь, и что он шериф, а мы заморожены здесь, и что мы там, и я только что вспомнил, мы здесь. Что я хочу знать: Где пещерный человек?",
		"Верите ли вы в магию в сердце юной девушки?",
		"Это не я, это не я...",
		"Занимайтесь любовью, а не войной!",
		"Стой, эй, что это за звук? Все смотрят, что происходит...",
		"Ну, знаешь, это просто, типа, твоё мнение, чувак.",
	)

	return pick(earthsblood_lines)

/datum/reagent/medicine/haloperidol
	name = "Haloperidol"
	description = "Увеличивает скорость выведения большинства стимулирующих/галлюциногенных наркотиков. Уменьшает наркотические эффект и дрожь. Серьёзно снижает к регенерации выносливости, вызывает сонливость. Небольшой шанс повреждения мозга."
	color = "#27870a"
	metabolization_rate = 0.4 * REAGENTS_METABOLISM
	ph = 4.3
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/haloperidol/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	for(var/datum/reagent/drug/reagent in affected_mob.reagents.reagent_list)
		affected_mob.reagents.remove_reagent(reagent.type, 5 * reagent.purge_multiplier * REM * seconds_per_tick)
	affected_mob.adjust_drowsiness(4 SECONDS * REM * seconds_per_tick)

	if(affected_mob.get_timed_status_effect_duration(/datum/status_effect/jitter) >= 6 SECONDS)
		affected_mob.adjust_jitter(-6 SECONDS * REM * seconds_per_tick)

	if (affected_mob.get_timed_status_effect_duration(/datum/status_effect/hallucination) >= 10 SECONDS)
		affected_mob.adjust_hallucinations(-10 SECONDS * REM * seconds_per_tick)

	if(affected_mob.getStaminaLoss() >= 100)
		affected_mob.reagents.remove_reagent(type, metabolization_rate * REM * seconds_per_tick)

	var/need_mob_update = FALSE
	if(SPT_PROB(10, seconds_per_tick))
		need_mob_update += affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1, 50, affected_organ_flags)
	need_mob_update += affected_mob.adjustStaminaLoss(2.5 * REM * seconds_per_tick, updating_stamina = FALSE, required_biotype = affected_biotype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

//used for changeling's adrenaline power
/datum/reagent/medicine/changelingadrenaline
	name = "Changeling Adrenaline"
	description = "Уменьшает продолжительность бессознательного состояния, нокдауна и оглушений. Восстанавливает выносливость, но наносит урон токсинами при передозировке."
	color = "#C1151D"
	overdose_threshold = 30
	chemical_flags = REAGENT_NO_RANDOM_RECIPE

/datum/reagent/medicine/changelingadrenaline/on_mob_life(mob/living/carbon/metabolizer, seconds_per_tick, times_fired)
	. = ..()
	metabolizer.AdjustAllImmobility(-20 * REM * seconds_per_tick)
	if(metabolizer.adjustStaminaLoss(-30 * REM * seconds_per_tick, updating_stamina = FALSE))
		. = UPDATE_MOB_HEALTH
	metabolizer.set_jitter_if_lower(20 SECONDS * REM * seconds_per_tick)
	metabolizer.set_dizzy_if_lower(20 SECONDS * REM * seconds_per_tick)

/datum/reagent/medicine/changelingadrenaline/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.add_traits(list(TRAIT_SLEEPIMMUNE, TRAIT_BATON_RESISTANCE), type)
	affected_mob.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)
	RegisterSignal(affected_mob, COMSIG_LIVING_ENTER_STAMCRIT, PROC_REF(on_stamcrit))

/datum/reagent/medicine/changelingadrenaline/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.remove_traits(list(TRAIT_SLEEPIMMUNE, TRAIT_BATON_RESISTANCE), type)
	affected_mob.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)
	affected_mob.remove_status_effect(/datum/status_effect/dizziness)
	affected_mob.remove_status_effect(/datum/status_effect/jitter)
	UnregisterSignal(affected_mob, COMSIG_LIVING_ENTER_STAMCRIT)

/datum/reagent/medicine/changelingadrenaline/proc/on_stamcrit(mob/living/affected_mob)
	SIGNAL_HANDLER
	affected_mob?.setStaminaLoss(90, updating_stamina = TRUE)
	to_chat(affected_mob, span_changeling("Наш ген-стим вспыхивает! Мы полны сил, но его сила ослабевает."))
	volume -= (min(volume, 1))
	return STAMCRIT_CANCELLED

/datum/reagent/medicine/changelingadrenaline/overdose_process(mob/living/metabolizer, seconds_per_tick, times_fired)
	. = ..()
	if(metabolizer.adjustToxLoss(1 * REM * seconds_per_tick, updating_health = FALSE))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/changelinghaste
	name = "Changeling Haste"
	description = "Резко увеличивает скорость движения, но наносит урон токсинами."
	color = "#AE151D"
	metabolization_rate = 2.5 * REAGENTS_METABOLISM
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/medicine/changelinghaste/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/changelinghaste)

/datum/reagent/medicine/changelinghaste/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/changelinghaste)

/datum/reagent/medicine/changelinghaste/on_mob_life(mob/living/carbon/metabolizer, seconds_per_tick, times_fired)
	. = ..()
	if(metabolizer.adjustToxLoss(2 * REM * seconds_per_tick, updating_health = FALSE))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/higadrite
	name = "Higadrite"
	description = "Лекарство, используемое для лечения больной печени."
	color = "#FF3542"
	self_consuming = TRUE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	metabolized_traits = list(TRAIT_STABLELIVER)

/datum/reagent/medicine/cordiolis_hepatico
	name = "Cordiolis Hepatico"
	description = "Странный, смоляно-чёрный реагент, который, кажется, поглощает весь свет. Эффекты неизвестны."
	color = COLOR_BLACK
	self_consuming = TRUE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/medicine/cordiolis_hepatico/on_mob_add(mob/living/affected_mob)
	. = ..()
	affected_mob.add_traits(list(TRAIT_STABLELIVER, TRAIT_STABLEHEART), type)

/datum/reagent/medicine/cordiolis_hepatico/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.remove_traits(list(TRAIT_STABLELIVER, TRAIT_STABLEHEART), type)

/datum/reagent/medicine/muscle_stimulant
	name = "Muscle Stimulant"
	description = "Мощное химическое вещество, которое позволяет находящемуся под его влиянием человеку быть в полной физической форме, даже испытывая огромную боль."
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE
	metabolized_traits = list(TRAIT_ANALGESIA)

/datum/reagent/medicine/muscle_stimulant/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)

/datum/reagent/medicine/muscle_stimulant/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)

/datum/reagent/medicine/modafinil
	name = "Modafinil"
	description = "Долгодействующий подавляющий сон, который очень незначительно сокращает время оглушения и нокдауна. Передозировка имеет ужасные побочные эффекты и наносит смертельный урон кислородным голоданием, вырубит вас, если не принять меры."
	color = "#BEF7D8" // palish blue white
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	overdose_threshold = 20 // with the random effects this might be awesome or might kill you at less than 10u (extensively tested)
	taste_description = "соль" // it actually does taste salty
	var/overdose_progress = 0 // to track overdose progress
	ph = 7.89
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	metabolized_traits = list(TRAIT_SLEEPIMMUNE)

/datum/reagent/medicine/modafinil/on_mob_life(mob/living/carbon/metabolizer, seconds_per_tick, times_fired)
	. = ..()
	if(overdosed) // We do not want any effects on OD
		return
	overdose_threshold = overdose_threshold + ((rand(-10, 10) / 10) * REM * seconds_per_tick) // for extra fun
	metabolizer.AdjustAllImmobility(-5 * REM * seconds_per_tick)
	metabolizer.adjustStaminaLoss(-3 * REM * seconds_per_tick, updating_stamina = FALSE, required_biotype = affected_biotype)
	metabolizer.set_jitter_if_lower(1 SECONDS * REM * seconds_per_tick)
	metabolization_rate = 0.005 * REAGENTS_METABOLISM * rand(5, 20) // randomizes metabolism between 0.02 and 0.08 per second
	return UPDATE_MOB_HEALTH

/datum/reagent/medicine/modafinil/overdose_start(mob/living/affected_mob)
	. = ..()
	to_chat(affected_mob, span_userdanger("Вы чувствуете себя ужасно запыхавшимся и дёрганым!"))
	metabolization_rate = 0.025 * REAGENTS_METABOLISM // sets metabolism to 0.005 per second on overdose

/datum/reagent/medicine/modafinil/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	overdose_progress++
	var/need_mob_update
	switch(overdose_progress)
		if(1 to 40)
			affected_mob.adjust_jitter_up_to(2 SECONDS * REM * seconds_per_tick, 20 SECONDS)
			affected_mob.adjust_stutter_up_to(2 SECONDS * REM * seconds_per_tick, 20 SECONDS)
			affected_mob.set_dizzy_if_lower(10 SECONDS * REM * seconds_per_tick)
			if(SPT_PROB(30, seconds_per_tick))
				affected_mob.losebreath++
				need_mob_update = TRUE
		if(41 to 80)
			need_mob_update = affected_mob.adjustOxyLoss(0.1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
			need_mob_update += affected_mob.adjustStaminaLoss(0.1 * REM * seconds_per_tick, updating_stamina = FALSE, required_biotype = affected_biotype)
			affected_mob.adjust_jitter_up_to(2 SECONDS * REM * seconds_per_tick, 40 SECONDS)
			affected_mob.adjust_stutter_up_to(2 SECONDS * REM * seconds_per_tick, 40 SECONDS)
			affected_mob.set_dizzy_if_lower(20 SECONDS * REM * seconds_per_tick)
			if(SPT_PROB(30, seconds_per_tick))
				affected_mob.losebreath++
				need_mob_update = TRUE
			if(SPT_PROB(10, seconds_per_tick))
				to_chat(affected_mob, span_userdanger("У вас внезапный припадок!"))
				affected_mob.emote("moan")
				affected_mob.Paralyze(20) // you should be in a bad spot at this point unless epipen has been used
		if(81)
			to_chat(affected_mob, span_userdanger("Вы чувствуете себя слишком истощённым, чтобы продолжать!")) // at this point you will eventually die unless you get charcoal
			need_mob_update = affected_mob.adjustOxyLoss(0.1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
			need_mob_update += affected_mob.adjustStaminaLoss(0.1 * REM * seconds_per_tick, updating_stamina = FALSE, required_biotype = affected_biotype)
		if(82 to INFINITY)
			REMOVE_TRAIT(affected_mob, TRAIT_SLEEPIMMUNE, type)
			affected_mob.Sleeping(100 * REM * seconds_per_tick)
			need_mob_update += affected_mob.adjustOxyLoss(1.5 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
			need_mob_update += affected_mob.adjustStaminaLoss(1.5 * REM * seconds_per_tick, updating_stamina = FALSE, required_biotype = affected_biotype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/psicodine
	name = "Psicodine"
	description = "Подавляет тревогу и другие различные формы психического расстройства. Передозировка вызывает галлюцинации и незначительные урон токсинами."
	color = "#07E79E"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30
	ph = 9.12
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	metabolized_traits = list(TRAIT_FEARLESS)

/datum/reagent/medicine/psicodine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_jitter(-12 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_dizzy(-12 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_confusion(-6 SECONDS * REM * seconds_per_tick)
	affected_mob.disgust = max(affected_mob.disgust - (6 * REM * seconds_per_tick), 0)
	if(affected_mob.mob_mood != null && affected_mob.mob_mood.sanity <= SANITY_NEUTRAL) // only take effect if in negative sanity and then...
		affected_mob.mob_mood.adjust_sanity(5 * REM * seconds_per_tick, maximum = SANITY_NEUTRAL) // set minimum to prevent unwanted spiking over neutral

/datum/reagent/medicine/psicodine/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_hallucinations_up_to(10 SECONDS * REM * seconds_per_tick, 120 SECONDS)
	if(affected_mob.adjustToxLoss(1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/metafactor
	name = "Mitogen Metabolism Factor"
	description = "Этот фермент катализирует преобразование питательной пищи в целебные пептиды."
	metabolization_rate = 0.0625  * REAGENTS_METABOLISM //slow metabolism rate so the patient can self heal with food even after the troph has metabolized away for amazing reagent efficency.
	color = "#FFBE00"
	overdose_threshold = 10
	inverse_chem_val = 0.1 //Shouldn't happen - but this is so looking up the chem will point to the failed type
	inverse_chem = /datum/reagent/impurity/probital_failed
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/metafactor/overdose_start(mob/living/carbon/affected_mob)
	. = ..()
	metabolization_rate = 2  * REAGENTS_METABOLISM

/datum/reagent/medicine/metafactor/overdose_process(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(13, seconds_per_tick))
		affected_mob.vomit(VOMIT_CATEGORY_KNOCKDOWN)

/datum/reagent/medicine/silibinin
	name = "Silibinin"
	description = "Гепатопротекторная смесь флаволигнанов, полученная из чертополоха, которая помогает обратить повреждения печени."
	color = "#FFFFD0"
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/silibinin/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.adjustOrganLoss(ORGAN_SLOT_LIVER, -2 * REM * seconds_per_tick, required_organ_flag = affected_organ_flags)) // Add a chance to cure liver trauma once implemented.
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/polypyr  //This is intended to be an ingredient in advanced chems.
	name = "Polypyrylium Oligomers"
	description = "Фиолетовая смесь коротких полиэлектролитные цепей, которые нелегко синтезировать в лаборатории. Ценится как промежуточное звено в синтезе передовых фармацевтических препаратов."
	color = "#9423FF"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 50
	taste_description = "онемевающая горечь"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/polypyr/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired) //I wanted a collection of small positive effects, this is as hard to obtain as coniine after all.
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustOrganLoss(ORGAN_SLOT_LUNGS, -0.25 * REM * seconds_per_tick, required_organ_flag = affected_organ_flags)
	need_mob_update += affected_mob.adjustBruteLoss(-0.35 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/polypyr/expose_mob(mob/living/carbon/human/exposed_human, methods=TOUCH, reac_volume)
	. = ..()
	if(!(methods & (TOUCH|VAPOR)) || !ishuman(exposed_human) || (reac_volume < 0.5))
		return
	exposed_human.set_facial_haircolor("#9922ff", update = FALSE)
	exposed_human.set_haircolor(color) //this will call update_body_parts()

/datum/reagent/medicine/polypyr/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.adjustOrganLoss(ORGAN_SLOT_LUNGS, 0.5 * REM * seconds_per_tick, required_organ_flag = affected_organ_flags))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/granibitaluri
	name = "Granibitaluri" //achieve "GRANular" amounts of C2
	description = "Лёгкое обезболивающее, полезное в качестве добавки вместе с более сильнодействующими лекарствами. Ускоряет заживление небольших ран и ожогов, но неэффективно при лечении тяжелых травм. Чрезвычайно большие дозы токсичны и могут со временем вызвать печёночную недостаточность."
	color = "#E0E0E0"
	overdose_threshold = 50
	metabolization_rate = 0.5 * REAGENTS_METABOLISM //same as C2s
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/granibitaluri/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/healamount = max(0.5 - round(0.01 * (affected_mob.getBruteLoss() + affected_mob.getFireLoss()), 0.1), 0) //base of 0.5 healing per cycle and loses 0.1 healing for every 10 combined brute/burn damage you have
	var/need_mob_update
	need_mob_update = affected_mob.adjustBruteLoss(-healamount * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += affected_mob.adjustFireLoss(-healamount * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/granibitaluri/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.2 * REM * seconds_per_tick, required_organ_flag = affected_organ_flags)
	need_mob_update += affected_mob.adjustToxLoss(0.2 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype) //Only really deadly if you eat over 100u
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

// helps bleeding wounds clot faster
/datum/reagent/medicine/coagulant
	name = "Sanguirite"
	description = "Патентованный коагулянт, используемый для ускорения свёртывания кровотечений ран. Выводится гепарином."
	color = "#bb2424"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 20
	/// The bloodiest wound that the patient has will have its blood_flow reduced by about half this much each second
	var/clot_rate = 0.3
	/// While this reagent is in our bloodstream, we reduce all bleeding by this factor
	var/passive_bleed_modifier = 0.7
	/// For tracking when we tell the person we're no longer bleeding
	var/was_working
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	metabolized_traits = list(TRAIT_COAGULATING)

/datum/reagent/medicine/coagulant/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	if(ishuman(affected_mob))
		var/mob/living/carbon/human/blood_boy = affected_mob
		blood_boy.physiology?.bleed_mod *= passive_bleed_modifier

/datum/reagent/medicine/coagulant/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	if(was_working)
		to_chat(affected_mob, span_warning("Лекарство, сгущающее вашу кровь, теряет свой эффект!"))
	if(ishuman(affected_mob))
		var/mob/living/carbon/human/blood_boy = affected_mob
		blood_boy.physiology?.bleed_mod /= passive_bleed_modifier

/datum/reagent/medicine/coagulant/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(!affected_mob.blood_volume || !affected_mob.all_wounds)
		return

	var/datum/wound/bloodiest_wound

	for(var/i in affected_mob.all_wounds)
		var/datum/wound/iter_wound = i
		if(iter_wound.blood_flow)
			if(iter_wound.blood_flow > bloodiest_wound?.blood_flow)
				bloodiest_wound = iter_wound

	if(bloodiest_wound)
		if(!was_working)
			to_chat(affected_mob, span_green("Вы чувствуете, как ваша текучая кровь начинает сгущаться!"))
			was_working = TRUE
		bloodiest_wound.adjust_blood_flow(-clot_rate * REM * seconds_per_tick)
	else if(was_working)
		was_working = FALSE

/datum/reagent/medicine/coagulant/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(!affected_mob.blood_volume)
		return

	if(SPT_PROB(7.5, seconds_per_tick))
		affected_mob.losebreath += rand(2, 4)
		affected_mob.adjustOxyLoss(rand(1, 3), updating_health = FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
		if(prob(30))
			to_chat(affected_mob, span_danger("Вы чувствуете, как ваша кровь свёртывается в венах!"))
		else if(prob(10))
			to_chat(affected_mob, span_userdanger("Вы чувствуете, будто ваша кровь перестала двигаться!"))
			affected_mob.adjustOxyLoss(rand(3, 4) * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)

		if(prob(50))
			var/obj/item/organ/lungs/our_lungs = affected_mob.get_organ_slot(ORGAN_SLOT_LUNGS)
			our_lungs.apply_organ_damage(1 * REM * seconds_per_tick)
		else
			var/obj/item/organ/heart/our_heart = affected_mob.get_organ_slot(ORGAN_SLOT_HEART)
			our_heart.apply_organ_damage(1 * REM * seconds_per_tick)

		return UPDATE_MOB_HEALTH

// i googled "natural coagulant" and a couple of results came up for banana peels, so after precisely 30 more seconds of research, i now dub grinding banana peels good for your blood
/datum/reagent/medicine/coagulant/banana_peel
	name = "Pulped Banana Peel"
	description = "Древний Клоунский Фольклор гласит, что мякоть банановой кожуры полезна для крови, но вы действительно собираетесь принимать медицинские советы от клоуна о бананах?"
	color = "#50531a" // rgb: 175, 175, 0
	taste_description = "ужасно волокнистая, горькая мякоть"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	clot_rate = 0.2
	passive_bleed_modifier = 0.8
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/banana_peel
	required_drink_type = /datum/reagent/medicine/coagulant/banana_peel
	name = "glass of banana peel pulp"
	desc = "Древний Клоунский Фольклор гласит, что мякоть банановой кожуры полезна для крови, \
		но вы действительно собираетесь принимать медицинские советы от клоуна о бананах?"

/datum/reagent/medicine/coagulant/seraka_extract
	name = "Seraka Extract"
	description = "Глубоко окрашенное масло, присутствующее в небольших количествах в грибах Серака. Действует как эффективное средство для свёртывания крови, но имеет низкий порог передозировки."
	color = "#00767C"
	taste_description = "насыщенная пикантная горечь"
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	clot_rate = 0.4 //slightly better than regular coagulant
	passive_bleed_modifier = 0.5
	overdose_threshold = 10 //but easier to overdose on

/datum/glass_style/drinking_glass/seraka_extract
	required_drink_type = /datum/reagent/medicine/coagulant/seraka_extract
	name = "glass of seraka extract"
	desc = "Глубоко пикантный, горький и заставляет вашу кровь свёртываться в венах. Отличный напиток, всё учитывается."

/datum/reagent/medicine/ondansetron
	name = "Ondansetron"
	description = "Предотвращает тошноту и рвоту. Может вызывать сонливость и усталость."
	color = "#74d3ff"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	ph = 10.6
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/ondansetron/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(8, seconds_per_tick))
		affected_mob.adjust_drowsiness(2 SECONDS * REM * seconds_per_tick)
	if(SPT_PROB(15, seconds_per_tick) && !affected_mob.getStaminaLoss())
		if(affected_mob.adjustStaminaLoss(10 * REM * seconds_per_tick, updating_stamina = FALSE))
			. = UPDATE_MOB_HEALTH
	affected_mob.adjust_disgust(-10 * REM * seconds_per_tick)

/datum/reagent/medicine/naloxone
	name = "Naloxone"
	description = "Опиоидный антагонист, который очищает организм пациента от сонливости и наркотиков, восстанавливает потерю дыхания и ускоряет восстановление от зависимости."
	color = "#f5f5dc"
	metabolization_rate = 0.2 * REM
	ph = 4
	penetrates_skin = TOUCH|VAPOR
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	metabolized_traits = list(TRAIT_ADDICTIONRESILIENT)
	var/static/list/opiates_to_clear = list(
		/datum/reagent/medicine/morphine,
		/datum/reagent/impedrezene,
		/datum/reagent/toxin/fentanyl,
		/datum/reagent/drug/krokodil,
		/datum/reagent/inverse/krokodil,
	)

/datum/reagent/medicine/naloxone/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	for(var/opiate in opiates_to_clear)
		holder.remove_reagent(opiate, 3 * REM * seconds_per_tick)

	if(affected_mob.mob_mood?.get_mood_event("numb"))
		affected_mob.clear_mood_event("numb")
		affected_mob.add_mood_event("not numb", /datum/mood_event/antinarcotic_medium)

	if(affected_mob.mob_mood?.get_mood_event("smacked out"))
		affected_mob.clear_mood_event("smacked out")
		affected_mob.add_mood_event("not smacked out", /datum/mood_event/antinarcotic_heavy)

	affected_mob.adjust_drowsiness(-5 SECONDS * REM * seconds_per_tick)
	if(affected_mob.losebreath >= 1)
		affected_mob.losebreath -= 1 * REM * seconds_per_tick
		return UPDATE_MOB_HEALTH
