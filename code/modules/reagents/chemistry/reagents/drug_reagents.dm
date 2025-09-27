/datum/reagent/drug
	name = "Drug"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "горечь"
	var/trippy = TRUE //Does this drug make you trip?

/datum/reagent/drug/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	if(trippy)
		affected_mob.clear_mood_event("[type]_high")

/datum/reagent/drug/space_drugs
	name = "Space Drugs"
	description = "Незаконное химическое соединение, используемое как наркотик."
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 30
	ph = 9
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/hallucinogens = 10) //4 per 2 seconds

/datum/reagent/drug/space_drugs/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.set_drugginess(30 SECONDS * REM * seconds_per_tick)
	if(isturf(affected_mob.loc) && !isspaceturf(affected_mob.loc) && !HAS_TRAIT(affected_mob, TRAIT_IMMOBILIZED) && SPT_PROB(5, seconds_per_tick))
		step(affected_mob, pick(GLOB.cardinals))
	if(SPT_PROB(3.5, seconds_per_tick))
		affected_mob.emote(pick("twitch","drool","moan","giggle"))

/datum/reagent/drug/space_drugs/overdose_start(mob/living/affected_mob)
	. = ..()
	to_chat(affected_mob, span_userdanger("Вас начинает сильно триповать!"))
	affected_mob.add_mood_event("[type]_overdose", /datum/mood_event/overdose, name)

/datum/reagent/drug/space_drugs/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/hallucination_duration_in_seconds = (affected_mob.get_timed_status_effect_duration(/datum/status_effect/hallucination) / 10)
	if(hallucination_duration_in_seconds < volume && SPT_PROB(10, seconds_per_tick))
		affected_mob.adjust_hallucinations(10 SECONDS)

/datum/reagent/drug/cannabis
	name = "Cannabis"
	description = "Психоактивный наркотик из растения Конопля, используемый в рекреационных целях."
	color = "#059033"
	overdose_threshold = INFINITY
	ph = 6
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	metabolization_rate = 0.125 * REAGENTS_METABOLISM

/datum/reagent/drug/cannabis/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.apply_status_effect(/datum/status_effect/stoned)
	if(SPT_PROB(1, seconds_per_tick))
		var/smoke_message = pick("Вы чувствуете расслабление.","Вы чувствуете спокойствие.","Во рту пересохло.","Вам бы попить воды.","Сердце бьётся чаще.","Вы чувствуете неуклюжесть.","Хочется вредной еды.","Вы замечаете, что двигаетесь медленнее.")
		to_chat(affected_mob, span_notice("[smoke_message]"))
	if(SPT_PROB(2, seconds_per_tick))
		affected_mob.emote(pick("smile","laugh","giggle"))
	affected_mob.adjust_nutrition(-0.15 * REM * seconds_per_tick) //жор
	if(SPT_PROB(4, seconds_per_tick) && affected_mob.body_position == LYING_DOWN && !affected_mob.IsSleeping()) //шанс уснуть если лёжа
		to_chat(affected_mob, span_warning("Вы задремали..."))
		affected_mob.Sleeping(10 SECONDS)
	if(SPT_PROB(4, seconds_per_tick) && affected_mob.buckled && affected_mob.body_position != LYING_DOWN && !affected_mob.IsParalyzed()) //шанс залипнуть если сидишь
		to_chat(affected_mob, span_warning("Слишком удобно, чтобы двигаться..."))
		affected_mob.Paralyze(10 SECONDS)

/datum/reagent/drug/nicotine
	name = "Nicotine"
	description = "Немного сокращает время оглушения. При передозировке наносит урон токсинами и кислородное голодание."
	color = "#60A584" // rgb: 96, 165, 132
	taste_description = "дыма"
	trippy = FALSE
	overdose_threshold = 15
	metabolization_rate = 0.125 * REAGENTS_METABOLISM
	ph = 8
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/nicotine = 15) // 6 per 2 seconds

	//Nicotine is used as a pesticide IRL.
/datum/reagent/drug/nicotine/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_toxic(round(volume))
	mytray.adjust_pestlevel(-rand(1, 2))

/datum/reagent/drug/nicotine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(0.5, seconds_per_tick))
		var/smoke_message = pick("Вы чувствуете расслабление.","Вы чувствуете спокойствие.","Вы чувствуете бодрость.","Вы чувствуете себя крутым.")
		to_chat(affected_mob, span_notice("[smoke_message]"))
	affected_mob.add_mood_event("smoked", /datum/mood_event/smoked)
	affected_mob.remove_status_effect(/datum/status_effect/jitter)
	affected_mob.AdjustAllImmobility(-50 * REM * seconds_per_tick)

	return UPDATE_MOB_HEALTH

/datum/reagent/drug/nicotine/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustToxLoss(0.1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)
	need_mob_update += affected_mob.adjustOxyLoss(1.1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/drug/krokodil
	name = "Krokodil"
	description = "Охлаждает и успокаивает вас. При передозировке наносит значительный урон мозгу и токсинам."
	color = "#0064B4"
	overdose_threshold = 20
	ph = 9
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	inverse_chem_val = 0.3
	inverse_chem = /datum/reagent/inverse/krokodil
	addiction_types = list(/datum/addiction/opioids = 18) //7.2 per 2 seconds

/datum/reagent/drug/krokodil/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/high_message = pick("Вы чувствуете спокойствие.", "Вы чувствуете собранность.", "Вы чувствуете, что вам нужно расслабиться.")
	if(SPT_PROB(2.5, seconds_per_tick))
		to_chat(affected_mob, span_notice("[high_message]"))
	affected_mob.add_mood_event("smacked out", /datum/mood_event/narcotic_heavy)
	if(current_cycle == 36 && creation_purity <= 0.6)
		if(!istype(affected_mob.dna.species, /datum/species/human/krokodil_addict))
			to_chat(affected_mob, span_userdanger("Ваша кожа легко слезает!"))
			var/mob/living/carbon/human/affected_human = affected_mob
			affected_human.set_facial_hairstyle("Выбритый", update = FALSE)
			affected_human.set_hairstyle("Лысый", update = FALSE)
			affected_mob.set_species(/datum/species/human/krokodil_addict)
			if(affected_mob.adjustBruteLoss(50 * REM, updating_health = FALSE, required_bodytype = affected_bodytype)) // holy shit your skin just FELL THE FUCK OFF
				return UPDATE_MOB_HEALTH

/datum/reagent/drug/krokodil/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.25 * REM * seconds_per_tick, required_organ_flag = affected_organ_flags)
	need_mob_update = affected_mob.adjustToxLoss(0.25 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/drug/methamphetamine
	name = "Methamphetamine"
	description = "Уменьшает время оглушения примерно на 300%, ускоряет пользователя и позволяет быстро восстанавливать выносливость, нанося небольшой урон мозгу. При передозировке субъект будет двигаться случайным образом, беспричинно смеяться, ронять предметы и страдать от урона токсинами и мозгом. При зависимости субъект будет постоянно дёргаться и пускать слюни, прежде чем у него закружится голова, он потеряет контроль над моторикой и в конечном итоге понесёт тяжёлый урон токсинами."
	color = "#78C8FA" //лучший сценарий - "по умолчанию", становится запутанным в зависимости от чистоты
	taste_description = "резкие, обжигающие химикаты"
	overdose_threshold = 20
	metabolization_rate = 0.75 * REAGENTS_METABOLISM
	ph = 5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/stimulants = 12) //4.8 per 2 seconds
	metabolized_traits = list(TRAIT_STIMULATED)

/datum/reagent/drug/methamphetamine/on_new(data)
	. = ..()
	//the more pure, the less non-blue colors get involved - best case scenario is rgb(135, 200, 250) AKA #78C8FA
	//worst case scenario is rgb(250, 250, 250) AKA #FAFAFA
	//minimum purity of meth is 50%, therefore we base values on that
	var/effective_impurity = min(1, (1 - creation_purity)/0.5)
	//yes i know that purity doesn't actually affect how meth works at all but this is so funny
	color = BlendRGB(initial(color), "#FAFAFA", effective_impurity)

//we need to update the color whenever purity gets changed
/datum/reagent/drug/methamphetamine/on_merge(list/mix_data, amount)
	. = ..()
	var/effective_impurity = min(1, (1 - creation_purity)/0.5)
	color = BlendRGB(initial(color), "#FAFAFA", effective_impurity)

/datum/reagent/drug/methamphetamine/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/methamphetamine)

/datum/reagent/drug/methamphetamine/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/methamphetamine)

/datum/reagent/drug/methamphetamine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/high_message = pick("Вы чувствуете себя возбуждённо.", "Вы чувствуете, что вам нужно двигаться быстрее.", "Вы чувствуете, что можете управлять миром.", "Теперь вы понимаете.")
	if(SPT_PROB(2.5, seconds_per_tick))
		to_chat(affected_mob, span_notice("[high_message]"))
	affected_mob.add_mood_event("tweaking", /datum/mood_event/stimulant_medium)
	affected_mob.AdjustAllImmobility(-40 * REM * seconds_per_tick)
	var/need_mob_update
	need_mob_update = affected_mob.adjustStaminaLoss(-5 * REM * seconds_per_tick, updating_stamina = FALSE, required_biotype = affected_biotype)
	affected_mob.set_jitter_if_lower(4 SECONDS * REM * seconds_per_tick)
	need_mob_update += affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, rand(1, 4) * REM * seconds_per_tick, required_organ_flag = affected_organ_flags)
	if(need_mob_update)
		. = UPDATE_MOB_HEALTH
	if(SPT_PROB(2.5, seconds_per_tick))
		affected_mob.emote(pick("twitch", "shiver"))

/datum/reagent/drug/methamphetamine/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(!HAS_TRAIT(affected_mob, TRAIT_IMMOBILIZED) && !ismovable(affected_mob.loc))
		for(var/i in 1 to round(4 * REM * seconds_per_tick, 1))
			step(affected_mob, pick(GLOB.cardinals))
	if(SPT_PROB(10, seconds_per_tick))
		affected_mob.emote("laugh")
	if(SPT_PROB(18, seconds_per_tick))
		affected_mob.visible_message(span_danger("Руки [affected_mob] дёргаются и размахиваются во все стороны!"))
		affected_mob.drop_all_held_items()
	var/need_mob_update
	need_mob_update = affected_mob.adjustToxLoss(1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)
	need_mob_update += affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, (rand(5, 10) / 10) * REM * seconds_per_tick, required_organ_flag = affected_organ_flags)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/drug/bath_salts
	name = "Bath Salts"
	description = "Делает вас невосприимчивым к оглушению и даёт бафф регенерации выносливости, но вы станете почти неконтролируемым бродягой с бородой, неистовым сумасшедшим."
	color = "#FAFAFA"
	overdose_threshold = 20
	taste_description = "соль" // because they're bathsalts?
	inverse_chem_val = 0.3
	inverse_chem = /datum/reagent/inverse/bath_salts
	addiction_types = list(/datum/addiction/stimulants = 25)  //8 per 2 seconds
	ph = 8.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	metabolized_traits = list(TRAIT_STUNIMMUNE, TRAIT_SLEEPIMMUNE, TRAIT_ANALGESIA, TRAIT_STIMULATED)
	var/datum/brain_trauma/special/psychotic_brawling/bath_salts/rage

/datum/reagent/drug/bath_salts/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	if(iscarbon(affected_mob))
		var/mob/living/carbon/carbon_mob = affected_mob
		rage = new()
		carbon_mob.gain_trauma(rage, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/reagent/drug/bath_salts/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	if(rage)
		QDEL_NULL(rage)

/datum/reagent/drug/bath_salts/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/high_message = pick("Вы чувствуете себя заряженным.", "Вы чувствуете себя готовым.", "Вы чувствуете, что можете выйти за пределы возможного.")
	if(SPT_PROB(2.5, seconds_per_tick))
		to_chat(affected_mob, span_notice("[high_message]"))
	affected_mob.add_mood_event("salted", /datum/mood_event/stimulant_heavy)
	var/need_mob_update
	need_mob_update = affected_mob.adjustStaminaLoss(-6 * REM * seconds_per_tick, updating_stamina = FALSE, required_biotype = affected_biotype)
	need_mob_update += affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 4 * REM * seconds_per_tick, required_organ_flag = affected_organ_flags)
	affected_mob.adjust_hallucinations(10 SECONDS * REM * seconds_per_tick)
	if(need_mob_update)
		. = UPDATE_MOB_HEALTH
	if(!HAS_TRAIT(affected_mob, TRAIT_IMMOBILIZED) && !ismovable(affected_mob.loc))
		step(affected_mob, pick(GLOB.cardinals))
		step(affected_mob, pick(GLOB.cardinals))

/datum/reagent/drug/bath_salts/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_hallucinations(10 SECONDS * REM * seconds_per_tick)
	if(!HAS_TRAIT(affected_mob, TRAIT_IMMOBILIZED) && !ismovable(affected_mob.loc))
		for(var/i in 1 to round(8 * REM * seconds_per_tick, 1))
			step(affected_mob, pick(GLOB.cardinals))
	if(SPT_PROB(10, seconds_per_tick))
		affected_mob.emote(pick("twitch","drool","moan"))
	if(SPT_PROB(28, seconds_per_tick))
		affected_mob.drop_all_held_items()

/datum/reagent/drug/aranesp
	name = "Aranesp"
	description = "Заряжает вас, заставляет двигаться и быстро восстанавливает урон выносливости. Побочные эффекты включают одышку и токсичность."
	color = "#78FFF0"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	inverse_chem_val = 0.5
	inverse_chem = /datum/reagent/inverse/aranesp
	addiction_types = list(/datum/addiction/stimulants = 8)
	metabolized_traits = list(TRAIT_STIMULATED)

/datum/reagent/drug/aranesp/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/high_message = pick("Вы чувствуете себя заряженным.", "Вы чувствуете себя готовым.", "Вы чувствуете, что можете выйти за пределы возможного.")
	if(SPT_PROB(2.5, seconds_per_tick))
		to_chat(affected_mob, span_notice("[high_message]"))
	var/need_mob_update
	need_mob_update = affected_mob.adjustStaminaLoss(-18 * REM * seconds_per_tick, updating_stamina = FALSE, required_biotype = affected_biotype)
	need_mob_update += affected_mob.adjustToxLoss(0.5 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)
	if(SPT_PROB(30, seconds_per_tick))
		affected_mob.losebreath++
		need_mob_update += affected_mob.adjustOxyLoss(1, FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/drug/happiness
	name = "Happiness"
	description = "Наполняет вас экстатическим онемением и вызывает незначительное повреждение мозга. Высоко аддиктивный. При передозировке вызывает резкие перепады настроения."
	color = "#EE35FF"
	overdose_threshold = 20
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	taste_description = "разбавитель для краски"
	inverse_chem_val = 0.4
	inverse_chem = /datum/reagent/inverse/happiness
	addiction_types = list(/datum/addiction/hallucinogens = 18)
	metabolized_traits = list(TRAIT_FEARLESS, TRAIT_ANALGESIA)

/datum/reagent/drug/happiness/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.add_mood_event("happiness_drug", /datum/mood_event/happiness_drug)

/datum/reagent/drug/happiness/on_mob_delete(mob/living/affected_mob)
	. = ..()
	affected_mob.clear_mood_event("happiness_drug")

/datum/reagent/drug/happiness/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.remove_status_effect(/datum/status_effect/jitter)
	affected_mob.remove_status_effect(/datum/status_effect/confusion)
	affected_mob.disgust = 0
	if(affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.2 * REM * seconds_per_tick, required_organ_flag = affected_organ_flags))
		return UPDATE_MOB_HEALTH

/datum/reagent/drug/happiness/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(16, seconds_per_tick))
		var/reaction = rand(1,3)
		switch(reaction)
			if(1)
				affected_mob.emote("laugh")
				affected_mob.add_mood_event("happiness_drug", /datum/mood_event/happiness_drug_good_od)
			if(2)
				affected_mob.emote("sway")
				affected_mob.set_dizzy_if_lower(50 SECONDS)
			if(3)
				affected_mob.emote("frown")
				affected_mob.add_mood_event("happiness_drug", /datum/mood_event/happiness_drug_bad_od)
	if(affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.5 * REM * seconds_per_tick, required_organ_flag = affected_organ_flags))
		return UPDATE_MOB_HEALTH

/datum/reagent/drug/pumpup
	name = "Pump-Up"
	description = "Покоряй мир! Быстродействующий, мощный наркотик, который расширяет пределы ваших возможностей."
	color = "#e38e44"
	metabolization_rate = 2 * REAGENTS_METABOLISM
	overdose_threshold = 30
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/stimulants = 6) //2.6 per 2 seconds
	metabolized_traits = list(TRAIT_BATON_RESISTANCE, TRAIT_ANALGESIA, TRAIT_STIMULATED)

/datum/reagent/drug/pumpup/on_mob_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	var/obj/item/organ/liver/liver = affected_mob.get_organ_slot(ORGAN_SLOT_LIVER)
	if(liver && HAS_TRAIT(liver, TRAIT_MAINTENANCE_METABOLISM))
		affected_mob.add_mood_event("maintenance_fun", /datum/mood_event/maintenance_high)
		metabolization_rate *= 0.8

/datum/reagent/drug/pumpup/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.set_jitter_if_lower(10 SECONDS * REM * seconds_per_tick)

	if(SPT_PROB(2.5, seconds_per_tick))
		to_chat(affected_mob, span_notice("[pick("Вперёд! Вперёд! ВПЕРЁД!", "Вы чувствуете себя готовым...", "Вы чувствуете себя неуязвимым...")]"))
	if(SPT_PROB(7.5, seconds_per_tick))
		affected_mob.losebreath++
		affected_mob.adjustToxLoss(2, updating_health = FALSE, required_biotype = affected_biotype)
		return UPDATE_MOB_HEALTH

/datum/reagent/drug/pumpup/overdose_start(mob/living/affected_mob)
	. = ..()
	to_chat(affected_mob, span_userdanger("Вы не можете перестать трястись, ваше сердце бьётся всё быстрее и быстрее..."))

/datum/reagent/drug/pumpup/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.set_jitter_if_lower(10 SECONDS * REM * seconds_per_tick)
	var/need_mob_update
	if(SPT_PROB(2.5, seconds_per_tick))
		affected_mob.drop_all_held_items()
	if(SPT_PROB(7.5, seconds_per_tick))
		affected_mob.emote(pick("twitch","drool"))
	if(SPT_PROB(10, seconds_per_tick))
		affected_mob.losebreath++
		affected_mob.adjustStaminaLoss(4, updating_stamina = FALSE, required_biotype = affected_biotype)
		need_mob_update = TRUE
	if(SPT_PROB(7.5, seconds_per_tick))
		need_mob_update += affected_mob.adjustToxLoss(2, updating_health = FALSE, required_biotype = affected_biotype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/drug/maint
	name = "Maintenance Drugs"
	chemical_flags = NONE

/datum/reagent/drug/maint/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	if(!iscarbon(affected_mob))
		return

	var/mob/living/carbon/carbon_mob = affected_mob
	var/obj/item/organ/liver/liver = carbon_mob.get_organ_slot(ORGAN_SLOT_LIVER)
	if(HAS_TRAIT(liver, TRAIT_MAINTENANCE_METABOLISM))
		carbon_mob.add_mood_event("maintenance_fun", /datum/mood_event/maintenance_high)
		metabolization_rate *= 0.8

/datum/reagent/drug/maint/powder
	name = "Maintenance Powder"
	description = "Неизвестный порошок, который вы, скорее всего, получили от ассистента, скучающего химика... или приготовили сами. Это очищенная форма дёгтя, которая усиливает ваши умственные способности, заставляя учиться намного быстрее."
	color = "#ffffff"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 15
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/maintenance_drugs = 14)

/datum/reagent/drug/maint/powder/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.1 * REM * seconds_per_tick, required_organ_flag = affected_organ_flags)
	// 5x if you want to OD, you can potentially go higher, but good luck managing the brain damage.
	var/amt = max(round(volume/3, 0.1), 1)
	affected_mob?.mind?.experience_multiplier_reasons |= type
	affected_mob?.mind?.experience_multiplier_reasons[type] = amt * REM * seconds_per_tick

/datum/reagent/drug/maint/powder/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob?.mind?.experience_multiplier_reasons[type] = null
	affected_mob?.mind?.experience_multiplier_reasons -= type

/datum/reagent/drug/maint/powder/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 6 * REM * seconds_per_tick, required_organ_flag = affected_organ_flags))
		return UPDATE_MOB_HEALTH

/datum/reagent/drug/maint/sludge
	name = "Maintenance Sludge"
	description = "Неизвестный шлам, который вы, скорее всего, получили от ассистента, скучающего химика... или приготовили сами. Наполовину очищенный, он заполняет ваше тело собой, делая его более устойчивым к ранам, но вызывает накопление токсинов."
	color = "#203d2c"
	metabolization_rate = 2 * REAGENTS_METABOLISM
	overdose_threshold = 25
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/maintenance_drugs = 8)
	metabolized_traits = list(TRAIT_HARDLY_WOUNDED, TRAIT_ANALGESIA)

/datum/reagent/drug/maint/sludge/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.adjustToxLoss(0.5 * REM * seconds_per_tick, required_biotype = affected_biotype))
		return UPDATE_MOB_HEALTH

/datum/reagent/drug/maint/sludge/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(!iscarbon(affected_mob))
		return
	var/mob/living/carbon/carbie = affected_mob
	//You will be vomiting so the damage is really for a few ticks before you flush it out of your system
	var/need_mob_update
	need_mob_update = carbie.adjustToxLoss(1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)
	if(SPT_PROB(5, seconds_per_tick))
		need_mob_update += carbie.adjustToxLoss(5, required_biotype = affected_biotype, updating_health = FALSE)
		carbie.vomit(VOMIT_CATEGORY_DEFAULT)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/drug/maint/tar
	name = "Maintenance Tar"
	description = "Неизвестный дёготь, который вы, скорее всего, получили от ассистента, скучающего химика... или приготовили сами. Сырой дёготь, прямо с пола. Может помочь вам избежать плохих ситуаций ценой повреждения печени."
	color = COLOR_BLACK
	overdose_threshold = 30
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/maintenance_drugs = 5)

/datum/reagent/drug/maint/tar/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.AdjustAllImmobility(-10 * REM * seconds_per_tick)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_LIVER, 1.5 * REM * seconds_per_tick, required_organ_flag = affected_organ_flags)
	return UPDATE_MOB_HEALTH

/datum/reagent/drug/maint/tar/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_update
	need_update = affected_mob.adjustToxLoss(5 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)
	need_update += affected_mob.adjustOrganLoss(ORGAN_SLOT_LIVER, 3 * REM * seconds_per_tick, required_organ_flag = affected_organ_flags)
	if(need_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/drug/mushroomhallucinogen
	name = "Mushroom Hallucinogen"
	description = "Сильный галлюциногенный наркотик, полученный из определённых видов грибов."
	color = "#E700E7" // rgb: 231, 0, 231
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	taste_description = "грибы"
	ph = 11
	overdose_threshold = 30
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/hallucinogens = 12)

/datum/reagent/drug/mushroomhallucinogen/on_mob_life(mob/living/carbon/psychonaut, seconds_per_tick, times_fired)
	. = ..()
	psychonaut.set_slurring_if_lower(1 SECONDS * REM * seconds_per_tick)

	switch(current_cycle)
		if(2 to 6)
			if(SPT_PROB(5, seconds_per_tick))
				psychonaut.emote(pick("twitch","giggle"))
		if(6 to 11)
			psychonaut.set_jitter_if_lower(20 SECONDS * REM * seconds_per_tick)
			if(SPT_PROB(10, seconds_per_tick))
				psychonaut.emote(pick("twitch","giggle"))
		if (11 to INFINITY)
			psychonaut.set_jitter_if_lower(40 SECONDS * REM * seconds_per_tick)
			if(SPT_PROB(16, seconds_per_tick))
				psychonaut.emote(pick("twitch","giggle"))

/datum/reagent/drug/mushroomhallucinogen/on_mob_metabolize(mob/living/psychonaut)
	. = ..()

	psychonaut.add_mood_event("tripping", /datum/mood_event/high)
	if(!psychonaut.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = psychonaut.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	// Info for non-matrix plebs like me!

	// This doesn't change the RGB matrixes directly at all. Instead, it shifts all the colors' Hue by 33%,
	// Shifting them up the color wheel, turning R to G, G to B, B to R, making a psychedelic effect.
	// The second moves them two colors up instead, turning R to B, G to R, B to G.
	// The third does a full spin, or resets it back to normal.
	// Imagine a triangle on the color wheel with the points located at the color peaks, rotating by 90 degrees each time.
	// The value with decimals is the Hue. The rest are Saturation, Luminosity, and Alpha, though they're unused here.

	// The filters were initially named _green, _blue, _red, despite every filter changing all the colors. It caused me a 2-years-long headache.

	var/list/col_filter_identity = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0.000,0,0,0)
	var/list/col_filter_shift_once = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0.333,0,0,0)
	var/list/col_filter_shift_twice = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0.666,0,0,0)
	var/list/col_filter_reset = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 1.000,0,0,0) //visually this is identical to the identity

	game_plane_master_controller.add_filter("rainbow", 10, color_matrix_filter(col_filter_reset, FILTER_COLOR_HSL))

	for(var/filter in game_plane_master_controller.get_filters("rainbow"))
		animate(filter, color = col_filter_identity, time = 0 SECONDS, loop = -1, flags = ANIMATION_PARALLEL)
		animate(color = col_filter_shift_once, time = 4 SECONDS)
		animate(color = col_filter_shift_twice, time = 4 SECONDS)
		animate(color = col_filter_reset, time = 4 SECONDS)

	game_plane_master_controller.add_filter("psilocybin_wave", 1, list("type" = "wave", "size" = 2, "x" = 32, "y" = 32))

	for(var/filter in game_plane_master_controller.get_filters("psilocybin_wave"))
		animate(filter, time = 64 SECONDS, loop = -1, easing = LINEAR_EASING, offset = 32, flags = ANIMATION_PARALLEL)

/datum/reagent/drug/mushroomhallucinogen/on_mob_end_metabolize(mob/living/psychonaut)
	. = ..()
	psychonaut.clear_mood_event("tripping")
	if(!psychonaut.hud_used)
		return
	var/atom/movable/plane_master_controller/game_plane_master_controller = psychonaut.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	game_plane_master_controller.remove_filter("rainbow")
	game_plane_master_controller.remove_filter("psilocybin_wave")

/datum/reagent/drug/mushroomhallucinogen/overdose_process(mob/living/psychonaut, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(10, seconds_per_tick))
		psychonaut.emote(pick("twitch","drool","moan"))

	if(SPT_PROB(10, seconds_per_tick))
		psychonaut.apply_status_effect(/datum/status_effect/tower_of_babel)

/datum/reagent/drug/blastoff
	name = "bLaStOoF"
	description = "Наркотик для хардкорной тусовщиков, который, как говорят, улучшает способности на танцполе.\nБольшинство стариков отказываются прикасаться к этому веществу, возможно, потому что воспоминания об инциденте в дискотеке Луны выжжены в их мозгах."
	color = "#9015a9"
	taste_description = "очиститель голодисков"
	ph = 5
	overdose_threshold = 30
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/hallucinogens = 15)
	metabolized_traits = list(TRAIT_STIMULATED)
	///How many flips have we done so far?
	var/flip_count = 0
	///How many spin have we done so far?
	var/spin_count = 0
	///How many flips for a super flip?
	var/super_flip_requirement = 3

/datum/reagent/drug/blastoff/on_mob_metabolize(mob/living/dancer)
	. = ..()

	dancer.add_mood_event("vibing", /datum/mood_event/high)
	RegisterSignal(dancer, COMSIG_MOB_EMOTED("flip"), PROC_REF(on_flip))
	RegisterSignal(dancer, COMSIG_MOB_EMOTED("spin"), PROC_REF(on_spin))

	if(!dancer.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = dancer.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	var/list/col_filter_shift_twice = list(0,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0.764,0,0,0) //most blue color
	var/list/col_filter_mid = list(0,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0.832,0,0,0) //red/blue mix midpoint
	var/list/col_filter_reset = list(0,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0.900,0,0,0) //most red color

	game_plane_master_controller.add_filter("blastoff_filter", 10, color_matrix_filter(col_filter_mid, FILTER_COLOR_HCY))
	game_plane_master_controller.add_filter("blastoff_wave", 1, list("type" = "wave", "x" = 32, "y" = 32))


	for(var/filter in game_plane_master_controller.get_filters("blastoff_filter"))
		animate(filter, color = col_filter_shift_twice, time = 3 SECONDS, loop = -1, flags = ANIMATION_PARALLEL)
		animate(color = col_filter_mid, time = 3 SECONDS)
		animate(color = col_filter_reset, time = 3 SECONDS)
		animate(color = col_filter_mid, time = 3 SECONDS)

	for(var/filter in game_plane_master_controller.get_filters("blastoff_wave"))
		animate(filter, time = 32 SECONDS, loop = -1, easing = LINEAR_EASING, offset = 32, flags = ANIMATION_PARALLEL)

	dancer.sound_environment_override = SOUND_ENVIRONMENT_PSYCHOTIC

/datum/reagent/drug/blastoff/on_mob_end_metabolize(mob/living/dancer)
	. = ..()

	dancer.clear_mood_event("vibing")
	UnregisterSignal(dancer, COMSIG_MOB_EMOTED("flip"))
	UnregisterSignal(dancer, COMSIG_MOB_EMOTED("spin"))

	if(!dancer.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = dancer.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	game_plane_master_controller.remove_filter("blastoff_filter")
	game_plane_master_controller.remove_filter("blastoff_wave")
	dancer.sound_environment_override = NONE

/datum/reagent/drug/blastoff/on_mob_life(mob/living/carbon/dancer, seconds_per_tick, times_fired)
	. = ..()
	if(dancer.adjustOrganLoss(ORGAN_SLOT_LUNGS, 0.3 * REM * seconds_per_tick, required_organ_flag = affected_organ_flags))
		. = UPDATE_MOB_HEALTH
	dancer.AdjustKnockdown(-20)

	if(SPT_PROB(BLASTOFF_DANCE_MOVE_CHANCE_PER_UNIT * volume, seconds_per_tick))
		dancer.emote("flip")

/datum/reagent/drug/blastoff/overdose_process(mob/living/dancer, seconds_per_tick, times_fired)
	. = ..()
	if(dancer.adjustOrganLoss(ORGAN_SLOT_LUNGS, 0.3 * REM * seconds_per_tick, required_organ_flag = affected_organ_flags))
		. = UPDATE_MOB_HEALTH

	if(SPT_PROB(BLASTOFF_DANCE_MOVE_CHANCE_PER_UNIT * volume, seconds_per_tick))
		dancer.emote("spin")

///This proc listens to the flip signal and throws the mob every third flip
/datum/reagent/drug/blastoff/proc/on_flip()
	SIGNAL_HANDLER

	if(!iscarbon(holder.my_atom))
		return
	var/mob/living/carbon/dancer = holder.my_atom

	flip_count++
	if(flip_count < BLASTOFF_DANCE_MOVES_PER_SUPER_MOVE)
		return
	flip_count = 0
	var/atom/throw_target = get_edge_target_turf(dancer, dancer.dir)  //Do a super flip
	dancer.SpinAnimation(speed = 3, loops = 3)
	dancer.visible_message(span_notice("[dancer] делает экстравагантный переворот!"), span_nicegreen("Вы делаете экстравагантный переворот!"))
	dancer.throw_at(throw_target, range = 6, speed = overdosed ? 4 : 1)

///This proc listens to the spin signal and throws the mob every third spin
/datum/reagent/drug/blastoff/proc/on_spin()
	SIGNAL_HANDLER

	if(!iscarbon(holder.my_atom))
		return
	var/mob/living/carbon/dancer = holder.my_atom

	spin_count++
	if(spin_count < BLASTOFF_DANCE_MOVES_PER_SUPER_MOVE)
		return
	spin_count = 0 //Do a super spin.
	dancer.visible_message(span_danger("[dancer] яростно кружится!"), span_danger("Вы яростно кружитесь!"))
	dancer.spin(30, 2)
	if(dancer.disgust < 40)
		dancer.adjust_disgust(10)
	if(!dancer.pulledby)
		return
	var/dancer_turf = get_turf(dancer)
	var/atom/movable/dance_partner = dancer.pulledby
	dance_partner.visible_message(span_danger("[dance_partner] пытается удержаться за [dancer], но его отбрасывает!"), span_danger("Вы пытаетесь удержаться за [dancer], но вас отбрасывает!"), null, COMBAT_MESSAGE_RANGE)
	var/throwtarget = get_edge_target_turf(dancer_turf, get_dir(dancer_turf, get_step_away(dance_partner, dancer_turf)))
	if(overdosed)
		dance_partner.throw_at(target = throwtarget, range = 7, speed = 4)
	else
		dance_partner.throw_at(target = throwtarget, range = 4, speed = 1) //superspeed

/datum/reagent/drug/saturnx
	name = "Saturn-X"
	description = "Это соединение было впервые обнаружено в период становления технологии маскировки и в то время считалось многообещающим кандидатом. Оно было снято с рассмотрения после того, как исследователи обнаружили множество связанных проблем безопасности, включая расстройства мышления и гепатотоксичность."
	taste_description = "металлическая горечь"
	color = "#638b9b"
	overdose_threshold = 25
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	ph = 10
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/maintenance_drugs = 20)

/datum/reagent/drug/saturnx/on_mob_life(mob/living/carbon/invisible_man, seconds_per_tick, times_fired)
	. = ..()
	if(invisible_man.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.3 * REM * seconds_per_tick, required_organ_flag = affected_organ_flags))
		return UPDATE_MOB_HEALTH

/datum/reagent/drug/saturnx/on_mob_metabolize(mob/living/invisible_man)
	. = ..()
	playsound(invisible_man, 'sound/effects/chemistry/saturnx_fade.ogg', 40)
	to_chat(invisible_man, span_nicegreen("Вы чувствуете покалывание по всей коже, когда ваше тело внезапно становится прозрачным!"))
	addtimer(CALLBACK(src, PROC_REF(turn_man_invisible), invisible_man), 1 SECONDS) //just a quick delay to synch up the sound.
	if(!invisible_man.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = invisible_man.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	var/list/col_filter_full = list(1,0,0,0, 0,1.00,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,0)
	var/list/col_filter_twothird = list(1,0,0,0, 0,0.68,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,0)
	var/list/col_filter_half = list(1,0,0,0, 0,0.42,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,0)
	var/list/col_filter_empty = list(1,0,0,0, 0,0,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,0)

	game_plane_master_controller.add_filter("saturnx_filter", 10, color_matrix_filter(col_filter_twothird, FILTER_COLOR_HCY))
	game_plane_master_controller.add_filter("saturnx_blur", 1, list("type" = "radial_blur", "size" = 0))

	for(var/filter in game_plane_master_controller.get_filters("saturnx_filter"))
		animate(filter, loop = -1, color = col_filter_full, time = 4 SECONDS, easing = CIRCULAR_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
		//uneven so we spend slightly less time with bright colors
		animate(color = col_filter_twothird, time = 6 SECONDS, easing = LINEAR_EASING)
		animate(color = col_filter_half, time = 3 SECONDS, easing = LINEAR_EASING)
		animate(color = col_filter_empty, time = 2 SECONDS, easing = CIRCULAR_EASING|EASE_OUT)
		animate(color = col_filter_half, time = 24 SECONDS, easing = CIRCULAR_EASING|EASE_IN)
		animate(color = col_filter_twothird, time = 12 SECONDS, easing = LINEAR_EASING)

	for(var/filter in game_plane_master_controller.get_filters("saturnx_blur"))
		animate(filter, loop = -1, size = 0.02, time = 2 SECONDS, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
		animate(size = 0, time = 6 SECONDS, easing = SINE_EASING)

///This proc turns the living mob passed as the arg "invisible_man"s invisible by giving him the invisible man trait and updating his body, this changes the sprite of all his organic limbs to a 1 alpha version.
/datum/reagent/drug/saturnx/proc/turn_man_invisible(mob/living/carbon/invisible_man, requires_liver = TRUE)
	if(requires_liver)
		if(!invisible_man.get_organ_slot(ORGAN_SLOT_LIVER))
			return
		if(invisible_man.undergoing_liver_failure())
			return
		if(HAS_TRAIT(invisible_man, TRAIT_LIVERLESS_METABOLISM))
			return
	if(invisible_man.has_status_effect(/datum/status_effect/grouped/stasis))
		return

	invisible_man.add_traits(list(TRAIT_INVISIBLE_MAN, TRAIT_HIDE_EXTERNAL_ORGANS, TRAIT_NO_BLOOD_OVERLAY), type)

	invisible_man.update_body()
	invisible_man.remove_from_all_data_huds()
	invisible_man.sound_environment_override = SOUND_ENVIROMENT_PHASED

/datum/reagent/drug/saturnx/on_mob_end_metabolize(mob/living/carbon/invisible_man)
	. = ..()
	if(HAS_TRAIT_FROM(invisible_man, TRAIT_INVISIBLE_MAN, type))
		invisible_man.add_to_all_human_data_huds() //Is this safe, what do you think, Floyd?
		invisible_man.remove_traits(list(TRAIT_INVISIBLE_MAN, TRAIT_HIDE_EXTERNAL_ORGANS, TRAIT_NO_BLOOD_OVERLAY), type)

		to_chat(invisible_man, span_notice("По мере того как вы трезвеете, непрозрачность снова возвращается к вашей телесной плоти."))

	invisible_man.update_body()
	invisible_man.sound_environment_override = NONE

	if(!invisible_man.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = invisible_man.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	game_plane_master_controller.remove_filter("saturnx_filter")
	game_plane_master_controller.remove_filter("saturnx_blur")

/datum/reagent/drug/saturnx/overdose_process(mob/living/invisible_man, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(7.5, seconds_per_tick))
		invisible_man.emote("giggle")
	if(SPT_PROB(5, seconds_per_tick))
		invisible_man.emote("laugh")
	if(invisible_man.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.4 * REM * seconds_per_tick, required_organ_flag = affected_organ_flags))
		return UPDATE_MOB_HEALTH

/datum/reagent/drug/saturnx/stable
	name = "Stabilized Saturn-X"
	description = "Химический экстракт, происходящий из соединения Сатурн-Икс, стабилизированный и более безопасный для тактического использования. После того как рецепт был обнаружен, планировалось начать массовое производство, но программа развалилась после того, как её руководитель исчез и больше его никто не видел."
	metabolization_rate = 0.15 * REAGENTS_METABOLISM
	overdose_threshold = 50
	addiction_types = list(/datum/addiction/maintenance_drugs = 35)

/*Kronkaine is a rare natural stimulant that can help you instantly clear stamina damage in combat,
but it also greatly aids civilians by letting them perform everyday actions like cleaning, building, pick pocketing and even performing surgery at double speed.

The main part of the stamina regeneration happens instantly once the reagent is added to the player and is doubled if smoked or injected.
After the initial burst of stamina, it also imparts stamina restoration per cycle.

The instant and gradual restoration effects as well as the heart damage are dose dependant, encouraging the player to push the limit of what is safe and reeasonable!

If you have at over 25u in your body you restore more than 20 stamina per cycle, enough to revive you from stamina crit, beware that this is a potentially fatal overdose!*/
/datum/reagent/drug/kronkaine
	name = "Kronkaine"
	description = "Высоконелегальный стимулятор с окраины галактики.\nГоворят, что средняя добавка кронкейна наносит столько же криминального ущерба, сколько пять грабителей, два хулигана и один профессиональный хастлер камбринго вместе взятые."
	color = "#FAFAFA"
	taste_description = "онемевающая горечь"
	ph = 8
	overdose_threshold = 20
	metabolization_rate = 0.75 * REAGENTS_METABOLISM
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/stimulants = 20)
	metabolized_traits = list(TRAIT_STIMULATED)

/datum/reagent/drug/kronkaine/on_new(data)
	. = ..()
	// Kronkaine also makes for a great fishing bait (found in "natural" baits)
	if(!istype(holder?.my_atom, /obj/item/food))
		return
	ADD_TRAIT(holder.my_atom, TRAIT_GREAT_QUALITY_BAIT, type)

/datum/reagent/drug/kronkaine/Destroy()
	REMOVE_TRAIT(holder.my_atom, TRAIT_GREAT_QUALITY_BAIT, type)
	return ..()

/datum/reagent/drug/kronkaine/on_mob_metabolize(mob/living/kronkaine_fiend)
	. = ..()
	kronkaine_fiend.add_actionspeed_modifier(/datum/actionspeed_modifier/kronkaine)
	kronkaine_fiend.sound_environment_override = SOUND_ENVIRONMENT_HANGAR
	SEND_SOUND(kronkaine_fiend, sound('sound/effects/health/fastbeat.ogg', repeat = TRUE, channel = CHANNEL_HEARTBEAT, volume = 30))

/datum/reagent/drug/kronkaine/on_mob_end_metabolize(mob/living/kronkaine_fiend)
	. = ..()
	kronkaine_fiend.remove_actionspeed_modifier(/datum/actionspeed_modifier/kronkaine)
	kronkaine_fiend.sound_environment_override = NONE
	//Stop the rapid heartneats, we make sure we are not in crit as to not mess with the heartbeats from organ/heart.
	if(!kronkaine_fiend.stat)
		kronkaine_fiend.stop_sound_channel(CHANNEL_HEARTBEAT)

/datum/reagent/drug/kronkaine/expose_mob(mob/living/carbon/druggo, methods, trans_volume, show_message, touch_protection)
	. = ..()
	if(!iscarbon(druggo))
		return

	//The drug is more effective if smoked or injected, restoring more stamina per unit.
	var/stamina_heal_per_unit
	if(methods & (INJECT|INHALE))
		stamina_heal_per_unit = 12
		if(trans_volume >= 3)
			SEND_SOUND(druggo, sound('sound/items/weapons/flash_ring.ogg')) //Эффект часто называют "колокола кронкейна".
			to_chat(druggo, span_danger("В ушах звенит, когда ваше кровяное давление внезапно подскакивает!"))
			to_chat(druggo, span_nicegreen("Вы чувствуете потрясающий прилив!"))
		else if(prob(15))
			to_chat(druggo, span_nicegreen(pick("Вы чувствуете, как трусость тает...", "Вы чувствуете себя безразличным к суждениям других.", "Моя жизнь кажется прекрасной!", "Вы опускаете морду... и внезапно чувствуете себя более благотворительным!")))
	else
		stamina_heal_per_unit = 6
	druggo.adjustStaminaLoss(-stamina_heal_per_unit * trans_volume)

/datum/reagent/drug/kronkaine/on_mob_life(mob/living/carbon/kronkaine_fiend, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	kronkaine_fiend.add_mood_event("tweaking", /datum/mood_event/stimulant_medium)
	if(kronkaine_fiend.adjustOrganLoss(ORGAN_SLOT_HEART, (0.1 + 0.04 * volume) * REM * seconds_per_tick, required_organ_flag = affected_organ_flags))
		need_mob_update = UPDATE_MOB_HEALTH
		if(kronkaine_fiend.get_organ_loss(ORGAN_SLOT_HEART) >= 75 && prob(15))
			to_chat(kronkaine_fiend, span_userdanger("Вы чувствуете, будто ваше сердце вот-вот взорвётся!"))
			playsound(kronkaine_fiend, 'sound/effects/singlebeat.ogg', 200, TRUE)
	kronkaine_fiend.set_jitter_if_lower(20 SECONDS * REM * seconds_per_tick)
	kronkaine_fiend.AdjustSleeping(-2 SECONDS * REM * seconds_per_tick)
	kronkaine_fiend.adjust_drowsiness(-10 SECONDS * REM * seconds_per_tick)
	/* Do not try to cheese the overdose threshhold with purging chems to become stamina immune, if you purge and take stamina damage you will be punished!

	The reason why I choose to add the adrenal crisis anti-cheese mechanic is because the main combat benefit is so front loaded, you could easily negate all the risk and downsides by mixing it with a small amount of a purger like haloperidol.
	I think that level of safety goes against the design we would like achieve with drugs; great rewards but at the cost of great risk.*/
	if(kronkaine_fiend.getStaminaLoss() > 30)
		for(var/possible_purger in kronkaine_fiend.reagents.reagent_list)
			if(istype(possible_purger, /datum/reagent/medicine/c2/multiver) || istype(possible_purger, /datum/reagent/medicine/haloperidol))
				if(kronkaine_fiend.HasDisease(/datum/disease/adrenal_crisis))
					break
				kronkaine_fiend.visible_message(span_bolddanger("[kronkaine_fiend.name] внезапно напрягается, похоже, шок заставляет их тело отключаться!"), span_userdanger("Внезапный шок в сочетании с коктейлем наркотиков и слабительных в вашем теле выводит вашу адреналовую систему из строя. Ой-ой!"))
				kronkaine_fiend.ForceContractDisease(new /datum/disease/adrenal_crisis(), FALSE, TRUE) //We punish players for purging, since unchecked purging would allow players to reap the stamina healing benefits without any drawbacks. This also has the benefit of making haloperidol a counter, like it is supposed to be.
				break
	need_mob_update = kronkaine_fiend.adjustStaminaLoss(-0.8 * volume * REM * seconds_per_tick, updating_stamina = FALSE, required_biotype = affected_biotype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/drug/kronkaine/overdose_process(mob/living/kronkaine_fiend, seconds_per_tick, times_fired)
	. = ..()
	if(kronkaine_fiend.adjustOrganLoss(ORGAN_SLOT_HEART, 0.5 * REM * seconds_per_tick, required_organ_flag = affected_organ_flags))
		. = UPDATE_MOB_HEALTH
	kronkaine_fiend.set_jitter_if_lower(20 SECONDS * REM * seconds_per_tick)
	if(SPT_PROB(10, seconds_per_tick))
		to_chat(kronkaine_fiend, span_danger(pick("Ваше сердце бешено колотится!", "В ушах звенит!", "Вы потеете как свинья!", "Вы сжимаете челюсти и скрипите зубами.", "Вы чувствуете колющую боль в груди.")))

/datum/reagent/drug/kronkaine/overdose_start(mob/living/affected_mob)
	. = ..()
	SEND_SOUND(affected_mob, sound('sound/effects/health/fastbeat.ogg', repeat = TRUE, channel = CHANNEL_HEARTBEAT, volume = 90))

///dirty kronkaine, aka gore. far worse overdose effects.
/datum/reagent/drug/kronkaine/gore
	name = "Gore"
	description = "Грязный Кронкейн. Нужно быть довольно глупым, чтобы принять это. Не делайте этого. Передозировка."
	color = "#ffbebe" // kronkaine but with some red
	ph = 4
	chemical_flags = NONE

/datum/reagent/drug/kronkaine/gore/overdose_start(mob/living/gored)
	. = ..()
	gored.visible_message(
		span_danger("[gored] взрывается в ливне крови и внутренностей!"),
		span_userdanger("РАСЧЛЕНЁНКА! РАСЧЛЕНЁНКА! РАСЧЛЕНЁНКА! ТЫ РАСЧЛЕНЁН! СЛИШКОМ МНОГО РАСЧЛЕНЁН! ТЫ РАСЧЛЕНЁН! РАСЧЛЕНЁНКА! ВСЁ КОНЧЕНО! РАСЧЛЕНЁНКА! РАСЧЛЕНЁНКА! ТЫ РАСЧЛЕНЁНКА! СЛИШКОМ МНОГО РАС-"),
	)
	new /obj/structure/bouncy_castle(gored.loc, gored)
	gored.gib()

/datum/reagent/drug/syndol
	name = "Syndol"
	description = "Мощный и аддиктивный галлюциноген, используемый агентами синдиката для дезориентации определённых целей. \
		Говорят, что вызываемые им галлюцинации специально под страхи пользователя, но тесты были неубедительными, \
		так как испытуемые из службы безопасности и ассистенты сообщали о совершенно разных переживаниях."
	color = "#c90000"
	taste_description = "металл"
	ph = 7
	overdose_threshold = 10
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/hallucinogens = 20)
	/// Track the active hallucination we're giving out so we don't replace it by accident
	VAR_PRIVATE/datum/weakref/active_hallucination_weakref

/datum/reagent/drug/syndol/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/obj/item/organ/liver = affected_mob.get_organ_slot(ORGAN_SLOT_LIVER)
	if(isnull(liver) || !(liver.organ_flags & affected_organ_flags))
		return
	// non-trivial but not immediately dangerous liver damage
	liver.apply_organ_damage(0.5 * REM * seconds_per_tick)
	// anti-hallucinogens can counteract the effects
	if(HAS_TRAIT(affected_mob, TRAIT_HALLUCINATION_IMMUNE) || affected_mob.reagents.has_reagent(/datum/reagent/medicine/haloperidol, amount = 3, needs_metabolizing = TRUE))
		QDEL_NULL(active_hallucination_weakref)
		return

	// and the main event, funny hallucinations
	if(active_hallucination_weakref?.resolve())
		return
	var/greatest_fear
	if(HAS_TRAIT(liver, TRAIT_LAW_ENFORCEMENT_METABOLISM))
		greatest_fear = /datum/hallucination/delusion/preset/syndies
	else if(HAS_TRAIT(liver, TRAIT_MAINTENANCE_METABOLISM) || HAS_TRAIT(liver, TRAIT_COMEDY_METABOLISM))
		greatest_fear = /datum/hallucination/delusion/preset/seccies

	if(greatest_fear)
		// 5 minutes = 15 units, roughly. we cancel the hallucination early when we exit the mob, anyway
		active_hallucination_weakref = WEAKREF(affected_mob.cause_hallucination(greatest_fear, name, duration = 5 MINUTES, skip_nearby = !overdosed))
	else
		// if they're just some random schmuck, give them random hallucinations
		affected_mob.adjust_hallucinations_up_to(4 SECONDS * REM * seconds_per_tick, 30 SECONDS)

/datum/reagent/drug/syndol/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.adjust_hallucinations(-16 SECONDS)
	QDEL_NULL(active_hallucination_weakref)

/datum/reagent/drug/syndol/overdose_start(mob/living/affected_mob)
	// no message, just refresh the hallucination
	QDEL_NULL(active_hallucination_weakref)
