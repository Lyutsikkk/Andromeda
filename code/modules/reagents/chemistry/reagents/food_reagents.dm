///////////////////////////////////////////////////////////////////
					//Food Reagents
//////////////////////////////////////////////////////////////////


// Part of the food code. Also is where all the food
// condiments, additives, and such go.

/datum/reagent/consumable
	name = "Consumable"
	taste_description = "обычная еда"
	taste_mult = 4
	inverse_chem_val = 0.1
	inverse_chem = null
	creation_purity = CONSUMABLE_STANDARD_PURITY
	/// How much nutrition this reagent supplies. Look at get_nutriment_factor() for an understanding.
	var/nutriment_factor = 1
	/// affects mood, typically higher for mixed drinks with more complex recipes'
	var/quality = 0

/datum/reagent/consumable/New()
	. = ..()
	// All food reagents function at a fixed rate
	chemical_flags |= REAGENT_UNAFFECTED_BY_METABOLISM

/datum/reagent/consumable/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(!ishuman(affected_mob) || HAS_TRAIT(affected_mob, TRAIT_NOHUNGER))
		return

	var/mob/living/carbon/human/affected_human = affected_mob
	affected_human.adjust_nutrition(get_nutriment_factor(affected_mob) * REM * seconds_per_tick)

/datum/reagent/consumable/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	. = ..()
	if(!(methods & INGEST) || !quality || HAS_TRAIT(exposed_mob, TRAIT_AGEUSIA))
		return
	switch(quality)
		if (DRINK_REVOLTING)
			exposed_mob.add_mood_event("quality_drink", /datum/mood_event/quality_revolting)
		if (DRINK_NICE)
			exposed_mob.add_mood_event("quality_drink", /datum/mood_event/quality_nice)
		if (DRINK_GOOD)
			exposed_mob.add_mood_event("quality_drink", /datum/mood_event/quality_good)
		if (DRINK_VERYGOOD)
			exposed_mob.add_mood_event("quality_drink", /datum/mood_event/quality_verygood)
		if (DRINK_FANTASTIC)
			exposed_mob.add_mood_event("quality_drink", /datum/mood_event/quality_fantastic)
			exposed_mob.add_mob_memory(/datum/memory/good_drink, drink = src)
		if (FOOD_AMAZING)
			exposed_mob.add_mood_event("quality_food", /datum/mood_event/amazingtaste)
			// The food this was in was really tasty, not the reagent itself
			var/obj/item/the_real_food = holder.my_atom
			if(isitem(the_real_food) && !is_reagent_container(the_real_food))
				exposed_mob.add_mob_memory(/datum/memory/good_food, food = the_real_food)

/// Gets just how much nutrition this reagent supplies per server tick to the eater
/datum/reagent/consumable/proc/get_nutriment_factor(mob/living/carbon/eater)
	return nutriment_factor * REAGENTS_METABOLISM * purity * 2

/datum/reagent/consumable/nutriment
	name = "Nutriment"
	description = "Все витамины, минералы и углеводы, необходимые организму, в чистом виде."
	nutriment_factor = 15
	color = "#664330" // rgb: 102, 67, 48
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

	/// Whether this reagent should get the tastes of food it's in applied onto it
	var/carry_food_tastes = TRUE

	var/brute_heal = 1
	var/burn_heal = 0

/datum/reagent/consumable/nutriment/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_plant_health(round(volume * 0.2))

/datum/reagent/consumable/nutriment/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(30, seconds_per_tick))
		if(affected_mob.heal_bodypart_damage(brute = brute_heal * REM * seconds_per_tick, burn = burn_heal * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC))
			return UPDATE_MOB_HEALTH

/datum/reagent/consumable/nutriment/on_new(list/supplied_data)
	. = ..()
	if(!data)
		return
	// taste data can sometimes be ("salt" = 3, "chips" = 1)
	// and we want it to be in the form ("salt" = 0.75, "chips" = 0.25)
	// which is called "normalizing"
	if(!supplied_data)
		supplied_data = data

	// if data isn't an associative list, this has some WEIRD side effects
	// TODO probably check for assoc list?

	data = counterlist_normalise(supplied_data)

/datum/reagent/consumable/nutriment/on_merge(list/mix_data, amount)
	. = ..()
	if(!islist(mix_data) || !mix_data.len)
		return

	// data for nutriment is one or more (flavour -> ratio)
	// where all the ratio values adds up to 1

	var/list/taste_amounts = list()
	if(data)
		taste_amounts = data.Copy()

	counterlist_scale(taste_amounts, volume)

	var/list/other_taste_amounts = mix_data.Copy()
	counterlist_scale(other_taste_amounts, amount)

	counterlist_combine(taste_amounts, other_taste_amounts)

	counterlist_normalise(taste_amounts)

	data = taste_amounts

/datum/reagent/consumable/nutriment/get_taste_description(mob/living/taster)
	if(length(data))
		return data
	return ..()

/datum/reagent/consumable/nutriment/vitamin
	name = "Vitamin"
	description = "Все лучшие витамины, минералы и углеводы, необходимые организму, в чистом виде."
	taste_description = "горечь"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	brute_heal = 1
	burn_heal = 1

/datum/reagent/consumable/nutriment/vitamin/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.satiety < MAX_SATIETY)
		affected_mob.satiety += 30 * REM * seconds_per_tick

/// The basic resource of vat growing.
/datum/reagent/consumable/nutriment/protein
	name = "Protein"
	description = "Натуральный полиамид, состоящий из аминокислот. Важная составляющая большинства известных форм жизни."
	taste_description = "мел"
	brute_heal = 0.8 //Rewards the player for eating a balanced diet.
	nutriment_factor = 9 //45% as calorie dense as oil.
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/protein

/datum/reagent/consumable/nutriment/fat
	name = "Fat"
	description = "Триглицериды, содержащиеся в растительных маслах и жировой ткани животных."
	color = "#f0eed7"
	taste_description = "сало"
	brute_heal = 0
	burn_heal = 1
	nutriment_factor = 18 // Twice as nutritious compared to protein and carbohydrates
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	var/fry_temperature = 450 //Around ~350 F (117 C) which deep fryers operate around in the real world

/datum/reagent/consumable/nutriment/fat/expose_obj(obj/exposed_obj, reac_volume, methods=TOUCH, show_message=TRUE)
	. = ..()
	if(!holder || (holder.chem_temp <= fry_temperature))
		return
	if(!isitem(exposed_obj) || HAS_TRAIT(exposed_obj, TRAIT_FOOD_FRIED))
		return
	if(is_type_in_typecache(exposed_obj, GLOB.oilfry_blacklisted_items) || (exposed_obj.resistance_flags & INDESTRUCTIBLE))
		exposed_obj.visible_message(span_notice("Горячее масло не оказывает никакого эффекта на [exposed_obj]!"))
		return
	if(exposed_obj.atom_storage)
		exposed_obj.visible_message(span_notice("Горячее масло разбрызгивается, когда [exposed_obj] касается его. Кажется, оно слишком заполнено, чтобы правильно приготовиться!"))
		return

	exposed_obj.visible_message(span_warning("[exposed_obj] быстро жарится, когда его обдают горячим маслом! Как-то так."))
	exposed_obj.AddElement(/datum/element/fried_item, volume SECONDS)
	exposed_obj.reagents.add_reagent(type, reac_volume, data, holder.chem_temp)

/datum/reagent/consumable/nutriment/fat/expose_mob(mob/living/exposed_mob, methods = TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if(!(methods & (VAPOR|TOUCH)) || isnull(holder) || (holder.chem_temp < fry_temperature)) //Directly coats the mob, and doesn't go into their bloodstream
		return

	var/burn_damage = ((holder.chem_temp / fry_temperature) * 0.33) //Damage taken per unit
	if(methods & TOUCH)
		burn_damage *= max(1 - touch_protection, 0)
	var/FryLoss = round(min(38, burn_damage * reac_volume))
	if(HAS_TRAIT(exposed_mob, TRAIT_OIL_FRIED))
		return

	exposed_mob.visible_message(span_warning("Кипящее масло шипит, покрывая [exposed_mob]!"), \
	span_userdanger("Вас покрыло кипящее масло!"))
	if(FryLoss)
		exposed_mob.emote("scream")
		exposed_mob.adjustFireLoss(FryLoss)
	playsound(exposed_mob, 'sound/machines/fryer/deep_fryer_emerge.ogg', 25, TRUE)
	ADD_TRAIT(exposed_mob, TRAIT_OIL_FRIED, "cooking_oil_react")
	addtimer(CALLBACK(exposed_mob, TYPE_PROC_REF(/mob/living, unfry_mob)), 2 SECONDS)

/datum/reagent/consumable/nutriment/fat/expose_turf(turf/open/exposed_turf, reac_volume)
	. = ..()
	if(!istype(exposed_turf))
		return
	exposed_turf.MakeSlippery(TURF_WET_LUBE, min_wet_time = 10 SECONDS, wet_time_to_add = reac_volume*2 SECONDS)
	var/obj/effect/hotspot/hotspot = (locate(/obj/effect/hotspot) in exposed_turf)
	if(hotspot)
		var/datum/gas_mixture/lowertemp = exposed_turf.remove_air(exposed_turf.air.total_moles())
		lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
		lowertemp.react(src)
		exposed_turf.assume_air(lowertemp)
		qdel(hotspot)

/datum/reagent/consumable/nutriment/fat/oil
	name = "Vegetable Oil"
	description = "Разновидность растительного масла, получаемого из растительных жиров. Используется в приготовлении пищи и жарке."
	color = "#EADD6B" //RGB: 234, 221, 107 (на основе рапсового масла)
	taste_mult = 0.8
	taste_description = "масло"
	carry_food_tastes = FALSE
	nutriment_factor = 7 //Not very healthy on its own
	metabolization_rate = 10 * REAGENTS_METABOLISM
	penetrates_skin = NONE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/vegetable_oil

/datum/reagent/consumable/nutriment/fat/oil/olive
	name = "Olive Oil"
	description = "Высококачественное масло, подходящее для блюд, где масло является ключевым вкусом."
	taste_description = "оливковое масло"
	color = "#DBCF5C"
	nutriment_factor = 10
	default_container = /obj/item/reagent_containers/condiment/olive_oil

/datum/reagent/consumable/nutriment/fat/oil/corn
	name = "Corn Oil"
	description = "Масло, получаемое из различных видов кукурузы."
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "слизь"
	nutriment_factor = 5 //it's a very cheap oil

/datum/reagent/consumable/nutriment/organ_tissue
	name = "Organ Tissue"
	description = "Натуральные ткани, составляющие основную массу органов, обеспечивающие множество витаминов и минералов."
	taste_description = "насыщенный землистый острый"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/nutriment/organ_tissue/stomach_lining
	name = "Stomach Lining"
	description = "Натуральная ткань, которая защищает ваш желудок."
	carry_food_tastes = FALSE // Don't want stomachs to leech the flavours of what they eat

/datum/reagent/consumable/nutriment/cloth_fibers
	name = "Cloth Fibers"
	description = "Это на самом деле не форма нутримента, но это ненадолго поддерживает Мотыльков..."
	taste_description = "ткань"
	nutriment_factor = 30
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	brute_heal = 0
	burn_heal = 0
	///Amount of satiety that will be drained when the cloth_fibers is fully metabolized
	var/delayed_satiety_drain = 2 * CLOTHING_NUTRITION_GAIN

/datum/reagent/consumable/nutriment/cloth_fibers/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.satiety < MAX_SATIETY)
		affected_mob.adjust_nutrition(CLOTHING_NUTRITION_GAIN)
		delayed_satiety_drain += CLOTHING_NUTRITION_GAIN

/datum/reagent/consumable/nutriment/cloth_fibers/on_mob_delete(mob/living/carbon/affected_mob)
	. = ..()
	if(!iscarbon(affected_mob))
		return

	var/mob/living/carbon/carbon_mob = affected_mob
	carbon_mob.adjust_nutrition(-delayed_satiety_drain)

/datum/reagent/consumable/nutriment/mineral
	name = "Mineral Slurry"
	description = "Минералы, растёртые в пасту, питательные только если вы тоже сделаны из камней."
	taste_description = "минералы"
	color = COLOR_WEBSAFE_DARK_GRAY
	chemical_flags = NONE
	brute_heal = 0
	burn_heal = 0

/datum/reagent/consumable/nutriment/mineral/get_nutriment_factor(mob/living/carbon/eater)
	if(HAS_TRAIT(eater, TRAIT_ROCK_EATER))
		return ..()

	// You cannot eat rocks, it gives no nutrition
	return 0

/datum/reagent/consumable/sugar
	name = "Sugar"
	description = "Органическое соединение, широко известное как столовый сахар и иногда называемое сахарозой. Этот белый, без запаха, кристаллический порошок имеет приятный сладкий вкус."
	color = COLOR_WHITE // rgb: 255, 255, 255
	taste_mult = 1.5 // stop sugar drowning out other flavours
	nutriment_factor = 2
	metabolization_rate = 5 * REAGENTS_METABOLISM
	creation_purity = 1 // impure base reagents are a big no-no
	overdose_threshold = 120 // Hyperglycaemic shock
	taste_description = "сладость"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/sugar

// Plants should not have sugar, they can't use it and it prevents them getting water/ nutients, it is good for mold though...
/datum/reagent/consumable/sugar/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_weedlevel(rand(1, 2))
	mytray.adjust_pestlevel(rand(1, 2))

/datum/reagent/consumable/sugar/overdose_start(mob/living/affected_mob)
	. = ..()
	to_chat(affected_mob, span_userdanger("У вас гипергликемический шок! Полегче с твинки!"))
	affected_mob.AdjustSleeping(20 SECONDS)

/datum/reagent/consumable/sugar/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_drowsiness_up_to((5 SECONDS * REM * seconds_per_tick), 60 SECONDS)

/datum/reagent/consumable/sugar/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	. = ..()
	if(methods & INGEST)
		exposed_mob.check_allergic_reaction(SUGAR, chance = reac_volume * 10, histamine_add = min(10, reac_volume * 2))

/datum/reagent/consumable/virus_food
	name = "Virus Food"
	description = "Смесь воды и молока. Клетки вирусов могут использовать эту смесь для размножения."
	nutriment_factor = 2
	color = "#899613" // rgb: 137, 150, 19
	taste_description = "водянистое молоко"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

// Compost for EVERYTHING
/datum/reagent/consumable/virus_food/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_plant_health(-round(volume * 0.5))

/datum/reagent/consumable/soysauce
	name = "Soysauce"
	description = "Солёный соус, приготовленный из соевых бобов."
	nutriment_factor = 2
	color = "#792300" // rgb: 121, 35, 0
	taste_description = "умами"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/soysauce

/datum/reagent/consumable/ketchup
	name = "Ketchup"
	description = "Кетчуп, кетсап, неважно. Это томатная паста."
	nutriment_factor = 5
	color = "#731008" // rgb: 115, 16, 8
	taste_description = "кетчуп"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/ketchup

/datum/reagent/consumable/capsaicin
	name = "Capsaicin Oil"
	description = "Это то, что делает перец чили острым."
	color = "#B31008" // rgb: 179, 16, 8
	taste_description = "острый перец"
	taste_mult = 1.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/capsaicin/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/heating = 0
	switch(current_cycle)
		if(1 to 15)
			heating = 5
			if(holder.has_reagent(/datum/reagent/cryostylane))
				holder.remove_reagent(/datum/reagent/cryostylane, 5 * REM * seconds_per_tick)
		if(15 to 25)
			heating = 10
		if(25 to 35)
			heating = 15
		if(35 to INFINITY)
			heating = 20
	affected_mob.adjust_bodytemperature(heating * TEMPERATURE_DAMAGE_COEFFICIENT * REM * seconds_per_tick)

/datum/reagent/consumable/frostoil
	name = "Frost Oil"
	description = "Особое масло, которое заметно охлаждает тело. Экстрагируется из холодных перцев и слаймов."
	color = "#8BA6E9" // rgb: 139, 166, 233
	taste_description = "мята"
	ph = 13 //HMM! I wonder
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	///40 joules per unit.
	specific_heat = 40
	default_container = /obj/item/reagent_containers/cup/bottle/frostoil

/datum/reagent/consumable/frostoil/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/cooling = 0
	switch(current_cycle)
		if(1 to 15)
			cooling = -10
			if(holder.has_reagent(/datum/reagent/consumable/capsaicin))
				holder.remove_reagent(/datum/reagent/consumable/capsaicin, 5 * REM * seconds_per_tick)
		if(15 to 25)
			cooling = -20
		if(25 to 35)
			cooling = -30
			if(prob(1))
				affected_mob.emote("shiver")
		if(35 to INFINITY)
			cooling = -40
			if(prob(5))
				affected_mob.emote("shiver")
	affected_mob.adjust_bodytemperature(cooling * TEMPERATURE_DAMAGE_COEFFICIENT * REM * seconds_per_tick, 50)

/datum/reagent/consumable/frostoil/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(reac_volume < 1)
		return
	if(isopenturf(exposed_turf))
		var/turf/open/exposed_open_turf = exposed_turf
		exposed_open_turf.MakeSlippery(wet_setting=TURF_WET_ICE, min_wet_time=100, wet_time_to_add=reac_volume SECONDS) // Is less effective in high pressure/high heat capacity environments. More effective in low pressure.
		var/temperature = exposed_open_turf.air.temperature
		var/heat_capacity = exposed_open_turf.air.heat_capacity()
		exposed_open_turf.air.temperature = max(exposed_open_turf.air.temperature - ((temperature - TCMB) * (heat_capacity * reac_volume * specific_heat) / (heat_capacity + reac_volume * specific_heat)) / heat_capacity, TCMB) // Exchanges environment temperature with reagent. Reagent is at 2.7K with a heat capacity of 40J per unit.
	if(reac_volume < 5)
		return
	for(var/mob/living/basic/slime/exposed_slime in exposed_turf)
		exposed_slime.adjustToxLoss(rand(15,30))

/datum/reagent/consumable/condensedcapsaicin
	name = "Condensed Capsaicin"
	description = "Химический агент, используемый для самообороны и в полицейской работе."
	color = "#B31008" // rgb: 179, 16, 8
	taste_description = "обжигающая агония"
	penetrates_skin = NONE
	ph = 7.4
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/cup/bottle/capsaicin

/datum/reagent/consumable/condensedcapsaicin/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	if(!ishuman(exposed_mob))
		return

	var/mob/living/carbon/victim = exposed_mob
	if(methods & (TOUCH|VAPOR|INHALE))
		//check for protection
		//actually handle the pepperspray effects
		if (!victim.is_pepper_proof()) // you need both eye and mouth protection
			if(prob(5))
				victim.emote("scream")
			victim.emote("cry")
			victim.set_eye_blur_if_lower(10 SECONDS)
			victim.adjust_temp_blindness(6 SECONDS)
			victim.set_confusion_if_lower(5 SECONDS)
			victim.Knockdown(3 SECONDS)
			victim.add_movespeed_modifier(/datum/movespeed_modifier/reagent/pepperspray)
			addtimer(CALLBACK(victim, TYPE_PROC_REF(/mob, remove_movespeed_modifier), /datum/movespeed_modifier/reagent/pepperspray), 10 SECONDS)
		victim.update_damage_hud()
	if(methods & INGEST)
		if(!holder.has_reagent(/datum/reagent/consumable/milk))
			if(prob(15))
				to_chat(exposed_mob, span_danger("[pick("Ваша голова пульсирует.", "Ваш рот словно горит.", "У вас кружится голова.")]"))
			if(prob(10))
				victim.set_eye_blur_if_lower(2 SECONDS)
			if(prob(10))
				victim.set_dizzy_if_lower(2 SECONDS)
			if(prob(5))
				victim.vomit(VOMIT_CATEGORY_DEFAULT)
	return ..()

/datum/reagent/consumable/condensedcapsaicin/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(!holder.has_reagent(/datum/reagent/consumable/milk))
		if(SPT_PROB(5, seconds_per_tick))
			affected_mob.visible_message(span_warning("[affected_mob] [pick("dry heaves!","coughs!","splutters!")]"))

/datum/reagent/consumable/salt
	name = "Table Salt"
	description = "Соль, состоящая из хлорида натрия. Обычно используется для приправы пищи."
	color = COLOR_WHITE // rgb: 255,255,255
	taste_description = "соль"
	penetrates_skin = NONE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/saltshaker

/datum/reagent/consumable/salt/expose_turf(turf/exposed_turf, reac_volume) //Creates an umbra-blocking salt pile
	. = ..()
	if(!istype(exposed_turf) || (reac_volume < 1))
		return
	exposed_turf.spawn_unique_cleanable(/obj/effect/decal/cleanable/food/salt)

/datum/reagent/consumable/salt/expose_mob(mob/living/exposed_mob, methods, reac_volume)
	. = ..()
	if(!iscarbon(exposed_mob))
		return
	var/mob/living/carbon/carbies = exposed_mob
	if(!(methods & (PATCH|TOUCH|VAPOR)))
		return
	for(var/datum/wound/iter_wound as anything in carbies.all_wounds)
		iter_wound.on_salt(reac_volume, carbies)

// Salt can help with wounds by soaking up fluid, but undiluted salt will also cause irritation from the loose crystals, and it might soak up the body's water as well!
// A saltwater mixture would be best, but we're making improvised chems here, not real ones.
/datum/wound/proc/on_salt(reac_volume, mob/living/carbon/carbies)
	return

/datum/wound/pierce/bleed/on_salt(reac_volume, mob/living/carbon/carbies)
	adjust_blood_flow(-0.06 * reac_volume, initial_flow * 0.6) // 20u of a salt shacker * 0.1 = -1.6~ blood flow, but is always clamped to, at best, third blood loss from that wound.
	// Crystal irritation worsening recovery.
	gauzed_clot_rate *= 0.65
	to_chat(carbies, span_notice("Крупинки соли просачиваются внутрь и прилипают к [LOWER_TEXT(declent_ru(DATIVE))], болезненно раздражая кожу, но впитывая большую часть крови."))

/datum/wound/slash/flesh/on_salt(reac_volume, mob/living/carbon/carbies)
	adjust_blood_flow(-0.1 * reac_volume, initial_flow * 0.5) // 20u of a salt shacker * 0.1 = -2~ blood flow, but is always clamped to, at best, halve blood loss from that wound.
	// Crystal irritation worsening recovery.
	clot_rate *= 0.75
	to_chat(carbies, span_notice("Крупинки соли просачиваются внутрь и прилипают к [LOWER_TEXT(declent_ru(DATIVE))], болезненно раздражая кожу, но впитывая большую часть крови."))

/datum/wound/burn/flesh/on_salt(reac_volume)
	// Slightly sanitizes and disinfects, but also increases infestation rate (some bacteria are aided by salt), and decreases flesh healing (can damage the skin from moisture absorption)
	sanitization += VALUE_PER(0.4, 30) * reac_volume
	infestation -= max(VALUE_PER(0.3, 30) * reac_volume, 0)
	infestation_rate += VALUE_PER(0.12, 30) * reac_volume
	flesh_healing -= max(VALUE_PER(5, 30) * reac_volume, 0)
	to_chat(victim, span_notice("Крупинки соли просачиваются внутрь и прилипают к [LOWER_TEXT(declent_ru(DATIVE))], болезненно раздражая кожу! Спустя несколько мгновений становится немного лучше."))

/datum/reagent/consumable/blackpepper
	name = "Black Pepper"
	description = "Порошок, полученный из перцевых зёрен. *АПЧХИ*"
	// без цвета (т.е. чёрный)
	taste_description = "перец"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/peppermill

/datum/reagent/consumable/coco
	name = "Coco Powder"
	description = "Жирная, горькая паста, изготовленная из какао-бобов."
	nutriment_factor = 5
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "горечь"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/garlic //NOTE: having garlic in your blood stops vampires from biting you.
	name = "Garlic Juice"
	description = "Толчёный чеснок. Шеф-повары обожают его, но он может заставить вас плохо пахнуть."
	color = "#FEFEFE"
	taste_description = "чеснок"
	metabolization_rate = 0.15 * REAGENTS_METABOLISM
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	added_traits = list(TRAIT_GARLIC_BREATH)

/datum/reagent/consumable/garlic/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(isvampire(affected_mob)) //incapacitating but not lethal. Unfortunately, vampires cannot vomit.
		if(SPT_PROB(min((current_cycle-1)/2, 12.5), seconds_per_tick))
			if(HAS_TRAIT(affected_mob, TRAIT_ANOSMIA))
				to_chat(affected_mob, span_danger("Вы чувствуете, что что-то не так, ваши силы покидают вас! Вы с трудом соображаете..."))
			else
				to_chat(affected_mob, span_danger("Вы не можете выбить запах чеснока из носа! Вы с трудом соображаете..."))
			affected_mob.Paralyze(10)
			affected_mob.set_jitter_if_lower(20 SECONDS)
	else
		var/obj/item/organ/liver/liver = affected_mob.get_organ_slot(ORGAN_SLOT_LIVER)
		if(liver && HAS_TRAIT(liver, TRAIT_CULINARY_METABOLISM))
			if(SPT_PROB(10, seconds_per_tick)) //stays in the system much longer than sprinkles/banana juice, so heals slower to partially compensate
				if(affected_mob.heal_bodypart_damage(brute = 1 * REM * seconds_per_tick, burn = 1 * REM * seconds_per_tick, updating_health = FALSE))
					return UPDATE_MOB_HEALTH

/datum/reagent/consumable/tearjuice
	name = "Tear Juice"
	description = "Ослепляющее вещество, извлечённое из определённых видов лука."
	color = "#c0c9a0"
	taste_description = "горечь"
	ph = 5

/datum/reagent/consumable/tearjuice/expose_mob(mob/living/exposed_mob, methods = INGEST, reac_volume)
	. = ..()
	if(!ishuman(exposed_mob))
		return

	var/mob/living/carbon/victim = exposed_mob
	if(methods & (TOUCH | VAPOR | INHALE))
		var/tear_proof = victim.is_eyes_covered()
		if (!tear_proof)
			to_chat(exposed_mob, span_warning("Ваши глаза жалят!"))
			victim.emote("cry")
			victim.adjust_eye_blur(6 SECONDS)

/datum/reagent/consumable/sprinkles
	name = "Sprinkles"
	description = "Разноцветные маленькие кусочки сахара, обычно встречающиеся на пончиках. Обожаются копами."
	color = COLOR_MAGENTA // rgb: 255, 0, 255
	taste_description = "детская беззаботность"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/sprinkles/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/obj/item/organ/liver/liver = affected_mob.get_organ_slot(ORGAN_SLOT_LIVER)
	if(liver && HAS_TRAIT(liver, TRAIT_LAW_ENFORCEMENT_METABOLISM))
		if(affected_mob.heal_bodypart_damage(brute = 1 * REM * seconds_per_tick, burn = 1 * REM * seconds_per_tick, updating_health = FALSE))
			return UPDATE_MOB_HEALTH

/datum/reagent/consumable/enzyme
	name = "Universal Enzyme"
	description = "Универсальный фермент, используемый при приготовлении определённых химикатов и продуктов питания."
	color = "#365E30" // rgb: 54, 94, 48
	taste_description = "сладость"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/enzyme

/datum/reagent/consumable/dry_ramen
	name = "Dry Ramen"
	description = "Еда космической эры, начиная с 25 августа 1958 года. Содержит сухую лапшу, овощи и химикаты, которые закипают при контакте с водой."
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "сухая и дешёвая лапша"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/cup/glass/dry_ramen

/datum/reagent/consumable/hot_ramen
	name = "Hot Ramen"
	description = "Лапша варёная, вкусы искусственные, прямо как назад в школе."
	nutriment_factor = 5
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "мокрая и дешёвая лапша"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/cup/glass/dry_ramen

/datum/reagent/consumable/nutraslop
	name = "Nutraslop"
	description = "Смесь остатков тюремной еды, подававшейся в предыдущие дни."
	nutriment_factor = 5
	color = "#3E4A00" // rgb: 62, 74, 0
	taste_description = "ваше заключение"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/hot_ramen/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_bodytemperature(10 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * seconds_per_tick, 0, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/hell_ramen
	name = "Hell Ramen"
	description = "Лапша варёная, вкусы искусственные, прямо как назад в школе."
	nutriment_factor = 5
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "мокрая и дешёвая лапша в огне"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/hell_ramen/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_bodytemperature(10 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * seconds_per_tick)

/datum/reagent/consumable/flour
	name = "Flour"
	description = "Это то, чем вы натираете себя, чтобы притвориться призраком."
	color = COLOR_WHITE // rgb: 0, 0, 0
	taste_description = "меловая пшеница"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_AFFECTS_WOUNDS
	default_container = /obj/item/reagent_containers/condiment/flour

/datum/reagent/consumable/flour/expose_mob(mob/living/exposed_mob, methods, reac_volume)
	. = ..()
	if(!iscarbon(exposed_mob))
		return
	var/mob/living/carbon/carbies = exposed_mob
	if(!(methods & (PATCH|TOUCH|VAPOR)))
		return
	for(var/datum/wound/iter_wound as anything in carbies.all_wounds)
		iter_wound.on_flour(reac_volume, carbies)

/datum/wound/proc/on_flour(reac_volume, mob/living/carbon/carbies)
	return

/datum/wound/pierce/bleed/on_flour(reac_volume, mob/living/carbon/carbies)
	adjust_blood_flow(-0.015 * reac_volume) // 30u of a flour sack * 0.015 = -0.45~ blood flow, prettay good
	to_chat(carbies, span_notice("Мука просачивается в [LOWER_TEXT(declent_ru(DATIVE))], болезненно высушивая её и впитывая часть крови."))
	// When some nerd adds infection for wounds, make this increase the infection

/datum/wound/slash/flesh/on_flour(reac_volume, mob/living/carbon/carbies)
	adjust_blood_flow(-0.04 * reac_volume) // 30u of a flour sack * 0.04 = -1.25~ blood flow, pretty good!
	to_chat(carbies, span_notice("Мука просачивается в [LOWER_TEXT(declent_ru(DATIVE))], болезненно высушивая часть её и впитывая немного крови."))
	// When some nerd adds infection for wounds, make this increase the infection

// Don't pour flour onto burn wounds, it increases infection risk! Very unwise. Backed up by REAL info from REAL professionals.
// https://www.reuters.com/article/uk-factcheck-flour-burn-idUSKCN26F2N3
/datum/wound/burn/flesh/on_flour(reac_volume)
	to_chat(victim, span_notice("Мука просачивается в [LOWER_TEXT(declent_ru(DATIVE))], пронзая вас интенсивной болью! Вероятно, это была не лучшая идея..."))
	sanitization -= min(0, 1)
	infestation += 0.2
	return

/datum/reagent/consumable/flour/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(isspaceturf(exposed_turf))
		return

	var/obj/effect/decal/cleanable/food/flour/flour_decal = exposed_turf.spawn_unique_cleanable(/obj/effect/decal/cleanable/food/flour)
	if(flour_decal)
		flour_decal.reagents.add_reagent(/datum/reagent/consumable/flour, reac_volume)

/datum/reagent/consumable/cherryjelly
	name = "Cherry Jelly"
	description = "Абсолютно лучшее. Наносится только на продукты с превосходной lateral симметрией."
	nutriment_factor = 10
	color = "#801E28" // rgb: 128, 30, 40
	taste_description = "вишня"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/cherryjelly

/datum/reagent/consumable/bluecherryjelly
	name = "Blue Cherry Jelly"
	description = "Синий и более вкусный вид вишнёвого желе."
	color = "#00F0FF"
	taste_description = "синяя вишня"

/datum/reagent/consumable/rice
	name = "Rice"
	description = "крошечные питательные зёрна"
	nutriment_factor = 3
	color = COLOR_WHITE // rgb: 0, 0, 0
	taste_description = "рис"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/rice

/datum/reagent/consumable/rice_flour
	name = "Rice Flour"
	description = "Мука, смешанная с рисом"
	color = COLOR_WHITE // rgb: 0, 0, 0
	taste_description = "меловая пшеница с рисом"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/vanilla
	name = "Vanilla Powder"
	description = "Жирная, горькая паста, изготовленная из стручков ванили."
	nutriment_factor = 5
	color = "#FFFACD"
	taste_description = "ваниль"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/eggyolk
	name = "Egg Yolk"
	description = "Полон белка."
	nutriment_factor = 8
	color = "#FFB500"
	taste_description = "яйцо"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/eggwhite
	name = "Egg White"
	description = "Полон ещё большего количества белка."
	nutriment_factor = 4
	color = "#fffdf7"
	taste_description = "пресное яйцо"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/corn_starch
	name = "Corn Starch"
	description = "Скользкий раствор."
	color = "#DBCE95"
	taste_description = "слизь"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_AFFECTS_WOUNDS

// Starch has similar absorbing properties to flour (Stronger here because it's rarer)
/datum/reagent/consumable/corn_starch/expose_mob(mob/living/exposed_mob, methods, reac_volume)
	. = ..()
	if(!iscarbon(exposed_mob))
		return
	var/mob/living/carbon/carbies = exposed_mob
	if(!(methods & (PATCH|TOUCH|VAPOR)))
		return
	for(var/datum/wound/iter_wound as anything in carbies.all_wounds)
		iter_wound.on_starch(reac_volume, carbies)

/datum/wound/proc/on_starch(reac_volume, mob/living/carbon/carbies)
	return

/datum/wound/pierce/bleed/on_starch(reac_volume, mob/living/carbon/carbies)
	adjust_blood_flow(-0.03 * reac_volume)
	to_chat(carbies, span_notice("Слизистый крахмал просачивается в [LOWER_TEXT(declent_ru(DATIVE))], болезненно высушивая часть её и впитывая немного крови."))
	// When some nerd adds infection for wounds, make this increase the infection
	return

/datum/wound/slash/flesh/on_starch(reac_volume, mob/living/carbon/carbies)
	adjust_blood_flow(-0.06 * reac_volume)
	to_chat(carbies, span_notice("Слизистый крахмал просачивается в [LOWER_TEXT(declent_ru(DATIVE))], болезненно высушивая её и впитывая часть крови."))
	// When some nerd adds infection for wounds, make this increase the infection
	return

/datum/wound/burn/flesh/on_starch(reac_volume, mob/living/carbon/carbies)
	to_chat(carbies, span_notice("Слизистый крахмал просачивается в [LOWER_TEXT(declent_ru(DATIVE))], пронзая вас интенсивной болью! Вероятно, это была не лучшая идея..."))
	sanitization -= min(0, 0.5)
	infestation += 0.1
	return

/datum/reagent/consumable/corn_syrup
	name = "Corn Syrup"
	description = "Распадается на сахар."
	color = "#DBCE95"
	metabolization_rate = 3 * REAGENTS_METABOLISM
	taste_description = "сладкая слизь"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/corn_syrup/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	holder.add_reagent(/datum/reagent/consumable/sugar, 3 * REM * seconds_per_tick)

/datum/reagent/consumable/honey
	name = "Honey"
	description = "Сладкий-сладкий мёд, который распадается на сахар. Обладает антибактериальными и естественными целебными свойствами."
	color = "#d3a308"
	nutriment_factor = 15
	metabolization_rate = 1 * REAGENTS_METABOLISM
	taste_description = "сладость"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/honey

// On the other hand, honey has been known to carry pollen with it rarely. Can be used to take in a lot of plant qualities all at once, or harm the plant.
/datum/reagent/consumable/honey/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	if(!isnull(mytray.myseed) && prob(20))
		mytray.pollinate(range = 1)
		return

	mytray.adjust_weedlevel(rand(1, 2))
	mytray.adjust_pestlevel(rand(1, 2))

/datum/reagent/consumable/honey/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	holder.add_reagent(/datum/reagent/consumable/sugar, 3 * REM * seconds_per_tick)
	var/need_mob_update
	if(SPT_PROB(33, seconds_per_tick))
		need_mob_update = affected_mob.adjustBruteLoss(-1, updating_health = FALSE, required_bodytype = affected_bodytype)
		need_mob_update += affected_mob.adjustFireLoss(-1, updating_health = FALSE, required_bodytype = affected_bodytype)
		need_mob_update += affected_mob.adjustOxyLoss(-1, updating_health = FALSE, required_biotype = affected_biotype)
		need_mob_update += affected_mob.adjustToxLoss(-1, updating_health = FALSE, required_biotype = affected_biotype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/honey/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	. = ..()
	if(!iscarbon(exposed_mob) || !(methods & (TOUCH|VAPOR|PATCH)))
		return

	var/mob/living/carbon/exposed_carbon = exposed_mob
	for(var/datum/surgery/surgery as anything in exposed_carbon.surgeries)
		surgery.speed_modifier = min(0.4, surgery.speed_modifier)

/datum/reagent/consumable/mayonnaise
	name = "Mayonnaise"
	description = "Белая и маслянистая смесь смешанных яичных желтков."
	color = "#DFDFDF"
	taste_description = "майонез"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/mayonnaise

/datum/reagent/consumable/mold // yeah, ok, togopal, I guess you could call that a condiment
	name = "Mold"
	description = "Эта приправа заставит любую еду выйти за рамки привычного. Или ваш желудок."
	color ="#708a88"
	taste_description = "прогорклый грибок"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/moltobeso
	name = "Molt'Obeso" //pardon my Italian
	description = "Сконцентрированное чревоугодие."
	color = "#f8fc36"
	taste_description = "чревоугодие"
	taste_mult = 0.3
	nutriment_factor = 0 //the essence of this sauce is to stimulate hunger and improve the absorption of calories from food eaten
	metabolization_rate = 0.025 * REAGENTS_METABOLISM
	metabolized_traits = list(TRAIT_GLUTTON)
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/moltobeso/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	for(var/datum/reagent/consumable/food in affected_mob.reagents.reagent_list)
		if(food == src)
			continue
		var/food_factor = food.get_nutriment_factor(affected_mob)
		if(food_factor <= 0)
			continue
		affected_mob.adjust_nutrition(food_factor * REM * seconds_per_tick)

/datum/reagent/consumable/eggrot
	name = "Rotten Eggyolk"
	description = "Пахнет абсолютно отвратительно."
	color ="#708a88"
	taste_description = "тухлые яйца"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/nutriment/stabilized
	name = "Stabilized Nutriment"
	description = "Биоинженерная белково-нутриентная структура, разработанная для разложения при высокой насыщенности. Простыми словами, он не позволит вам растолстеть."
	nutriment_factor = 15
	color = "#664330" // rgb: 102, 67, 48
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/nutriment/stabilized/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.nutrition > NUTRITION_LEVEL_FULL - 25)
		affected_mob.adjust_nutrition(-3 * REM * get_nutriment_factor(affected_mob) * seconds_per_tick)

////Lavaland Flora Reagents////


/datum/reagent/consumable/entpoly
	name = "Entropic Polypnium"
	description = "Ихор, полученный из определённого гриба, сулит неприятности."
	color = "#1d043d"
	taste_description = "горький гриб"
	ph = 12
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/entpoly/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	if(current_cycle > 10)
		affected_mob.Unconscious(40 * REM * seconds_per_tick, FALSE)
	if(SPT_PROB(10, seconds_per_tick))
		affected_mob.losebreath += 4
		affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2*REM, 150, affected_biotype)
		affected_mob.adjustToxLoss(3*REM, updating_health = FALSE, required_biotype = affected_biotype)
		affected_mob.adjustStaminaLoss(10*REM, updating_stamina = FALSE, required_biotype = affected_biotype)
		affected_mob.set_eye_blur_if_lower(10 SECONDS)
		need_mob_update = TRUE
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/tinlux
	name = "Tinea Luxor"
	description = "Стимулирующий ихор, который вызывает рост люминесцентных грибов на коже."
	color = "#b5a213"
	taste_description = "покалывающий гриб"
	ph = 11.2
	self_consuming = TRUE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_DEAD_PROCESS

/datum/reagent/consumable/tinlux/expose_mob(mob/living/exposed_mob, methods = TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if(!exposed_mob.reagents) // they won't process the reagent, but still benefit from its effects for a duration.
		var/amount = round(reac_volume * clamp(1 - touch_protection, 0, 1))
		var/duration = (amount / metabolization_rate) * SSmobs.wait
		if(duration > 1 SECONDS)
			exposed_mob.adjust_timed_status_effect(duration, /datum/status_effect/tinlux_light)

/datum/reagent/consumable/tinlux/on_mob_add(mob/living/living_mob)
	. = ..()
	living_mob.apply_status_effect(/datum/status_effect/tinlux_light) //infinite duration

/datum/reagent/consumable/tinlux/on_mob_delete(mob/living/living_mob)
	. = ..()
	living_mob.remove_status_effect(/datum/status_effect/tinlux_light)

/datum/reagent/consumable/vitfro
	name = "Vitrium Froth"
	description = "Шипучая паста, которая заживляет раны кожи."
	color = "#d3a308"
	nutriment_factor = 3
	taste_description = "фруктовый гриб"
	ph = 10.4
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/vitfro/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	if(SPT_PROB(55, seconds_per_tick))
		need_mob_update = affected_mob.adjustBruteLoss(-1 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
		need_mob_update += affected_mob.adjustFireLoss(-1 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/liquidelectricity
	name = "Liquid Electricity"
	description = "Кровь Эфириалов и вещество, которое поддерживает их жизнь. Отлично для них, ужасно для всех остальных."
	nutriment_factor = 5
	color = "#97ee63"
	taste_description = "чистое электричество"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/liquidelectricity/enriched
	name = "Enriched Liquid Electricity"

/datum/reagent/consumable/liquidelectricity/enriched/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume) //can't be on life because of the way blood works.
	. = ..()
	if(!(methods & (INGEST|INJECT|PATCH|INHALE)) || !iscarbon(exposed_mob))
		return

	var/mob/living/carbon/exposed_carbon = exposed_mob
	var/obj/item/organ/stomach/ethereal/stomach = exposed_carbon.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(istype(stomach))
		stomach.adjust_charge(reac_volume * 30 * ETHEREAL_DISCHARGE_RATE)

/datum/reagent/consumable/liquidelectricity/enriched/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(isethereal(affected_mob))
		affected_mob.blood_volume += 1 * seconds_per_tick
	else if(SPT_PROB(10, seconds_per_tick)) //lmao at the newbs who eat energy bars
		affected_mob.electrocute_act(rand(5,10), "Liquid Electricity in their body", 1, SHOCK_NOGLOVES) //the shock is coming from inside the house
		playsound(affected_mob, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/datum/reagent/consumable/astrotame
	name = "Astrotame"
	description = "Искусственный подсластитель космической эры."
	nutriment_factor = 0
	metabolization_rate = 2 * REAGENTS_METABOLISM
	color = COLOR_WHITE // rgb: 255, 255, 255
	taste_mult = 8
	taste_description = "сладость"
	overdose_threshold = 17
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/astrotame/overdose_process(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.disgust < 80)
		affected_mob.adjust_disgust(10 * REM * seconds_per_tick)

/datum/reagent/consumable/secretsauce
	name = "Secret Sauce"
	description = "Что бы это могло быть?"
	nutriment_factor = 2
	color = "#792300"
	taste_description = "неописуемое"
	quality = FOOD_AMAZING
	taste_mult = 100
	ph = 6.1

/datum/reagent/consumable/nutriment/peptides
	name = "Peptides"
	description = "Эти восстанавливающие пептиды не только ускоряют заживление ран, но и питательны!"
	color = "#BBD4D9"
	taste_description = "мятная глазурь"
	nutriment_factor = 10 // 33% less than nutriment to reduce weight gain
	brute_heal = 3
	burn_heal = 1
	inverse_chem = /datum/reagent/peptides_failed//should be impossible, but it's so it appears in the chemical lookup gui
	inverse_chem_val = 0.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/caramel
	name = "Caramel"
	description = "Кто бы мог подумать, что нагретый сахар может быть таким вкусным?"
	nutriment_factor = 10
	color = "#D98736"
	taste_mult = 2
	taste_description = "карамель"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/caramel/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	. = ..()
	if(methods & INGEST)
		exposed_mob.check_allergic_reaction(SUGAR, chance = reac_volume * 10, histamine_add = min(10, reac_volume * 2))

/datum/reagent/consumable/char
	name = "Char"
	description = "Сущность гриля. Обладает странными свойствами при передозировке."
	nutriment_factor = 5
	color = "#C8C8C8"
	taste_mult = 6
	taste_description = "дым"
	overdose_threshold = 15
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/char/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(13, seconds_per_tick))
		affected_mob.say(pick_list_replacements(BOOMER_FILE, "boomer"), forced = /datum/reagent/consumable/char)

/datum/reagent/consumable/bbqsauce
	name = "BBQ Sauce"
	description = "Сладкий, дымный, пикантный и проникает повсюду. Идеален для гриля."
	nutriment_factor = 5
	color = "#78280A" // rgb: 120 40, 10
	taste_mult = 2.5 //сахар 1.5, капсаицин 1.5, так что хорошая золотая середина.
	taste_description = "дымная сладость"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/bbqsauce

/datum/reagent/consumable/chocolatepudding
	name = "Chocolate Pudding"
	description = "Отличный десерт для любителей шоколада."
	color = COLOR_MAROON
	quality = DRINK_VERYGOOD
	nutriment_factor = 4
	taste_description = "сладкий шоколад"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_EASY

/datum/glass_style/drinking_glass/chocolatepudding
	required_drink_type = /datum/reagent/consumable/chocolatepudding
	name = "chocolate pudding"
	desc = "Вкусно."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "chocolatepudding"

/datum/reagent/consumable/vanillapudding
	name = "Vanilla Pudding"
	description = "Отличный десерт для любителей ванили."
	color = "#FAFAD2"
	quality = DRINK_VERYGOOD
	nutriment_factor = 4
	taste_description = "сладкая ваниль"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/vanillapudding
	required_drink_type = /datum/reagent/consumable/vanillapudding
	name = "vanilla pudding"
	desc = "Вкусно."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "vanillapudding"

/datum/reagent/consumable/laughsyrup
	name = "Laughin' Syrup"
	description = "Продукт отжима Смеющегося Гороха. Газированный и, кажется, меняет вкус в зависимости от того, с чем используется!"
	color = "#803280"
	nutriment_factor = 5
	taste_mult = 2
	taste_description = "газированная сладость"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/gravy
	name = "Gravy"
	description = "Смесь муки, воды и соков приготовленного мяса."
	taste_description = "грави"
	color = "#623301"
	taste_mult = 1.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/pancakebatter
	name = "Pancake Batter"
	description = "Очень молочное тесто."
	taste_description = "молочное тесто"
	color = "#fccc98"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/korta_flour
	name = "Korta Flour"
	description = "Крупномолотая, перечная мука, изготовленная из скорлупы орехов корты."
	taste_description = "землистая жгучесть"
	color = "#EEC39A"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/korta_milk
	name = "Korta Milk"
	description = "Молочная жидкость, получаемая путём измельчения сердцевины ореха корты."
	taste_description = "сладкое молоко"
	color = COLOR_WHITE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/korta_nectar
	name = "Korta Nectar"
	description = "Сладкий, сахарный сироп, изготовленный из измельчённых сладких орехов корты."
	color = "#d3a308"
	nutriment_factor = 5
	metabolization_rate = 1 * REAGENTS_METABOLISM
	taste_description = "перечная сладость"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/whipped_cream
	name = "Whipped Cream"
	description = "Белый пушистый крем, приготовленный путём взбивания сливок на высокой скорости."
	color = "#efeff0"
	nutriment_factor = 4
	taste_description = "пушистые сладкие сливки"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/peanut_butter
	name = "Peanut Butter"
	description = "Насыренная, кремовая паста, производимая путём измельчения арахиса."
	taste_description = "арахис"
	color = "#D9A066"
	nutriment_factor = 15
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/peanut_butter

/datum/reagent/consumable/peanut_butter/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired) //ET loves peanut butter
	. = ..()
	if(isabductor(affected_mob))
		affected_mob.add_mood_event("ET_pieces", /datum/mood_event/et_pieces, name)
		affected_mob.set_drugginess(30 SECONDS * REM * seconds_per_tick)

/datum/reagent/consumable/vinegar
	name = "Vinegar"
	description = "Полезен для маринования или добавления на чипсы."
	taste_description = "кислота"
	color = "#661F1E"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/vinegar

/datum/reagent/consumable/cornmeal
	name = "Cornmeal"
	description = "Молотая кукурузная мука для приготовления блюд из кукурузы."
	taste_description = "сырая кукурузная мука"
	color = "#ebca85"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/cornmeal

/datum/reagent/consumable/yoghurt
	name = "Yoghurt"
	description = "Кремовый натуральный йогурт с применением как в еде, так и в напитках."
	taste_description = "йогурт"
	color = "#efeff0"
	nutriment_factor = 2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/yoghurt

/datum/reagent/consumable/cornmeal_batter
	name = "Cornmeal Batter"
	description = "Яичная, молочная, кукурузная смесь, которая не очень хороша в сыром виде."
	taste_description = "сырое тесто"
	color = "#ebca85"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/olivepaste
	name = "Olive Paste"
	description = "Кашицеобразная масса из мелко молотых оливок."
	taste_description = "кашицеобразные оливки"
	color = "#adcf77"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/creamer
	name = "Coffee Creamer"
	description = "Сухое молоко для дешёвого кофе. Как восхитительно."
	taste_description = "молоко"
	color = "#efeff0"
	nutriment_factor = 1.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/creamer

/datum/reagent/consumable/mintextract
	name = "Mint Extract"
	description = "Полезен для работы с нежелательными клиентами."
	color = "#CF3600" // rgb: 207, 54, 0
	taste_description = "мята"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/mintextract/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(HAS_TRAIT(affected_mob, TRAIT_FAT))
		affected_mob.investigate_log("был разорван употреблением [declent_ru(GENITIVE)] при ожирении.", INVESTIGATE_DEATHS)
		affected_mob.inflate_gib()

/datum/reagent/consumable/worcestershire
	name = "Worcestershire Sauce"
	description = "Кстати, это произносится \"Вустерширский\" соус."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#572b26"
	taste_description = "сладкая рыба"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/worcestershire

/datum/reagent/consumable/red_bay
	name = "Red Bay Seasoning"
	description = "Секретная смесь трав и специй, которая хорошо сочетается с чем угодно - по мнению марсиан, по крайней мере."
	color = "#8E4C00"
	taste_description = "специи"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/red_bay

/datum/reagent/consumable/curry_powder
	name = "Curry Powder"
	description = "Одна из самых распространённых специй человечества. Обычно используется для приготовления карри."
	color = "#F6C800"
	taste_description = "сухое карри"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/curry_powder

/datum/reagent/consumable/dashi_concentrate
	name = "Dashi Concentrate"
	description = "Концентрированная форма даси. Проварите с водой в соотношении 1:8, чтобы получить вкусный бульон даси."
	color = "#372926"
	taste_description = "экстремальный умами"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/dashi_concentrate

/datum/reagent/consumable/martian_batter
	name = "Martian Batter"
	description = "Густое тесто, приготовленное с даси и мукой, используется для приготовления таких блюд, как окономияки и такояки."
	color = "#D49D26"
	taste_description = "тесто умами"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/grounding_solution
	name = "Grounding Solution"
	description = "Пищевой ионный раствор, предназначенный для нейтрализации загадочного «жидкого электричества», распространённого в пище со Спрута, образуя безвредную соль при контакте."
	color = "#efeff0"
	taste_description = "металлическая соль"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
