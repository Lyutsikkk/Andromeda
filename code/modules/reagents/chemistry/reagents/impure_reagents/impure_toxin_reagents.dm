//Reagents produced by metabolising/reacting fermichems suboptimally these specifically are for toxins
//Inverse = Splitting
//Invert = Whole conversion
//Failed = End reaction below purity_min

////////////////////TOXINS///////////////////////////

//Lipolicide - Impure Version
/datum/reagent/impurity/ipecacide
	name = "Ipecacide"
	description = "Чрезвычайно противное вещество, вызывающее рвоту. Образуется при нечистых реакциях Липолицида."
	ph = 7
	liver_damage = 0

/datum/reagent/impurity/ipecacide/on_mob_add(mob/living/carbon/owner)
	if(owner.disgust >= DISGUST_LEVEL_GROSS)
		return ..()
	owner.adjust_disgust(50)
	..()

//Formaldehyde - Impure Version
/datum/reagent/impurity/methanol
	name = "Methanol"
	description = "Лёгкая, бесцветная жидкость с характерным запахом. Проглатывание может привести к слепоте. Является побочным продуктом переработки нечистого Формальдегида организмами."
	color = "#aae7e4"
	ph = 7
	liver_damage = 0

/datum/reagent/impurity/methanol/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/obj/item/organ/eyes/eyes = affected_mob.get_organ_slot(ORGAN_SLOT_EYES)
	if(eyes?.apply_organ_damage(0.5 * REM * seconds_per_tick, required_organ_flag = affected_organ_flags))
		return UPDATE_MOB_HEALTH

//Chloral Hydrate - Impure Version
/datum/reagent/impurity/chloralax
	name = "Chloralax"
	description = "Маслянистая, бесцветная и слегка токсичная жидкость. Образуется при расщеплении нечистого хлоралгидрата внутри организма."
	color = "#387774"
	ph = 7
	liver_damage = 0

/datum/reagent/impurity/chloralax/on_mob_life(mob/living/carbon/owner, seconds_per_tick)
	. = ..()
	if(owner.adjustToxLoss(1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
		return UPDATE_MOB_HEALTH

//Mindbreaker Toxin - Impure Version
/datum/reagent/impurity/rosenol
	name = "Rosenol"
	description = "Странная синяя жидкость, которая образуется во время нечистых реакций токсина разрушителя разума. Исторически её злоупотребляли для написания поэзии."
	color = "#0963ad"
	ph = 7
	liver_damage = 0
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/datum/reagent/impurity/rosenol/on_mob_life(mob/living/carbon/owner, seconds_per_tick)
	. = ..()
	var/obj/item/organ/tongue/tongue = owner.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(!tongue)
		return
	if(SPT_PROB(4.0, seconds_per_tick))
		owner.manual_emote("щёлкает [owner.p_their()] языком.")
		owner.say("Классно.", forced = /datum/reagent/impurity/rosenol)
	if(SPT_PROB(2.0, seconds_per_tick))
		owner.say(pick("Ах! Это было ошибкой!", "Ужасно.", "Внимание всем, картошка очень горячая.", "Когда мне было шесть, я съел пакет слив.", "И если есть что-то, что я не выношу, так это помидоры.", "И если есть что-то, что я люблю, так это помидоры.", "У нас был капитан, который был настолько строг, что на его станции нельзя было дышать.", "Анробасты просто падали замертво, ты слышал, как они падают позади тебя."), forced = /datum/reagent/impurity/rosenol)
