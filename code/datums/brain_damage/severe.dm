//Severe traumas, when your brain gets abused way too much.
//These range from very annoying to completely debilitating.
//They cannot be cured with chemicals, and require brain surgery to solve.

/datum/brain_trauma/severe
	abstract_type = /datum/brain_trauma/severe
	resilience = TRAUMA_RESILIENCE_SURGERY

/datum/brain_trauma/severe/mute
	name = "Немота"
	desc = "Пациент полностью неспособен говорить."
	scan_desc = "серьезные повреждения речевого центра мозга"
	gain_text = span_warning("Вы забываете, как говорить!")
	lose_text = span_notice("Вы внезапно вспоминаете, как говорить.")

/datum/brain_trauma/severe/mute/on_gain()
	ADD_TRAIT(owner, TRAIT_MUTE, TRAUMA_TRAIT)
	. = ..()

/datum/brain_trauma/severe/mute/on_lose()
	REMOVE_TRAIT(owner, TRAIT_MUTE, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/aphasia
	name = "Афазия"
	desc = "Пациент не может говорить или понимать любой язык."
	scan_desc = "обширные повреждения языкового центра мозга"
	gain_text = span_warning("Вы с трудом подбираете слова в своей голове...")
	lose_text = span_notice("Вы внезапно вспоминаете, как работают языки.")

/datum/brain_trauma/severe/aphasia/on_gain()
	owner.add_blocked_language(subtypesof(/datum/language) - /datum/language/aphasia, source = LANGUAGE_APHASIA)
	owner.grant_language(/datum/language/aphasia, source = LANGUAGE_APHASIA)
	. = ..()

/datum/brain_trauma/severe/aphasia/on_lose()
	if(!QDELING(owner))
		owner.remove_blocked_language(subtypesof(/datum/language), source = LANGUAGE_APHASIA)
		owner.remove_language(/datum/language/aphasia, source = LANGUAGE_APHASIA)

	..()

/datum/brain_trauma/severe/blindness
	name = "Церебральная слепота"
	desc = "Мозг пациента больше не связан с глазами."
	scan_desc = "обширные повреждения затылочной доли мозга"
	gain_text = span_warning("Вы ничего не видите!")
	lose_text = span_notice("Ваше зрение возвращается.")

/datum/brain_trauma/severe/blindness/on_gain()
	owner.become_blind(TRAUMA_TRAIT)
	. = ..()

/datum/brain_trauma/severe/blindness/on_lose()
	owner.cure_blind(TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/paralysis
	name = "Паралич"
	desc = "Мозг пациента больше не может контролировать часть двигательных функций."
	scan_desc = "церебральный паралич"
	gain_text = ""
	lose_text = ""
	var/paralysis_type
	var/list/paralysis_traits = list()
	//для описаний

/datum/brain_trauma/severe/paralysis/New(specific_type)
	if(specific_type)
		paralysis_type = specific_type
	if(!paralysis_type)
		paralysis_type = pick("full","left","right","arms","legs","r_arm","l_arm","r_leg","l_leg")
	var/subject
	switch(paralysis_type)
		if("full")
			subject = "все ваше тело"
			paralysis_traits = list(TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM, TRAIT_PARALYSIS_L_LEG, TRAIT_PARALYSIS_R_LEG)
		if("left")
			subject = "левую сторону вашего тела"
			paralysis_traits = list(TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_L_LEG)
		if("right")
			subject = "правую сторону вашего тела"
			paralysis_traits = list(TRAIT_PARALYSIS_R_ARM, TRAIT_PARALYSIS_R_LEG)
		if("arms")
			subject = "ваши руки"
			paralysis_traits = list(TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM)
		if("legs")
			subject = "ваши ноги"
			paralysis_traits = list(TRAIT_PARALYSIS_L_LEG, TRAIT_PARALYSIS_R_LEG)
		if("r_arm")
			subject = "вашу правую руку"
			paralysis_traits = list(TRAIT_PARALYSIS_R_ARM)
		if("l_arm")
			subject = "вашу левую руку"
			paralysis_traits = list(TRAIT_PARALYSIS_L_ARM)
		if("r_leg")
			subject = "вашу правую ногу"
			paralysis_traits = list(TRAIT_PARALYSIS_R_LEG)
		if("l_leg")
			subject = "вашу левую ногу"
			paralysis_traits = list(TRAIT_PARALYSIS_L_LEG)

	gain_text = span_warning("Вы больше не чувствуете [subject]!")
	lose_text = span_notice("Вы снова чувствуете [subject]!")

/datum/brain_trauma/severe/paralysis/on_gain()
	. = ..()
	for(var/X in paralysis_traits)
		ADD_TRAIT(owner, X, TRAUMA_TRAIT)


/datum/brain_trauma/severe/paralysis/on_lose()
	..()
	for(var/X in paralysis_traits)
		REMOVE_TRAIT(owner, X, TRAUMA_TRAIT)


/datum/brain_trauma/severe/paralysis/paraplegic
	random_gain = FALSE
	paralysis_type = "legs"
	resilience = TRAUMA_RESILIENCE_ABSOLUTE

/datum/brain_trauma/severe/paralysis/hemiplegic
	random_gain = FALSE
	resilience = TRAUMA_RESILIENCE_ABSOLUTE

/datum/brain_trauma/severe/paralysis/hemiplegic/left
	paralysis_type = "left"

/datum/brain_trauma/severe/paralysis/hemiplegic/right
	paralysis_type = "right"

/datum/brain_trauma/severe/narcolepsy
	name = "Нарколепсия"
	desc = "Пациент может непроизвольно засыпать во время обычной деятельности."
	scan_desc = "травматическая нарколепсия"
	gain_text = span_warning("Вы испытываете постоянное чувство сонливости...")
	lose_text = span_notice("Вы снова чувствуете себя бодрым и осознанным.")
	/// Шанс в секунду, что пользователь заснет
	var/sleep_chance = 1
	/// Шанс в секунду, что пользователь заснет во время бега
	var/sleep_chance_running = 2
	/// Шанс в секунду, что пользователь заснет в сонном состоянии
	var/sleep_chance_drowsy = 3
	/// Минимальное время, в течение которого пользователь будет оставаться сонным
	var/drowsy_time_minimum = 20 SECONDS
	/// Максимальное время, в течение которого пользователь будет оставаться сонным
	var/drowsy_time_maximum = 30 SECONDS
	/// Минимальное время сна пользователя
	var/sleep_time_minimum = 6 SECONDS
	/// Максимальное время сна пользователя
	var/sleep_time_maximum = 6 SECONDS

/datum/brain_trauma/severe/narcolepsy/on_life(seconds_per_tick, times_fired)
	if(owner.IsSleeping())
		return

	/// If any of these are in the user's blood, return early
	var/static/list/immunity_medicine = list(
		/datum/reagent/medicine/modafinil,
		/datum/reagent/medicine/synaptizine,
	) //don't add too many, as most stimulant reagents already have a drowsy-removing effect
	for(var/medicine in immunity_medicine)
		if(owner.reagents.has_reagent(medicine))
			return

	var/drowsy = !!owner.has_status_effect(/datum/status_effect/drowsiness)
	var/caffeinated = HAS_TRAIT(owner, TRAIT_STIMULATED)
	var/final_sleep_chance = sleep_chance
	if(owner.move_intent == MOVE_INTENT_RUN)
		final_sleep_chance += sleep_chance_running
	if(drowsy)
		final_sleep_chance += sleep_chance_drowsy //stack drowsy ontop of base or running odds with the += operator
	if(caffeinated)
		final_sleep_chance *= 0.5 //make it harder to fall asleep on caffeine

	if(!SPT_PROB(final_sleep_chance, seconds_per_tick))
		return

	//если не сонный, не засыпать, но сделать сонным
	if(!drowsy)
		to_chat(owner, span_warning("Вы чувствуете усталость..."))
		owner.adjust_drowsiness(rand(drowsy_time_minimum, drowsy_time_maximum))
		if(prob(50))
			owner.emote("yawn")
		else if(prob(33)) //самое редкое сообщение - кастомный эмодзи
			owner.visible_message("трёт [owner.p_their()] глаза.", visible_message_flags = EMOTE_MESSAGE)
	//если сонный - заснуть. у вас был шанс это предотвратить
	else
		to_chat(owner, span_warning("Вы засыпаете."))
		owner.Sleeping(rand(sleep_time_minimum, sleep_time_maximum))
		if(prob(50) && owner.IsSleeping())
			owner.emote("snore")

/datum/brain_trauma/severe/narcolepsy/permanent
	scan_desc = "хроническая нарколепсия" //меньше шансов заснуть чем у родителя, но спит дольше
	sleep_chance = 0.333
	sleep_chance_running = 0.333
	sleep_chance_drowsy = 1
	sleep_time_minimum = 20 SECONDS
	sleep_time_maximum = 30 SECONDS

/datum/brain_trauma/severe/monophobia
	name = "Монофобия"
	desc = "Пациент чувствует себя плохо и тревожно, когда находится не рядом с другими людьми, что может привести к потенциально смертельному уровню стресса."
	scan_desc = "монофобия"
	gain_text = span_warning("Вы чувствуете себя очень одиноко...")
	lose_text = span_notice("Вам кажется, что вы можете быть в безопасности и в одиночестве.")
	var/stress = 0

/datum/brain_trauma/severe/monophobia/on_gain()
	. = ..()
	owner.AddComponentFrom(REF(src), /datum/component/fearful, list(/datum/terror_handler/vomiting, /datum/terror_handler/simple_source/monophobia))

/datum/brain_trauma/severe/monophobia/on_lose(silent)
	. = ..()
	owner.RemoveComponentSource(REF(src), /datum/component/fearful)

/datum/brain_trauma/severe/discoordination
	name = "Дезориентация"
	desc = "Пациент не способен использовать сложные инструменты или механизмы."
	scan_desc = "крайняя степень дезориентации"
	gain_text = span_warning("Вы почти не контролируете свои руки!")
	lose_text = span_notice("Вы снова чувствуете контроль над своими руками.")

/datum/brain_trauma/severe/discoordination/on_gain()
	. = ..()
	owner.apply_status_effect(/datum/status_effect/discoordinated)

/datum/brain_trauma/severe/discoordination/on_lose()
	owner.remove_status_effect(/datum/status_effect/discoordinated)
	return ..()

/datum/brain_trauma/severe/pacifism
	name = "Травматический пацифизм"
	desc = "Пациент категорически не желает причинять вред другим в насильственной форме."
	scan_desc = "пацифический синдром"
	gain_text = span_notice("Вы чувствуете странное умиротворение.")
	lose_text = span_notice("Вы больше не чувствуете принуждения избегать насилия.")

/datum/brain_trauma/severe/pacifism/on_gain()
	ADD_TRAIT(owner, TRAIT_PACIFISM, TRAUMA_TRAIT)
	. = ..()

/datum/brain_trauma/severe/pacifism/on_lose()
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/hypnotic_stupor
	name = "Гипнотический ступор"
	desc = "Пациент склонен к эпизодам крайней заторможенности, делающей его чрезвычайно внушаемым."
	scan_desc = "онейрическая петля обратной связи"
	gain_text = span_warning("Вы чувствуете себя несколько ошеломлённым.")
	lose_text = span_notice("Вы чувствуете, будто туман рассеялся в вашем сознании.")

/datum/brain_trauma/severe/hypnotic_stupor/on_lose() //hypnosis must be cleared separately, but brain surgery should get rid of both anyway
	..()
	owner.remove_status_effect(/datum/status_effect/trance)

/datum/brain_trauma/severe/hypnotic_stupor/on_life(seconds_per_tick, times_fired)
	..()
	if(SPT_PROB(0.5, seconds_per_tick) && !owner.has_status_effect(/datum/status_effect/trance))
		owner.apply_status_effect(/datum/status_effect/trance, rand(100,300), FALSE)

/datum/brain_trauma/severe/hypnotic_trigger
	name = "Гипнотический триггер"
	desc = "В подсознании пациента установлена триггерная фраза, вызывающая внушаемое трансовое состояние."
	scan_desc = "онейрическая петля обратной связи"
	gain_text = span_warning("Вы чувствуете странность, будто забыли что-то важное.")
	lose_text = span_notice("Ощущение, будто груз сняли с вашего сознания.")
	random_gain = FALSE
	var/trigger_phrase = "Nanotrasen"

/datum/brain_trauma/severe/hypnotic_trigger/New(phrase)
	..()
	if(phrase)
		trigger_phrase = phrase

/datum/brain_trauma/severe/hypnotic_trigger/on_lose() //hypnosis must be cleared separately, but brain surgery should get rid of both anyway
	..()
	owner.remove_status_effect(/datum/status_effect/trance)

/datum/brain_trauma/severe/hypnotic_trigger/handle_hearing(datum/source, list/hearing_args)
	if(!owner.can_hear() || owner == hearing_args[HEARING_SPEAKER])
		return

	var/regex/reg = new("(\\b[REGEX_QUOTE(trigger_phrase)]\\b)","ig")

	if(findtext(hearing_args[HEARING_RAW_MESSAGE], reg))
		addtimer(CALLBACK(src, PROC_REF(hypnotrigger)), 1 SECONDS) //to react AFTER the chat message
		hearing_args[HEARING_RAW_MESSAGE] = reg.Replace(hearing_args[HEARING_RAW_MESSAGE], span_hypnophrase("*********"))

/datum/brain_trauma/severe/hypnotic_trigger/proc/hypnotrigger()
	to_chat(owner, span_warning("Эти слова пробуждают что-то глубоко внутри вас, и вы чувствуете, как сознание ускользает..."))
	owner.apply_status_effect(/datum/status_effect/trance, rand(100,300), FALSE)

/datum/brain_trauma/severe/dyslexia
	name = "Дислексия"
	desc = "Пациент не способен читать или писать."
	scan_desc = "дислексия"
	gain_text = span_warning("Вы испытываете трудности с чтением и письмом...")
	lose_text = span_notice("Вы внезапно вспоминаете, как читать и писать.")

/datum/brain_trauma/severe/dyslexia/on_gain()
	ADD_TRAIT(owner, TRAIT_ILLITERATE, TRAUMA_TRAIT)
	. = ..()

/datum/brain_trauma/severe/dyslexia/on_lose()
	REMOVE_TRAIT(owner, TRAIT_ILLITERATE, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/kleptomaniac
	name = "Клептомания"
	desc = "Пациент испытывает непреодолимую тягу к воровству."
	scan_desc = "клептомания"
	gain_text = span_warning("Вас охватывает внезапное желание взять это. Конечно же, никто не заметит.")
	lose_text = span_notice("Вы больше не чувствуете желания брать чужие вещи.")
	/// Время отката между попытками воровства
	COOLDOWN_DECLARE(steal_cd)

/datum/brain_trauma/severe/kleptomaniac/on_gain()
	. = ..()
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(damage_taken))

/datum/brain_trauma/severe/kleptomaniac/on_lose()
	. = ..()
	UnregisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE)

/datum/brain_trauma/severe/kleptomaniac/proc/damage_taken(datum/source, damage_amount, damage_type, ...)
	SIGNAL_HANDLER
	// While you're fighting someone (or dying horribly) your mind has more important things to focus on than pocketing stuff
	if(damage_amount >= 5 && (damage_type == BRUTE || damage_type == BURN || damage_type == STAMINA))
		COOLDOWN_START(src, steal_cd, 12 SECONDS)

/datum/brain_trauma/severe/kleptomaniac/on_life(seconds_per_tick, times_fired)
	if(owner.usable_hands <= 0)
		return
	if(!SPT_PROB(5, seconds_per_tick))
		return
	if(!COOLDOWN_FINISHED(src, steal_cd))
		return
	if(!owner.has_active_hand() || !owner.get_empty_held_indexes())
		return

	// If our main hand is full, that means our offhand is empty, so try stealing with that
	var/steal_to_offhand = !!owner.get_active_held_item()
	var/curr_index = owner.active_hand_index
	var/pre_dir = owner.dir
	if(steal_to_offhand)
		owner.swap_hand(owner.get_inactive_hand_index())

	var/list/stealables = list()
	for(var/obj/item/potential_stealable in oview(1, owner))
		if(potential_stealable.w_class >= WEIGHT_CLASS_BULKY)
			continue
		if(potential_stealable.anchored || !(potential_stealable.interaction_flags_item & INTERACT_ITEM_ATTACK_HAND_PICKUP))
			continue
		stealables += potential_stealable

	for(var/obj/item/stealable as anything in shuffle(stealables))
		if(!owner.CanReach(stealable, view_only = TRUE) || stealable.IsObscured())
			continue
		// Try to do a raw click on the item with one of our empty hands, to pick it up (duh)
		owner.log_message("пытался подобрать (клептомания)", LOG_ATTACK, color = "orange")
		owner.ClickOn(stealable)
		// No feedback message. Intentional, you may not even realize you picked up something
		break

	if(steal_to_offhand)
		owner.swap_hand(curr_index)
	owner.setDir(pre_dir)
	// Gives you a small buffer - not to avoid spam, but to make it more subtle / less predictable
	COOLDOWN_START(src, steal_cd, 8 SECONDS)
