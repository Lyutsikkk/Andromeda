//The Medical Kiosk is designed to act as a low access alernative to  a medical analyzer, and doesn't require breaking into medical. Self Diagnose at your heart's content!
//For a fee that is. Comes in 4 flavors of medical scan.

/// Shows if the machine is being used for a general scan.
#define KIOSK_SCANNING_GENERAL (1<<0)
/// Shows if the machine is being used for a disease scan.
#define KIOSK_SCANNING_SYMPTOMS (1<<1)
/// Shows if the machine is being used for a radiation/brain trauma scan.
#define KIOSK_SCANNING_NEURORAD (1<<2)
/// Shows if the machine is being used for a reagent scan.
#define KIOSK_SCANNING_REAGENTS (1<<3)



/obj/machinery/medical_kiosk
	name = "medical kiosk"
	desc = "Автономный медицинский киоск, который может предоставить широкий спектр медицинского анализа для диагностики."
	icon = 'icons/obj/machines/medical_kiosk.dmi'
	icon_state = "kiosk"
	base_icon_state = "kiosk"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/medical_kiosk
	payment_department = ACCOUNT_MED
	var/obj/item/scanner_wand
	/// How much it costs to use the kiosk by default.
	var/default_price = 15
	/// Makes the TGUI display gibberish and/or incorrect/erratic information.
	var/pandemonium = FALSE //AKA: Emag mode.

	/// Shows whether the kiosk is being used to scan someone and what it's being used for.
	var/scan_active = NONE

	/// Do we have someone paying to use this?
	var/paying_customer = FALSE //Ticked yes if passing inuse()

	/// Who's paying?
	var/datum/weakref/paying_ref //The person using the console in each instance. Used for paying for the kiosk.
	/// Who's getting scanned?
	var/datum/weakref/patient_ref //If scanning someone else, this will be the target.

/obj/machinery/medical_kiosk/Initialize(mapload) //loaded subtype for mapping use
	. = ..()
	AddComponent(/datum/component/payment, get_cost(), SSeconomy.get_dep_account(ACCOUNT_MED), PAYMENT_FRIENDLY)
	register_context()
	scanner_wand = new/obj/item/scanner_wand(src)

/obj/machinery/medical_kiosk/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	var/screentip_change = FALSE

	if(!held_item && scanner_wand)
		context[SCREENTIP_CONTEXT_RMB] = "Поднять сканирующую палочку"
		return screentip_change = TRUE

	if(istype(held_item) && held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = anchored ? "Открепить" : "Закрепить"
		return screentip_change = TRUE
	if(istype(held_item) && held_item.tool_behaviour == TOOL_CROWBAR && panel_open)
		context[SCREENTIP_CONTEXT_LMB] = "Разобрать"
		return screentip_change = TRUE
	if(istype(held_item) && held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = panel_open ? "Закрыть панель" : "Открыть панель"
		return screentip_change = TRUE
	if(istype(held_item, /obj/item/scanner_wand))
		context[SCREENTIP_CONTEXT_LMB] = "Вернуть сканирующую палочку"
		return screentip_change = TRUE

/obj/machinery/medical_kiosk/proc/inuse()  //Verifies that the user can use the interface, followed by showing medical information.
	var/mob/living/carbon/human/paying = paying_ref?.resolve()
	if(!paying)
		paying_ref = null
		return

	var/obj/item/card/id/card = paying.get_idcard(TRUE)
	if(card?.registered_account?.account_job?.paycheck_department == payment_department)
		use_energy(active_power_usage)
		paying_customer = TRUE
		say("Здравствуйте, уважаемый медицинский персонал!")
		return
	var/bonus_fee = pandemonium ? rand(10,30) : 0
	if(attempt_charge(src, paying, bonus_fee) & COMPONENT_OBJ_CANCEL_CHARGE )
		return
	use_energy(active_power_usage)
	paying_customer = TRUE
	icon_state = "[base_icon_state]_active"
	say("Спасибо за ваше покровительство!")
	return

/obj/machinery/medical_kiosk/proc/clearScans() //Called it enough times to be it's own proc
	scan_active = NONE
	update_appearance()
	return

/obj/machinery/medical_kiosk/update_icon_state()
	if(panel_open)
		icon_state = "[base_icon_state]_open"
		return ..()
	if(!is_operational)
		icon_state = "[base_icon_state]_off"
		return ..()
	icon_state = "[base_icon_state][scan_active ? "_active" : null]"
	return ..()

/obj/machinery/medical_kiosk/wrench_act(mob/living/user, obj/item/tool) //Allows for wrenching/unwrenching the machine.
	..()
	default_unfasten_wrench(user, tool, time = 0.1 SECONDS)
	return ITEM_INTERACT_SUCCESS

///Returns the active cost of the board
/obj/machinery/medical_kiosk/proc/get_cost()
	PRIVATE_PROC(TRUE)

	var/obj/item/circuitboard/machine/medical_kiosk/board = circuit

	return board.custom_cost

/obj/machinery/medical_kiosk/attackby(obj/item/O, mob/user, list/modifiers, list/attack_modifiers)
	if(default_deconstruction_screwdriver(user, "[base_icon_state]_open", "[base_icon_state]_off", O))
		return
	else if(default_deconstruction_crowbar(O))
		return

	if(istype(O, /obj/item/scanner_wand))
		var/obj/item/scanner_wand/W = O
		if(scanner_wand)
			balloon_alert(user, "уже есть палочка!")
			return
		if(HAS_TRAIT(O, TRAIT_NODROP) || !user.transferItemToLoc(O, src))
			balloon_alert(user, "прилипла к руке!")
			return
		user.visible_message(span_notice("[user] защелкивает [O] на [declent_ru(NOMINATIVE)]!"))
		balloon_alert(user, "палочка возвращена")
		//Это позволит сканеру вернуть переменную selected_target сканирующей палочки и присвоить ее переменной altPatient
		if(W.selected_target)
			var/datum/weakref/target_ref = WEAKREF(W.return_patient())
			if(patient_ref != target_ref)
				clearScans()
			patient_ref = target_ref
			user.visible_message(span_notice("[W.return_patient()] установлен как текущий пациент."))
			W.selected_target = null
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)
		scanner_wand = O
		return
	return ..()

/obj/machinery/medical_kiosk/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!ishuman(user) || !user.can_perform_action(src))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!scanner_wand)
		balloon_alert(user, "нет сканирующей палочки!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!user.put_in_hands(scanner_wand))
		balloon_alert(user, "сканирующая палочка упала!")
		scanner_wand = null
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	user.visible_message(span_notice("[user] отцепляет [scanner_wand] от [declent_ru(NOMINATIVE)]."))
	balloon_alert(user, "палочка извлечена")
	playsound(src, 'sound/machines/click.ogg', 60, TRUE)
	scanner_wand = null
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/medical_kiosk/Destroy()
	qdel(scanner_wand)
	return ..()

/obj/machinery/medical_kiosk/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(obj_flags & EMAGGED)
		return
	if(user)
		if (emag_card)
			user.visible_message(span_warning("[user] проводит подозрительной картой рядом с биометрическим сканером [declent_ru(NOMINATIVE)]!"))
		balloon_alert(user, "сенсоры перегружены")
	obj_flags |= EMAGGED
	var/obj/item/circuitboard/board = circuit
	board.obj_flags |= EMAGGED //Отражает статус эмэга на плате.
	pandemonium = TRUE
	return TRUE

/obj/machinery/medical_kiosk/examine(mob/user)
	. = ..()
	if(scanner_wand == null)
		. += span_notice("[declent_ru(NOMINATIVE)] отсутствует сканер.")
	else
		. += span_notice("[declent_ru(NOMINATIVE)] имеет сканер, закрепленный сбоку. Правый клик чтобы извлечь.")

/obj/machinery/medical_kiosk/ui_interact(mob/user, datum/tgui/ui)
	var/patient_distance = 0
	if(!ishuman(user))
		to_chat(user, span_warning("[declent_ru(NOMINATIVE)] не может взаимодействовать с не гуманоидами!"))
		if (ui)
			ui.close()
		return
	var/mob/living/carbon/human/patient = patient_ref?.resolve()
	patient_distance = get_dist(src.loc, patient)
	if(patient == null)
		say("Сканер сброшен.")
		patient_ref = WEAKREF(user)
	else if(patient_distance>5)
		patient_ref = null
		say("Пациент вне зоны доступа. Сброс биометрии.")
		clearScans()
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MedicalKiosk", name)
		ui.open()
		icon_state = "[base_icon_state]_active"
		var/mob/living/carbon/human/paying = user
		paying_ref = WEAKREF(paying)

/obj/machinery/medical_kiosk/ui_data(mob/living/carbon/human/user)
	var/mob/living/carbon/human/patient = patient_ref?.resolve()
	var/list/data = list()
	if(!patient)
		return
	var/patient_name = patient.name
	var/patient_status = "Живой."
	var/max_health = patient.maxHealth
	var/total_health = patient.health
	var/brute_loss = patient.getBruteLoss()
	var/fire_loss = patient.getFireLoss()
	var/tox_loss = patient.getToxLoss()
	var/oxy_loss = patient.getOxyLoss()
	var/chaos_modifier = 0

	var/sickness = "Пациент не показывает признаков заболевания."
	var/sickness_data = "Не применимо."

	var/bleed_status = "Пациент в настоящее время не истекает кровью."
	var/blood_status = " Пациент либо не имеет крови, либо не нуждается в ней для функционирования."
	var/blood_percent = round((patient.blood_volume / BLOOD_VOLUME_NORMAL) * 100)
	var/datum/blood_type/blood_type = patient.get_bloodtype()
	var/blood_name = "ошибка"
	var/blood_warning = " "
	var/blood_alcohol = patient.get_blood_alcohol_content()

	for(var/thing in patient.diseases) //Информация о заболеваниях
		var/datum/disease/D = thing
		if(!(D.visibility_flags & HIDDEN_SCANNER))
			sickness = "Внимание: Пациент является носителем вирусного заболевания. Требуется дополнительная медицинская помощь."
			sickness_data = "\nНазвание: [D.name].\nТип: [D.spread_text].\nСтадия: [D.stage]/[D.max_stages].\nВозможное лечение: [D.cure_text]"

	if(patient.can_bleed()) //Информация об уровне крови
		blood_name = LOWER_TEXT(blood_type.get_blood_name())
		if(patient.is_bleeding())
			bleed_status = " Пациент в настоящее время истекает кровью!"

		if(blood_percent <= 80)
			blood_warning = " У пациента [blood_percent <= 60 ? "ОПАСНО низкий" : "низкий"] уровень [blood_name]."
			var/list/treatments = list()
			if(blood_percent <= 60)
				treatments += "переливание [blood_name]"
			else if(!HAS_TRAIT(patient, TRAIT_NOHUNGER))
				treatments += "обильную пищу"
			if(blood_type.restoration_chem)
				treatments += "добавки [LOWER_TEXT(blood_type.restoration_chem::name)]"
				if(blood_percent <= 60 && blood_type.restoration_chem == /datum/reagent/iron)
					treatments += "солевой глюкозы немедленно"

			if (length(treatments))
				blood_warning += " Требуется [english_list(treatments, and_text = " или ")]"

			if (blood_percent <= 60)
				blood_warning += " Игнорирование лечения может привести к смерти!"

		blood_status = "Уровень [blood_name] пациента составляет [blood_percent]%.[blood_type.get_type() ? " У пациента [blood_type.get_type()] группа [blood_name]." : ""][blood_warning]"

	var/trauma_status = "Пациент не имеет уникальных черепно-мозговых травм."
	var/brain_loss = patient.get_organ_loss(ORGAN_SLOT_BRAIN)
	var/brain_status = "Мозговые паттерны в норме."
	if(LAZYLEN(patient.get_traumas()))
		var/list/trauma_text = list()
		for(var/t in patient.get_traumas())
			var/datum/brain_trauma/trauma = t
			var/trauma_desc = ""
			switch(trauma.resilience)
				if(TRAUMA_RESILIENCE_SURGERY)
					trauma_desc += "тяжелая "
				if(TRAUMA_RESILIENCE_LOBOTOMY)
					trauma_desc += "глубоко укоренившаяся "
				if(TRAUMA_RESILIENCE_MAGIC, TRAUMA_RESILIENCE_ABSOLUTE)
					trauma_desc += "постоянная "
			trauma_desc += trauma.scan_desc
			trauma_text += trauma_desc
		trauma_status = "Обнаружены церебральные травмы: пациент, по-видимому, страдает от [english_list(trauma_text)]."

	var/chemical_list = list()
	var/overdose_list = list()
	var/addict_list = list()
	var/hallucination_status = "Пациент не галлюцинирует."

	if(patient.reagents.reagent_list.len) //Chemical Analysis details.
		for(var/r in patient.reagents.reagent_list)
			var/datum/reagent/reagent = r
			if(reagent.chemical_flags & REAGENT_INVISIBLE) //Don't show hidden chems
				continue
			chemical_list += list(list("name" = reagent.declent_ru(NOMINATIVE), "volume" = round(reagent.volume, 0.01)))
			if(reagent.overdosed)
				overdose_list += list(list("name" = reagent.declent_ru(NOMINATIVE)))
	var/obj/item/organ/stomach/belly = patient.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(belly?.reagents.reagent_list.len) //include the stomach contents if it exists
		for(var/bile in belly.reagents.reagent_list)
			var/datum/reagent/bit = bile
			if(bit.chemical_flags & REAGENT_INVISIBLE) //Don't show hidden chems
				continue
			if(!belly.food_reagents[bit.type])
				chemical_list += list(list("name" = bit.name, "volume" = round(bit.volume, 0.01)))
			else
				var/bit_vol = bit.volume - belly.food_reagents[bit.type]
				if(bit_vol > 0)
					chemical_list += list(list("name" = bit.name, "volume" = round(bit_vol, 0.01)))
	for(var/datum/addiction/addiction_type as anything in patient.mind.active_addictions)
		addict_list += list(list("name" = initial(addiction_type.name)))

	if (patient.has_status_effect(/datum/status_effect/hallucination))
		hallucination_status = "Субъект, по-видимому, галлюцинирует. Рекомендуемые методы лечения: Антипсихотические препараты, [/datum/reagent/medicine/haloperidol::name] или [/datum/reagent/medicine/synaptizine::name]."

	if(patient.stat == DEAD || HAS_TRAIT(patient, TRAIT_FAKEDEATH) || ((brute_loss+fire_loss+tox_loss+oxy_loss) >= 200))  //Проверки статуса пациента.
		patient_status = "Мертв."
	if((brute_loss+fire_loss+tox_loss+oxy_loss) >= 80)
		patient_status = "Тяжело ранен"
	else if((brute_loss+fire_loss+tox_loss+oxy_loss) >= 40)
		patient_status = "Ранен"
	else if((brute_loss+fire_loss+tox_loss+oxy_loss) >= 20)
		patient_status = "Легко ранен"
	if(pandemonium || user.has_status_effect(/datum/status_effect/hallucination))
		patient_status = pick(
			"Единственный киоск - это киоск, но единственный ли пациент - пациент?",
			"Дышит вручную.",
			"Свяжитесь с администратором сайта NTOS.",
			"97% углерода, 3% натуральных ароматизаторов",
			"Приливы и отливы со временем изнашивают нас всех.",
			"Это волчанка. У вас волчанка.",
			"Проходит болезнь обезьян.",
		)

	if((brain_loss) >= 100)   //Проверки состояния мозга.
		brain_status = "Обнаружено серьезное повреждение мозга."
	else if((brain_loss) >= 50)
		brain_status = "Обнаружено тяжелое повреждение мозга."
	else if((brain_loss) >= 20)
		brain_status = "Обнаружено повреждение мозга."
	else if((brain_loss) >= 1)
		brain_status = "Обнаружено легкое повреждение мозга."  //У вас может быть леееегкий случай тяжелого повреждения мозга.

	if(pandemonium)
		chaos_modifier = 1
	else if(user.has_status_effect(/datum/status_effect/hallucination))
		chaos_modifier = 0.3

	data["kiosk_cost"] = get_cost() + (chaos_modifier * (rand(1,25)))
	data["patient_name"] = patient_name
	data["patient_health"] = round(((total_health - (chaos_modifier * (rand(1,50)))) / max_health) * 100, 0.001)
	data["brute_health"] = round(brute_loss+(chaos_modifier * (rand(1,30))),0.001) //To break this down for easy reading, all health values are rounded to the .001 place
	data["burn_health"] = round(fire_loss+(chaos_modifier * (rand(1,30))),0.001) //then a random number is added, which is multiplied by chaos modifier.
	data["toxin_health"] = round(tox_loss+(chaos_modifier * (rand(1,30))),0.001) //That allows for a weaker version of the affect to be applied while hallucinating as opposed to emagged.
	data["suffocation_health"] = round(oxy_loss+(chaos_modifier * (rand(1,30))),0.001) //It's not the cleanest but it does make for a colorful window.
	data["brain_health"] = brain_status
	data["brain_damage"] = brain_loss+(chaos_modifier * (rand(1,30)))
	data["patient_status"] = patient_status
	data["trauma_status"] = trauma_status
	data["patient_illness"] = sickness
	data["illness_info"] = sickness_data
	data["bleed_status"] = bleed_status
	data["blood_name"] = capitalize(blood_name)
	data["blood_levels"] = blood_percent - (chaos_modifier * (rand(1,35)))
	data["blood_status"] = blood_status
	data["blood_alcohol"] = blood_alcohol
	data["chemical_list"] = chemical_list
	data["overdose_list"] = overdose_list
	data["addict_list"] = addict_list
	data["hallucinating_status"] = hallucination_status

	data["active_status_1"] = scan_active & KIOSK_SCANNING_GENERAL // General Scan Check
	data["active_status_2"] = scan_active & KIOSK_SCANNING_SYMPTOMS // Symptom Scan Check
	data["active_status_3"] = scan_active & KIOSK_SCANNING_NEURORAD // Radio-Neuro Scan Check
	data["active_status_4"] = scan_active & KIOSK_SCANNING_REAGENTS // Reagents/hallucination Scan Check
	return data

/obj/machinery/medical_kiosk/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("beginScan_1")
			if(!(scan_active & KIOSK_SCANNING_GENERAL))
				inuse()
			if(paying_customer == TRUE)
				scan_active |= KIOSK_SCANNING_GENERAL
				paying_customer = FALSE
		if("beginScan_2")
			if(!(scan_active & KIOSK_SCANNING_SYMPTOMS))
				inuse()
			if(paying_customer == TRUE)
				scan_active |= KIOSK_SCANNING_SYMPTOMS
				paying_customer = FALSE
		if("beginScan_3")
			if(!(scan_active & KIOSK_SCANNING_NEURORAD))
				inuse()
			if(paying_customer == TRUE)
				scan_active |= KIOSK_SCANNING_NEURORAD
				paying_customer = FALSE
		if("beginScan_4")
			if(!(scan_active & KIOSK_SCANNING_REAGENTS))
				inuse()
			if(paying_customer == TRUE)
				scan_active |= KIOSK_SCANNING_REAGENTS
				paying_customer = FALSE
		if("clearTarget")
			patient_ref = null
			clearScans()
			. = TRUE


#undef KIOSK_SCANNING_GENERAL
#undef KIOSK_SCANNING_NEURORAD
#undef KIOSK_SCANNING_REAGENTS
#undef KIOSK_SCANNING_SYMPTOMS
