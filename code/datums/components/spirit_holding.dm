/**
 * spirit holding component; for items to have spirits inside of them for "advice"
 *
 * Used for the possessed blade and fantasy affixes
 */
/datum/component/spirit_holding
	///bool on if this component is currently polling for observers to inhabit the item
	var/attempting_awakening = FALSE
	/// Allows renaming the bound item
	var/allow_renaming = TRUE
	/// Allows channeling
	var/allow_channeling = TRUE
	/// Allows exorcism
	var/allow_exorcism
	///mob contained in the item.
	var/mob/living/basic/shade/bound_spirit

/datum/component/spirit_holding/Initialize(datum/mind/soul_to_bind, mob/awakener, allow_renaming = TRUE, allow_channeling = TRUE, allow_exorcism = TRUE)
	if(!ismovable(parent)) //you may apply this to mobs, i take no responsibility for how that works out
		return COMPONENT_INCOMPATIBLE
	src.allow_renaming = allow_renaming
	src.allow_channeling = allow_channeling
	src.allow_exorcism = allow_exorcism
	if(soul_to_bind)
		bind_the_soule(soul_to_bind, awakener, soul_to_bind.name)

/datum/component/spirit_holding/Destroy(force)
	. = ..()
	if(bound_spirit)
		QDEL_NULL(bound_spirit)

/datum/component/spirit_holding/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(on_destroy))

/datum/component/spirit_holding/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_EXAMINE, COMSIG_ITEM_ATTACK_SELF, COMSIG_QDELETING))

///сигнал при осмотре родителя
/datum/component/spirit_holding/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(!bound_spirit)
		examine_list += span_notice("[parent] спит.[allow_channeling ? " Используйте [parent] в руках, чтобы попытаться пробудить его." : ""]")
		return
	examine_list += span_notice("[parent] живёт.")

///сигнал при атаке родителя
/datum/component/spirit_holding/proc/on_attack_self(datum/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(get_ghost), user)

/datum/component/spirit_holding/proc/get_ghost(mob/user)
	var/atom/thing = parent
	if(attempting_awakening)
		thing.balloon_alert(user, "уже призываем!")
		return
	if(!(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE))
		thing.balloon_alert(user, "духи не желают!")
		to_chat(user, span_warning("Аномальные потусторонние силы мешают вам пробудить [parent]!"))
		return
	if(!allow_channeling && bound_spirit)
		to_chat(user, span_warning("Как бы вы ни старались, дух внутри продолжает спать."))
		return
	attempting_awakening = TRUE
	thing.balloon_alert(user, "призываем...")
	var/mob/chosen_one = SSpolling.poll_ghosts_for_target(
		question = "Хотите сыграть за [span_notice("Духа [span_danger("меча [user.real_name]")]")]?",
		check_jobban = ROLE_PAI,
		poll_time = 20 SECONDS,
		checked_target = thing,
		ignore_category = POLL_IGNORE_POSSESSED_BLADE,
		alert_pic = thing,
		role_name_text = "одержимый клинок",
		chat_text_border_icon = thing,
	)
	affix_spirit(user, chosen_one)

/// При завершении опроса призраков
/datum/component/spirit_holding/proc/affix_spirit(mob/awakener, mob/dead/observer/ghost)
	var/atom/thing = parent

	if(isnull(ghost))
		thing.balloon_alert(awakener, "тишина...")
		attempting_awakening = FALSE
		return

	// Немедленная отмена регистрации, чтобы предотвратить создание нового духа
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_SELF)
	if(QDELETED(parent)) // если предмет для вселения духа уничтожен - не создаём духа
		to_chat(ghost, span_userdanger("Новый сосуд для твоего духа был уничтожен! Ты остаёшься непривязанным призраком."))
		return

	bind_the_soule(ghost.mind, awakener)

	attempting_awakening = FALSE

	if(!allow_renaming)
		return
	// Теперь, когда всё готово для духа, позволим ему выбрать имя
	var/valid_input_name = custom_name(awakener)
	if(valid_input_name)
		bound_spirit.fully_replace_character_name(null, "Дух [valid_input_name]")

/datum/component/spirit_holding/proc/bind_the_soule(datum/mind/chosen_spirit, mob/awakener, name_override)
	bound_spirit = new(parent)
	chosen_spirit.transfer_to(bound_spirit)
	bound_spirit.fully_replace_character_name(null, "Дух [name_override ? name_override : parent]")
	bound_spirit.get_language_holder().omnitongue = TRUE // Даём всеязычие

	RegisterSignal(parent, COMSIG_ATOM_RELAYMOVE, PROC_REF(block_buckle_message))
	if(allow_exorcism)
		RegisterSignal(parent, COMSIG_BIBLE_SMACKED, PROC_REF(on_bible_smacked))

/**
 * custom_name : Simply sends a tgui input text box to the blade asking what name they want to be called, and retries it if the input is invalid.
 *
 * Arguments:
 * * awakener: user who interacted with the blade
 */
/datum/component/spirit_holding/proc/custom_name(mob/awakener, iteration = 1)
	if(iteration > 5)
		return "нерешительность" // Дух нерешительности
	var/chosen_name = sanitize_name(tgui_input_text(bound_spirit, "Как тебя назвать?", "Выбор имени духа", max_length = MAX_NAME_LEN))
	if(!chosen_name) // учитывая работу sanitize_name, сообщение об ошибке также отправится вызывающему
		to_chat(awakener, span_warning("Твой клинок не выбрал подходящее имя! Подожди, пока он попробует снова.")) // более подробно, чем стандартное сообщение sanitize_name
		return custom_name(awakener, iteration++)
	return chosen_name

///signal fired from a mob moving inside the parent
/datum/component/spirit_holding/proc/block_buckle_message(datum/source, mob/living/user, direction)
	SIGNAL_HANDLER
	return COMSIG_BLOCK_RELAYMOVE

/datum/component/spirit_holding/proc/on_bible_smacked(datum/source, mob/living/user, ...)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(attempt_exorcism), user)

/**
 * attempt_exorcism: called from on_bible_smacked, takes time and if successful
 * resets the item to a pre-possessed state
 *
 * Arguments:
 * * exorcist: user who is attempting to remove the spirit
 */
/datum/component/spirit_holding/proc/attempt_exorcism(mob/exorcist)
	if(!allow_exorcism)
		return // на всякий случай
	var/atom/movable/exorcised_movable = parent
	to_chat(exorcist, span_notice("Ты начинаешь экзорцизм [parent]..."))
	playsound(parent, 'sound/effects/hallucinations/veryfar_noise.ogg',40,TRUE)
	if(!do_after(exorcist, 4 SECONDS, target = exorcised_movable))
		return
	playsound(parent, 'sound/effects/pray_chaplain.ogg',60,TRUE)
	UnregisterSignal(exorcised_movable, list(COMSIG_ATOM_RELAYMOVE, COMSIG_BIBLE_SMACKED))
	RegisterSignal(exorcised_movable, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))
	to_chat(bound_spirit, span_userdanger("Тебя изгнали!"))
	QDEL_NULL(bound_spirit)
	exorcised_movable.name = initial(exorcised_movable.name)
	exorcist.visible_message(span_notice("[exorcist] изгоняет дух из [exorcised_movable]!"), \
						span_notice("Ты успешно изгнал дух из [exorcised_movable]!"))
	return COMSIG_END_BIBLE_CHAIN

///сигнал при уничтожении родителя
/datum/component/spirit_holding/proc/on_destroy(datum/source)
	SIGNAL_HANDLER
	to_chat(bound_spirit, span_userdanger("Ты был уничтожен!"))
	QDEL_NULL(bound_spirit)
