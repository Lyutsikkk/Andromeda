/**
 * ### Keep Me Secure component!
 *
 * Component that attaches to items, invoking a function to react when left unmoved and unsecured for too long.
 * Used for Nuclear Authentication Disks, and whiny plushy as an example (which changes sprites depending on whether it considers itself secure.)
 */
/datum/component/keep_me_secure
	/// callback for the parent being secure
	var/datum/callback/secured_callback
	/// callback for the parent being unsecured
	var/datum/callback/unsecured_callback

	/// The last secure location the parent was at.
	var/turf/last_secured_location
	/// The last world time the parent moved.
	var/last_move
	/// Living population must be above this amount for security checks to apply.
	var/min_pop_limit

/datum/component/keep_me_secure/Initialize(secured_callback, unsecured_callback, min_pop_limit)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.secured_callback = secured_callback
	src.unsecured_callback = unsecured_callback
	src.min_pop_limit = min_pop_limit

/datum/component/keep_me_secure/Destroy(force)
	secured_callback = null
	unsecured_callback = null
	return ..()

/datum/component/keep_me_secure/RegisterWithParent()
	last_move = world.time
	if (secured_callback || unsecured_callback)
		START_PROCESSING(SSobj, src)
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(on_examine_more))


/datum/component/keep_me_secure/UnregisterFromParent()
	STOP_PROCESSING(SSobj, src)
	UnregisterSignal(parent, COMSIG_ATOM_EXAMINE)

/// Returns whether the game is supposed to consider the parent "secure".
/datum/component/keep_me_secure/proc/is_secured()
	if(living_player_count() < src.min_pop_limit)
		return TRUE

	var/obj/item/item_parent = parent
	if (last_secured_location == get_turf(item_parent))
		return FALSE

	var/mob/holder = item_parent.pulledby || get(parent, /mob)
	if (isnull(holder?.client))
		return FALSE

	return TRUE

/datum/component/keep_me_secure/process(seconds_per_tick)
	if(is_secured())
		last_secured_location = get_turf(parent)
		last_move = world.time
		if(secured_callback)
			secured_callback.Invoke(last_move)
	else
		if(unsecured_callback)
			unsecured_callback.Invoke(last_move)

/// сигнал при осмотре родителя
/datum/component/keep_me_secure/proc/on_examine(mob/living/source, mob/examiner, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_boldnotice("[parent] должен быть закреплён в любое время.")
	if(is_secured())
		examine_list += span_notice("Сейчас он закреплён.")
	else
		examine_list += span_warning("Сейчас он не закреплён...")
	examine_list += span_notice("Осмотрите внимательнее для подробностей.")

/// сигнал при детальном осмотре
/datum/component/keep_me_secure/proc/on_examine_more(mob/living/source, mob/examiner, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("Чтобы [parent] был закреплён, необходимо:")
	examine_list += span_notice("1. Постоянное движение, и...")
	examine_list += span_notice("2. Удержание или переноска кем-либо.")
